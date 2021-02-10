using AnyMOD, Gurobi

# ! this branch requires specific AnyMOD version to support energy shares defined in 'par_setShare', version is installed using 'add https://github.com/leonardgoeke/AnyMOD.jl#dev_share'

# initialize a model object, first two arguments are the input and output directory
# (objName specifies a model name, shortExp specifies the distance of years (e.g. 2015, 2020 ...), decomm = :none deactivates endogenous decommissioning) 
modelObj = anyModel("modelData","results", objName = "naEMF", shortExp = 5, decomm = :none)

# create all variables and equations of the model
createOptModel!(modelObj)
# set the objective function
setObjective!(:costs,modelObj)

plotTree(:timestep,modelObj, plotSize = (64.0,8.0))
plotTree(:region,modelObj, plotSize = (64.0,8.0))
plotTree(:technology,modelObj, plotSize = (56.0,8.0))
plotTree(:carrier,modelObj, plotSize = (20.0,8.0))

# solve model with gurobi 
set_optimizer(modelObj.optModel,Gurobi.Optimizer)
set_optimizer_attribute(modelObj.optModel, "Method", 2); # set method option of gurobi to use barrier algorithm
set_optimizer_attribute(modelObj.optModel, "Crossover", 0); # disable crossover part of barrier algorithm
optimize!(modelObj.optModel)

# report results of solved model
plotEnergyFlow(:sankey,modelObj); # writes an html file containing several sankey plots
reportResults(:summary,modelObj); # writes a pivot table summarizing key results
reportResults(:exchange,modelObj); # writes a pivot table with more detailed results on interconnection
reportResults(:costs,modelObj); # writes a pivot table with more detailed results on costs