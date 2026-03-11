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

post = Dict()
post["Site"] = Dict()

# Scenario switches
backup_sys_capex = true

results_path = joinpath(dir, "results")
posts_path = joinpath(dir, "data")

post["Site"]["latitude"] = 33.457466
post["Site"]["longitude"] = -84.151510

max_ton = 950
building_area = 8000
fuel_cost = 8

electric_load = CSV.read(joinpath(posts_path, "electric_load.csv"), DataFrame, header=false)
heating_load = CSV.read(joinpath(posts_path, "heating_load.csv"), DataFrame, header=false)
cooling_load = CSV.read(joinpath(posts_path, "cooling_load.csv"), DataFrame, header=false)
electric_load_v = vec(Array(electric_load))
heating_load_v = vec(Array(heating_load))
cooling_load_v = vec(Array(cooling_load))

# Run REopt:
# Prepare input
post["SpaceHeatingLoad"] = Dict()
post["SpaceHeatingLoad"]["fuel_loads_mmbtu_per_hour"] = heating_load_v

post["CoolingLoad"] = Dict()
post["CoolingLoad"]["thermal_loads_ton"] = cooling_load_v

post["ElectricLoad"] = Dict()
post["ElectricLoad"]["loads_kw"] = electric_load_v
post["ElectricLoad"]["year"] = 2017

# GHP:
post["GHP"] = Dict()
#post["GHP"]["max_ton"] = max_ton
post["GHP"]["require_ghp_purchase"] = 1
#post["GHP"]["heatpump_capacity_sizing_factor_on_peak_load"] = 1.0

ghpghx_inputs = Dict()
ghpghx_inputs["heat_pump_configuration"] = "WSHP"

post["GHP"]["ghpghx_inputs"] = Dict()
post["GHP"]["ghpghx_inputs"] = [ghpghx_inputs]

post["GHP"]["building_sqft"] = building_area
post["GHP"]["om_cost_per_sqft_year"] = 0

# Existing Boiler:
post["ExistingBoiler"] = Dict()
post["ExistingBoiler"]["fuel_cost_per_mmbtu"] = fuel_cost
if backup_sys_capex == true
    post["ExistingBoiler"]["installed_cost_per_mmbtu_per_hour"] = 56000
end
#post["ExistingBoiler"]["max_thermal_factor_on_peak_load"] = 1.0

# Existing Chiller:
post["ExistingChiller"] = Dict()
if backup_sys_capex == true
    post["ExistingChiller"]["installed_cost_per_ton"] = 1000
end
#post["ExistingChiller"]["max_thermal_factor_on_peak_load"] = 1.0

# Electric Tariff:
post["ElectricTariff"] = Dict()
post["ElectricTariff"]["urdb_label"] = "539fc216ec4f024c27d8add3"

write(joinpath(posts_path, "GHP_results_ExstChiller_Debug.json"), JSON.json(post))

post_REopt = REoptInputs(Scenario(post))

#m1= Model(optimizer_with_attributes(Xpress.Optimizer, "OUTPUTLOG" => 0))
#m2 = Model(optimizer_with_attributes(Xpress.Optimizer, "OUTPUTLOG" => 0))
m1= Model(optimizer_with_attributes(Xpress.Optimizer, "OUTPUTLOG" => 0))
m2 = Model(optimizer_with_attributes(Xpress.Optimizer, "OUTPUTLOG" => 0))
r = run_reopt([m1,m2], post_REopt)

#m = Model(optimizer_with_attributes(Xpress.Optimizer, "OUTPUTLOG" => 0))
#r = run_reopt(m, post_REopt)

write(joinpath(results_path, "GHP_results_ExstChiller_Debug.json"), JSON.json(r))

