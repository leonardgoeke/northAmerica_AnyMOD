
using AnyMOD, Gurobi, YAML, CSV
include("changeFormat.jl")

emfFormat_df = DataFrame(timestep = String[], region = String[], variable = String[], scenario = String[], value = Float64[])

# initialize a model object, first two arguments are the input and output directory
# (objName specifies a model name, shortExp specifies the distance of years (e.g. 2015, 2020 ...), decomm = :none deactivates endogenous decommissioning) 
modelObj = anyModel("modelData","results", objName = "reference", shortExp = 5, supTsLvl = 2, decomm = :none)

# create all variables and equations of the model
createOptModel!(modelObj)
# set the objective function
setObjective!(:costs,modelObj)
# solve model with gurobi 
set_optimizer(modelObj.optModel,Gurobi.Optimizer)
set_optimizer_attribute(modelObj.optModel, "Method", 2); # set method option of gurobi to use barrier algorithm
set_optimizer_attribute(modelObj.optModel, "Crossover", 0); # disable crossover part of barrier algorithm
optimize!(modelObj.optModel)

# report results of solved model
reportResults(:summary,modelObj); # writes a pivot table summarizing key results

append!(emfFormat_df,reportEMF(modelObj))

#plotEnergyFlow(:sankey,modelObj, dropDown = (:timestep,))

x = "net0by2080"
for x in ["net0by2050","net0by2060","net0by2080"]
    modelObj = anyModel(["modelData",x],"results", objName = x, shortExp = 5, supTsLvl = 2, decomm = :none)

    # create all variables and equations of the model
    createOptModel!(modelObj)
    
    # set the objective function
    setObjective!(:costs,modelObj)

    # solve model with gurobi 
    set_optimizer(modelObj.optModel,Gurobi.Optimizer)
    set_optimizer_attribute(modelObj.optModel, "Method", 2); # set method option of gurobi to use barrier algorithm
    set_optimizer_attribute(modelObj.optModel, "Crossover", 0); # disable crossover part of barrier algorithm
    optimize!(modelObj.optModel)

    # report results of solved model
    reportResults(:summary,modelObj); #
    reportResults(:exchange,modelObj); #

    append!(emfFormat_df,reportEMF(modelObj))
end

CSV.write("results/emfFormat.csv", emfFormat_df)