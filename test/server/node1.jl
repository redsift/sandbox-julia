module Node1

println("node1.jl")

compute() = Dict("name" => "default", "key" => "some/thing")

end

compute() = Node1.compute()