using Pkg
using JSON
using CSV
using DataFrames
using GhpGhx
using Xpress
using HiGHS
using JuMP
using REopt

dir = @__DIR__
posts_path = joinpath(dir, "data")
results_path = joinpath(dir, "results")

file = "Amanda_demo.json"

post_REopt = JSON.parsefile("$posts_path/$file")

m1 = Model(optimizer_with_attributes(HiGHS.Optimizer, "output_flag" => false, "log_to_console" => false))
m2 = Model(optimizer_with_attributes(HiGHS.Optimizer, "output_flag" => false, "log_to_console" => false))
r = run_reopt([m1,m2], post_REopt)

#m = Model(optimizer_with_attributes(HiGHS.Optimizer, "output_flag" => false, "log_to_console" => false))
#r = run_reopt(m, post_REopt)

write(joinpath(results_path, "Amanda_demo.json"), JSON.json(r))

