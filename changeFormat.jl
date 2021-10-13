


function reportEMF(anyM::anyModel)

    # ! read in mappings and prepare variables
    allMapping_dic = YAML.load_file("reportEMF.yml")

    varMap_dic = allMapping_dic["variables"]
    setMap_dic = allMapping_dic["sets"]
    agg_arr = allMapping_dic["aggregations"]

    allVar_df = DataFrame(timestep = String[], region = String[], variable = String[], value = Float64[])

    # ! prepare all summary output files
    repData_dic = Dict{String,DataFrame}()
    for repFile in (:summary,:exchange,:costs)
    
        repData_df = reportResults(repFile,anyM,rtnOpt = (:csvDf,))
        # renames columns to match set names
        if repFile == :summary
            rename!(repData_df,"region_dispatch" => "region","timestep_superordinate_dispatch" => "timestep")
        elseif repFile == :exchange
            rename!(repData_df,"region_from" => "region","timestep_superordinate_dispatch" => "timestep")
        else
            rename!(repData_df,"timestep_superordinate_dispatch" => "timestep")
        end
        
        # replaces set names with names in mapping
        for set in keys(setMap_dic)
            repData_df[!,set] .= map(x -> setMap_dic[set][x],repData_df[!,set])
        end
        
        # write variable names as string for correct string comparision below
        repData_df[!,:variable] = string.(repData_df[!,:variable])

        repData_dic[string(repFile)] = combine(groupby(repData_df,filter(x -> x != "value",names(repData_df))),:value => (x -> sum(x)) => :value)
    end

    # ! loop over reporting variables that have to be created
    for reportVar in keys(varMap_dic)

        mapInfo_arr = varMap_dic[reportVar]
        reportVar_df = DataFrame(timestep = String[], region = String[], value = Float64[])

        # loop over elements aggregated for reporting variable
        for aggCase in mapInfo_arr

            # load dataframe and filter relevant columns
            loadCsv_df = repData_dic[aggCase["file"]]
            filtCol_arr = intersect(collect(keys(aggCase)),names(loadCsv_df))
            fltCsv_df = filter(x -> all(map(y -> occursin(aggCase[y],x[Symbol(y)]),filtCol_arr)),loadCsv_df)
            if isempty(fltCsv_df) continue end

            # apply correction factor and add to dataframe for variable
            fltCsv_df[!,:value] .= fltCsv_df[!,:value] * aggCase["factor"]

            append!(reportVar_df,combine(groupby(fltCsv_df,["timestep", "region"]),:value => (x -> sum(x)) => :value))
        end

        # aggregate all entries for regions and timesteps
        reportVar_df = combine(groupby(reportVar_df,["timestep", "region"]),:value => (x -> sum(x)) => :value)

        # add variable column
        reportVar_df[!,:variable] .= reportVar
        append!(allVar_df,reportVar_df)
    end
    noAggVar_df = copy(allVar_df)

    # ! obtain variables that can be aggregated from others
    for aggVar in agg_arr
        aggVar_df = select(filter(x -> occursin(aggVar,x.variable) ,noAggVar_df),Not([:variable]))
        aggVar_df = combine(groupby(aggVar_df,["timestep", "region"]),:value => (x -> sum(x)) => :value)
        aggVar_df[!,:variable] .= aggVar
        append!(allVar_df,aggVar_df)
    end

    # ! aggregate variables to one region for the us
    usVar_df = filter(x -> !(x.region in ("MEX","CAN")),allVar_df)
    usVar_df[!,:region] .= "USA"
    usVar_df = combine(groupby(usVar_df,["timestep", "region", "variable"]),:value => (x -> sum(x)) => :value)
    append!(allVar_df,usVar_df)

    # add scenario name
    allVar_df[!,:scenario] .= anyM.options.objName

    return allVar_df

end


