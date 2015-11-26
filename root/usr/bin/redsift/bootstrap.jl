import JSON
 
if length(ARGS) == 0
	throw(ArgumentError("No nodes to execute"))
end

SIFT_ROOT = ENV["SIFT_ROOT"]
IPC_ROOT = ENV["IPC_ROOT"]
DRY = get(ENV, "DRY", "false") == "true"

sift = JSON.parsefile(joinpath(SIFT_ROOT, "sift.json"))

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
	
	if DRY
		continue
	end
	
	out = Array{Dict}(0)
	
	tic()	
	res = mod.compute()

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
	println(takebuf_string(buf))
end
