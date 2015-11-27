module Node1

println("node1.jl")

compute(data::Dict) = Dict("name" => "default", "key" => "some/thing")

end

compute(data::Dict) = Node1.compute(data)