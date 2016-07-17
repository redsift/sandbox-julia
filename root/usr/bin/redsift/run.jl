import JSON
import Nanomsg
import Compat: UTF8String, ASCIIString

function toEncodedMessage(m)
	if haskey(m, "value")
		const v = m["value"]
		in::AbstractString
		if isa(v, Type{AbstractString}) || isa(v, Type{ASCIIString}) || isa(v, Type{UTF8String})
			in = v
		else
			buf = IOBuffer()
			JSON.print(buf, v)
			in = takebuf_string(buf)
		end

		out = IOBuffer()
		enc = Base64EncodePipe(out)
		write(enc, in)
		close(enc)
		m["value"] = takebuf_string(out)
	end
	return m
end

function decodeValues(b)
	for i in b["data"]
		if haskey(i, "value")
			dec = Base64DecodePipe(IOBuffer(i["value"]) )
			out = readall(dec)
			close(dec)
			i["value"] = out
		end
	end
end

function fromEncodedMessage(m)
	if haskey(m, "in")
		decodeValues(m["in"])
	end

	if haskey(m, "with")
		decodeValues(m["with"])
	end

	return m
end

# --- Main

if length(ARGS) == 0
	throw(ArgumentError("No nodes to execute"))
end

SIFT_ROOT = ENV["SIFT_ROOT"]
SIFT_JSON = ENV["SIFT_JSON"]
IPC_ROOT = ENV["IPC_ROOT"]
DRY = get(ENV, "DRY", "false") == "true"

sift = JSON.parsefile(joinpath(SIFT_ROOT, SIFT_JSON))

socks = Array{Nanomsg.Socket}(0)
mods = Array{Module}(0)

for istring in ARGS
	pos = parse(Int, istring)
	i = pos + 1
	j = sift["dag"]["nodes"][i]["implementation"]["julia"]

	path = joinpath(SIFT_ROOT, j)
	sym = symbol(path)
	mod = Module(sym)
	eval(mod, quote
		eval(x) = Core.eval($sym, x)
		eval(m, x) = Core.eval(m, x)
		include($path)
	end)

	if !isdefined(mod, :compute)
		throw("Node #$pos ($j) does not define compute()")
	end

	addr = joinpath("ipc://$IPC_ROOT", "$pos.sock")
	sock = Nanomsg.Socket(Nanomsg.CSymbols.AF_SP, Nanomsg.CSymbols.NN_REP)
	Nanomsg.connect(sock, addr)
	push!(socks, sock)
	push!(mods, mod)
end

if DRY
	exit(0)
end

for (sock, i, r, w) in Nanomsg.poll(socks, true, false)
	if r
		tic()
		data = recv(sock)

		out = Array{Dict}(0)
		mod = mods[i]

		try
			dict = fromEncodedMessage(JSON.parse(IOBuffer(data)))

			res = mod.compute(dict)

			if isa(res, Dict)
				push!(out, toEncodedMessage(res))
			else
				for e in res
					push!(out, toEncodedMessage(e))
				end
			end
		catch e
			println("ERROR: handling node. Data: ", takebuf_string(IOBuffer(data)))
			throw(e)
		end


		diff = toq()

		buf = IOBuffer()
		JSON.print(buf, Dict("out" => out, "stats" => Dict("result" => diff)))
		Nanomsg.send(sock, takebuf_array(buf), Nanomsg.CSymbols.NN_NO_FLAG)
	end
end
