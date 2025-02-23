#############################################################################
# Joulia
# A Large-Scale Spatial Power System Model for Julia
# See https://github.com/JuliaEnergy/Joulia.jl
#############################################################################
# Example: ELMOD-DE

#using Joulia
include("src/Joulia.jl")

#Run this only once to set up packages
using Pkg
Pkg.activate(pwd())
Pkg.add("DataFrames")
Pkg.add("CSV")
Pkg.add("JuMP")
Pkg.add("ProgressMeter")
Pkg.add(Pkg.PackageSpec(name = "Gurobi", version = v"0.8"))
#Pkg.add("Clp")
#end

using DataFrames
using CSV
using Gurobi
#using Clp



# data load for 2015 sample data
# see http://doi.org/10.5281/zenodo.1044463
pp_df = CSV.read("data_test/power_plants.csv")
avail_con_df = CSV.read("data_test/avail_con.csv")
prices_df = CSV.read("data_test/prices.csv")

storages_df = CSV.read("data_test/storages.csv")

lines_df = CSV.read("data_test/lines.csv")

load_df = CSV.read("data_test/load.csv")
nodes_df = CSV.read("data_test/nodes.csv")
exchange_df = CSV.read("data_test/exchange.csv")

res_df = CSV.read("data_test/res.csv")
avail_pv = CSV.read("data_test/avail_pv.csv")
avail_windon = CSV.read("data_test/avail_windon.csv")
avail_windoff = CSV.read("data_test/avail_windoff.csv")

avail = Dict(:PV => avail_pv,
	:WindOnshore => avail_windon,
	:WindOffshore => avail_windoff,
	:global => avail_con_df)

# generation of Joulia data types
pp = PowerPlants(pp_df, avail=avail_con_df, prices=prices_df)
storages = Storages(storages_df)
lines = Lines(lines_df)
nodes = Nodes(nodes_df, load_df, exchange_df)
res = RenewableEnergySource(res_df, avail)

# generation of the Joulia model
elmod = JouliaModel(pp, res, storages, nodes, lines)

# sclicing the data in weeks with the first full week starting at hour 49
slices = week_slices(49)

# running the Joulia model for week 30 using the Gurobi solver
results = run_model(elmod, slices[30], solver=GurobiSolver())


