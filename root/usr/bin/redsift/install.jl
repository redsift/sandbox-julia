SIFT_ROOT = ENV["SIFT_ROOT"]

si = joinpath(SIFT_ROOT, "sysimg.so")
if !isfile(si)
	include(joinpath(JULIA_HOME, Base.DATAROOTDIR, "julia", "build_sysimg.jl"))

	ui = joinpath(SIFT_ROOT, "server", "userimg.jl")
	if !isfile(ui)
		println("userimg file $ui does not exist, skipping sift compile step. Will be slower.")
		ui = nothing
	end

	build_sysimg(joinpath(SIFT_ROOT, "sysimg"), "native", ui)
end
