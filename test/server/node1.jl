module Node1

println("node1.jl")

function compute(data::Dict)
	println("Got data: ", data)
	Dict("name" => "default", "key" => "some/thing", "value" => Dict("something" => "BOO0"))
end

end

compute(data::Dict) = Node1.compute(data)