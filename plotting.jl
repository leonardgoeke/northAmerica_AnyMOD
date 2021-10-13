modelObj.graInfo.names["hhtOil"] = "oil boiler"
modelObj.graInfo.names["hhtBiomass"] = "bio boiler"
modelObj.graInfo.names["hltBiomass"] = "bio boiler"

modelObj.graInfo.names["hhtGas"] = "gas boiler"
modelObj.graInfo.names["hltGas"] = "gas boiler"
modelObj.graInfo.names["hltOil"] = "oil boiler"
modelObj.graInfo.names["hhtHardcoal"] = "gas boiler"
modelObj.graInfo.names["hhtElec"] = "electric furnace"
modelObj.graInfo.names["hltElec"] = "electric heating"

modelObj.graInfo.names["pGas"] = "gas pp."
modelObj.graInfo.names["chpGas"] = "gas-chp pp."
modelObj.graInfo.names["pHardcoal"] = "coal pp."
modelObj.graInfo.names["chpHardcoal"] = ""

modelObj.graInfo.names["pNuclear"] = "nuclear pp."

modelObj.graInfo.names["resGeothermal"] = "geothermal"
modelObj.graInfo.names["resPvUtilityOpt"] = "solar"

modelObj.graInfo.names["heatHigh"] = "process heat"
modelObj.graInfo.names["heatLow"] = "residential heat"

modelObj.graInfo.names["gasNatural"] = "fossil gas"
modelObj.graInfo.names["gasBio"] = "bio gas"
modelObj.graInfo.names["gasSynth"] = "synthetic gas"

modelObj.graInfo.names["mobilityFreight"] = "freight transport"
modelObj.graInfo.names["mobilityPassenger"] = "passenger transport"

modelObj.graInfo.names["frtRoadElec"] = ""
modelObj.graInfo.names["frtRailRe"] = ""
modelObj.graInfo.names["frtRailFossil"] = "diesel rail"
modelObj.graInfo.names["psngRailRe"] = "electric rail"
modelObj.graInfo.names["psngRailFossil"] = "diesel rail"
modelObj.graInfo.names["psngRoadElec"] = "bev"

modelObj.graInfo.names["frtRoadIce"] = "ICE"
modelObj.graInfo.names["frtRoadPhev"] = "hybrid"

modelObj.graInfo.names["psngAirFossil"] = "air transport"
modelObj.graInfo.names["frtRailFossil"] = "freight transport"
modelObj.graInfo.names["resHydroLarge"] = "hydro"

modelObj.graInfo.colors["power"] = (1.0, 0.9215, 0.2313)

modelObj.graInfo.colors["heatHigh"] = (153/255,0/255,0/255)
modelObj.graInfo.colors["heatLow"] = (255/255,116/255,133/255)

modelObj.graInfo.colors["gasNatural"] = (1.0, 0.416, 0.212)
modelObj.graInfo.colors["gasBio"] = (0.682, 0.898, 0.443)
modelObj.graInfo.colors["gasSynth"] = (0.235,0.506,0.325)

modelObj.graInfo.colors["hardcoal"] = (0.459,0.286,0.216)
modelObj.graInfo.colors["oil"] = (86/255,87/255,83/255)
modelObj.graInfo.colors["nuclear"] = (0.329,0.447,0.827)

modelObj.graInfo.colors["mobilityFreight"] = (111/255,200/255,182/255)
modelObj.graInfo.colors["mobilityPassenger"] = (111/255,200/255,182/255)

usR_arr = getfield.(filter(x -> x.idx in modelObj.sets[:R].nodes[3].down, collect(values(modelObj.sets[:R].nodes))),:idx)


plotEnergyFlow(:sankey,modelObj, dropDown = (:timestep,), rmvNode = rmvNode = ("trade buy; fossil gas","trade buy; hardcoal","trade buy; oil","trade buy; biomass", "trade buy; nuclear"), minVal = 4.0, filterFunc = x -> x.R_dis in usR_arr && x.Ts_disSup == 1)