import JSON
import Nanomsg

if length(ARGS) == 0
	throw(ArgumentError("No nodes to execute"))
end

SIFT_ROOT = ENV["SIFT_ROOT"]
IPC_ROOT = ENV["IPC_ROOT"]
DRY = get(ENV, "DRY", "false") == "true"

sift = JSON.parsefile(joinpath(SIFT_ROOT, "sift.json"))

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
	
	const addr = joinpath("ipc://$IPC_ROOT", "$pos.sock")
	const sock = Nanomsg.Socket(Nanomsg.CSymbols.AF_SP, Nanomsg.CSymbols.NN_REP)
	Nanomsg.connect(sock, addr)
	push!(socks, sock)
	push!(mods, mod)
end
	
if DRY
	exit(0)
end

for (sock, i, r, w) in Nanomsg.poll(socks, true, false)
	if r
		data = recv(sock)
		dict = JSON.parse(IOBuffer(data))
		println("IN: from socket at index #$i ", dict)
	
		out = Array{Dict}(0)
		
		tic()	
		res = mod.compute(dict)
	
		if isa(res, Dict)
			push!(out, res)
		else
			for e in res
				push!(out, e)
			end	
		end
		diff = toq()
		
		buf = IOBuffer() 
		JSON.print(buf, Dict("out" => out, "stats" => Dict("result" => diff)))
		Nanomsg.send(sock, takebuf_array(buf), CSymbols.NN_NO_FLAG)
	end
end	
