
using AnyMOD, Gurobi, YAML, CSV, DataFrames
include("changeFormat.jl")

round = "R2"

emfFormat_df = DataFrame(timestep = String[], region = String[], variable = String[], scenario = String[], value = Float64[])

# initialize a model object, first two arguments are the input and output directory
# (objName specifies a model name, shortExp specifies the distance of years (e.g. 2015, 2020 ...), decomm = :none deactivates endogenous decommissioning) 
modelObj = anyModel(["modelData","Ref"],"results", objName = "NT.Ref." * round, shortExp = 5, supTsLvl = 2, decomm = :none)

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
reportResults(:exchange,modelObj);

append!(emfFormat_df,reportEMF(modelObj))

#plotEnergyFlow(:sankey,modelObj, dropDown = (:timestep,))

techName_dic = Dict("Ref" => "Ref", "NoDacCCS" => "CMSG.1", "AdvCCS" => "CMSG.2","AdvH2" => "CMSG.3","AdvDac" => "CMSG.4","AdvAll" => "CMSG.Adv")
scrName_dic = Dict("net0by2050" => "0by50", "net0by2060" => "0by60", "net0by2080" => "0by80")

for y in keys(techName_dic)
    println(y)
    for x in keys(scrName_dic)
        println(x)
        modelObj = anyModel(["modelData",x,y],"results", objName = scrName_dic[x]  * "." *  techName_dic[y] * "." * round, shortExp = 5, supTsLvl = 2, decomm = :none)

        # create all variables and equations of the model
        createOptModel!(modelObj)
        
        # set the objective function
        setObjective!(:costs,modelObj)

        # solve model with gurobi 
        set_optimizer(modelObj.optModel,Gurobi.Optimizer)
        set_optimizer_attribute(modelObj.optModel, "Method", 2); # set method option of gurobi to use barrier algorithm
        set_optimizer_attribute(modelObj.optModel, "Crossover", 0); # disable crossover part of barrier algorithm
        optimize!(modelObj.optModel)
        try
            # report results of solved model
            reportResults(:summary,modelObj); #
            reportResults(:exchange,modelObj); #

            append!(emfFormat_df,reportEMF(modelObj))#
        catch
        end
    end
end

CSV.write("results/emfFormat.csv", emfFormat_df)

emfFormatFlt_df = copy(emfFormat_df)
emfFormatFlt_df[!,:value] = map(x -> abs(x) < 1e-5 ? 0.0 : x, emfFormat_df[!,:value])
emfFormatFlt_df = unstack(emfFormatFlt_df, :timestep, :value,allowduplicates=true)
CSV.write("results/emfFormat_fltStack.csv", emfFormatFlt_df)
