
if settings.startup["momo-fix-angels-chemistry-machine"].value then
    -- Check if "normal chemical plants" are enabled - if no then we cant remove "angels-chemical-plant" recipes
    -- In other words: "angels-chemical-plant" should be able to craft chemical stuff
    -- It seems that in new Angels mods (as of 2022-06-11) "chemical-plant-*" plants are removed
    local normalChemicalPlantsAreEnabled = false
	if (data.raw["assembling-machine"]["chemical-plant-2"] ~= nil and not momoIRTweak.tableFindValue(data.raw["assembling-machine"]["chemical-plant-2"].flags, 'hidden'))
        and (data.raw["assembling-machine"]["chemical-plant-3"] ~= nil and not momoIRTweak.tableFindValue(data.raw["assembling-machine"]["chemical-plant-3"].flags, 'hidden'))
        and (data.raw["assembling-machine"]["chemical-plant-4"] ~= nil and not momoIRTweak.tableFindValue(data.raw["assembling-machine"]["chemical-plant-4"].flags, 'hidden'))
    then
        normalChemicalPlantsAreEnabled = true
	end

	if (data.raw.technology["angels-advanced-chemistry-4"]) then
		bobmods.lib.tech.remove_recipe_unlock("electrolysis-1", "bob-distillery")
		if (settings.startup["momo-30-sci-extreme"].value == false) and normalChemicalPlantsAreEnabled then
			bobmods.lib.tech.remove_recipe_unlock("basic-chemistry-2", "angels-chemical-plant")
			bobmods.lib.tech.remove_recipe_unlock("angels-advanced-chemistry-2", "angels-chemical-plant-2")
			bobmods.lib.tech.remove_recipe_unlock("angels-advanced-chemistry-3", "angels-chemical-plant-3")
			bobmods.lib.tech.remove_recipe_unlock("angels-advanced-chemistry-4", "angels-chemical-plant-4")
		end
	end
	
	-- check for independent angel chemical plant
	local chemBase = momoTweak.deepcopy(data.raw["assembling-machine"]["chemical-plant"].crafting_categories)
	local angelChemicalPlantCraftingCategories = momoTweak.deepcopy(data.raw["assembling-machine"]["angels-chemical-plant"].crafting_categories)
	local dirty = false
	for i, angel in pairs( angelChemicalPlantCraftingCategories ) do
		local have = false
		for k, base in pairs( data.raw["assembling-machine"]["chemical-plant"].crafting_categories ) do
			if (angel == base) then 
				have = true 
			end
		end
		
		if have == false then
			log ("MTKL => Angel chem not overlap = " .. angel)
			table.insert(chemBase, angel)
			dirty = true
		end
	end
	-- end check
	
	if not dirty then log("MTKL => no standalone category for angels chem.") end
	
	local cat_override = "momo-sci-recipe"

	if (data.raw["recipe-category"][cat_override]) then

	    if (normalChemicalPlantsAreEnabled) then
            data.raw["assembling-machine"]["angels-chemical-plant"]  .crafting_categories = {cat_override}
            data.raw["assembling-machine"]["angels-chemical-plant-2"].crafting_categories = {cat_override}
            data.raw["assembling-machine"]["angels-chemical-plant-3"].crafting_categories = {cat_override}
            data.raw["assembling-machine"]["angels-chemical-plant-4"].crafting_categories = {cat_override}


            data.raw["assembling-machine"]["chemical-plant"]  .crafting_categories = chemBase
            data.raw["assembling-machine"]["chemical-plant-2"].crafting_categories = chemBase
            data.raw["assembling-machine"]["chemical-plant-3"].crafting_categories = chemBase
            data.raw["assembling-machine"]["chemical-plant-4"].crafting_categories = chemBase
        else
            -- loop through "angels-chemical-plant-*" and take each crafting categories and add cat_override to them:
            for k, chemicalPlantName in pairs({"angels-chemical-plant", "angels-chemical-plant-2", "angels-chemical-plant-3", "angels-chemical-plant-4"}) do
                momoIRTweak.tableAddValueIfUnique(data.raw["assembling-machine"][chemicalPlantName].crafting_categories, cat_override)
                momoIRTweak.tableAddValueIfUnique(data.raw["assembling-machine"][chemicalPlantName].crafting_categories, "chemistry")
            end
        end

	    momoTweak.angelChemPlanTweak()
	end
end

-- those plants need to be able to craft Momo recipes which require many ingredients:
for k, chemicalPlantName in pairs({"angels-chemical-plant", "angels-chemical-plant-2", "angels-chemical-plant-3", "angels-chemical-plant-4"}) do
	if (data.raw["assembling-machine"][chemicalPlantName] ~= nil) then
		data.raw["assembling-machine"][chemicalPlantName].ingredient_count = 50
		-- this category will be handled by liquifiers and advanced chemical plants:
		momoIRTweak.tableRemoveItem(data.raw["assembling-machine"][chemicalPlantName].crafting_categories, "liquifying")
	end
end

for k, electrolyserName in pairs({"angels-electrolyser", "angels-electrolyser-2", "angels-electrolyser-3", "angels-electrolyser-4"}) do
	if (data.raw["assembling-machine"][electrolyserName] ~= nil) then
		data.raw["assembling-machine"][electrolyserName].ingredient_count = 50;
	end
end

-- adjust liquifiers:
for k, liquifierName in pairs({"liquifier", "liquifier-2", "liquifier-3", "liquifier-4"}) do
	if (data.raw["assembling-machine"][liquifierName] ~= nil) then
		data.raw["assembling-machine"][liquifierName].ingredient_count = 50
		momoIRTweak.tableAddValueIfUnique(data.raw["assembling-machine"][liquifierName].crafting_categories, "liquifying")
	end
end

if (data.raw["assembling-machine"]["advanced-chemical-plant"] ~= nil) then
	momoIRTweak.tableAddValueIfUnique(data.raw["assembling-machine"]["advanced-chemical-plant-2"].crafting_categories, "liquifying")
end
if (data.raw["assembling-machine"]["advanced-chemical-plant-2"] ~= nil) then
	data.raw["assembling-machine"]["advanced-chemical-plant-2"].ingredient_count = 50
	momoIRTweak.tableAddValueIfUnique(data.raw["assembling-machine"]["advanced-chemical-plant-2"].crafting_categories, "liquifying")
end

