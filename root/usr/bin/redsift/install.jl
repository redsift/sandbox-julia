SIFT_ROOT = ENV["SIFT_ROOT"]

include(joinpath(JULIA_HOME, Base.DATAROOTDIR, "julia", "build_sysimg.jl"))

ui = joinpath(SIFT_ROOT, "server", "userimg.jl")
if !isfile(ui)
	println("userimg file $ui does not exist, skipping sift compile step. Will be slower.")
	ui = nothing
end

build_sysimg(joinpath(SIFT_ROOT, "sift.so"), "native", ui)