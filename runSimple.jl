
using AnyMOD, Gurobi

# initialize a model object, first two arguments are the input and output directory
# (objName specifies a model name, shortExp specifies the distance of years (e.g. 2015, 2020 ...), decomm = :none deactivates endogenous decommissioning) 
modelObj = anyModel(["modelData","net0by2050"],"results", objName = "net0by2050", shortExp = 5, supTsLvl = 2, decomm = :none)

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
plotEnergyFlow(:sankey,modelObj);
reportResults(:summary,modelObj);
reportResults(:exchange,modelObj);
reportResults(:costs,modelObj); 