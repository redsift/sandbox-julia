compute(data::Dict) = @task for i = 1:5
  sleep(0.1)
  produce(Dict("name" => "default", "key" => "async/thing$i"))
end