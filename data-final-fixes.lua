
local angelsindustries_affected_electronics = {
	-- electronics
	{
		name = "basic-circuit-board", -- localised name: "Basic circuit board" (first circuit board)
		shouldRecipeBeEnabledFromStart = true,
	},
	--{
	--	name = "basic-electronic-board", -- DOESNT EXISTS
	--},
	{
		name = "electronic-circuit", -- localised name: "Basic electronic board" (second circuit board)
		unlock_tech = "electronics"
	},
	{
		name = "advanced-circuit", -- localised name: "Electronic circuit board" (red color)
		unlock_tech = "advanced-electronics"
	},
	{
		name = "processing-unit", -- localised name: "Electronic logic board" (blue color)
		unlock_tech = "advanced-electronics-2"
	},
	{
		name = "advanced-processing-unit", -- localised name: "Electronic processing board" (purple color)
		unlock_tech = "advanced-electronics-3"
	},
	-- electronic components/boards
	{
		name = "wooden-board", -- localised name: "Wooden board"
		shouldRecipeBeEnabledFromStart = true,
	},
	{
		name = "phenolic-board", -- localised name: "Phenolic board"
		unlock_tech = "advanced-electronics"
	},
	{
		name = "fibreglass-board", -- localised name: "Fibreglass board"
		unlock_tech = "advanced-electronics-2"
	},
	{
		name = "circuit-board", -- localised name: "Circuit board" (is red board used as ingredient for "advanced-circuit")
		unlock_tech = "advanced-electronics"
	},
	{
		name = "superior-circuit-board", -- localised name: "Superior circuit board" (is blue board used as ingredient for "processing-unit")
		unlock_tech = "advanced-electronics-2"
	},
	{
		name = "multi-layer-circuit-board", -- localised name: "Multi-layer circuit board" (is purple board used as ingredient for "advanced-processing-unit")
		unlock_tech = "advanced-electronics-3"
	},
	{
		name = "basic-electronic-components", -- localised name: "Basic electronic components"
		unlock_tech = "electronics"
	},
	{
		name = "electronic-components", -- localised name: "Transistors"
		unlock_tech = "advanced-electronics"
	},
	{
		name = "intergrated-electronics", -- localised name: "Integrated electronics"
		unlock_tech = "advanced-electronics-2"
	},
	{
		name = "processing-electronics", -- localised name: "CPUs"
		unlock_tech = "advanced-electronics-3"
	},

	-- gears
	{
		name = "brass-gear-wheel",
		unlock_tech = "zinc-processing"
	},
	{
		name = "cobalt-steel-gear-wheel",
		unlock_tech = "angels-cobalt-steel-smelting-1"
	},

	-- batteries
	{
		name = "lithium-ion-battery",
		unlock_tech = "advanced-electronics-2"
	},
	{
		name = "silver-zinc-battery",
		unlock_tech = "advanced-electronics-3"
	},
}


local angelsindustries_restore_electronics = {
	-- electronics
	{"basic-circuit-board", "circuit-grey"},
	{"electronic-circuit", "circuit-red-loaded"},
	{"advanced-circuit","circuit-green-loaded"},
	{"processing-unit","circuit-blue-loaded"},
	{"advanced-processing-unit","circuit-yellow-loaded"},
	-- electronic components/boards
	--{"wooden-board","circuit-grey-board"},
	{"phenolic-board","circuit-orange-board"},
	{"fibreglass-board","circuit-blue-board"},
	{"circuit-board","circuit-orange"},
	{"superior-circuit-board","circuit-blue"},
	{"multi-layer-circuit-board","circuit-yellow"},
	{"basic-electronic-components","circuit-resistor"},
	{"electronic-components","circuit-transistor"},
	{"intergrated-electronics","circuit-microchip"},
	{"processing-electronics","circuit-cpu"},
}


if momoTweak.mods.angelsindustries then
	-- Fix for mod "angelsindustries":
	-- 1. Loop to reenable electronic ingredients (see list: prototypes/overrides/replacement-fallbacks.lua   and angelsmods.functions.AI.replace_gen_mats() )
	--        ^ also replace their ingredients. For example: in "electronic-circuit" recipe replace "circuit-grey" with "basic-circuit-board" etc
	--        ^ also fix: battery, li-ion battery, silver-zinc battery
	--                ^ TODO: should we add li-ion and silver-zinc to some angelsindustries batteries recipes? Or also to "Pyanodons super conductor"? Accumulators, compnents for high tier robots?
	--        ^ TODO: add "Another world structure compnents" to more builidngs?
	-- 2. add "momo electronic circuits" to recipes of corresponding "angelsindustries circuits". Check if there is no "circular references". Also in the "momo circuits" recipes replace "angelsindustries boards" with "momo boards".
	-- 2. Perform tests also for progression locks on following sets of mods: same but without angelsindustries (with various settings of this mod off/on (especially components)), SeaBlock pack (with and without angelsindustries - but keep in mind that with it overwrites settings - see "settings-updates/angelsindustries.lua" in SeaBlock mod), MSP30 with its science packs in labs (not in chips), the save "new_save - bug with paper reproduction" (130 mods)


	for _,item_data in pairs(angelsindustries_affected_electronics) do
		if data.raw.item[item_data.name] ~= nil then
			local shouldRecipeBeEnabledFromStart = false
			if item_data.shouldRecipeBeEnabledFromStart == true then shouldRecipeBeEnabledFromStart = true end

			momoIRTweak.recipe.reEnableItem(item_data.name)
			momoIRTweak.recipe.reEnableRecipe(item_data.name, shouldRecipeBeEnabledFromStart)
			momoIRTweak.recipe.ChangeRecipeResults(item_data.name,  {
				{
					amount = 1,
					name = item_data.name,
					type = "item"
				}
			})
			if item_data.unlock_tech ~= nil then
				bobmods.lib.tech.add_recipe_unlock(item_data.unlock_tech, item_data.name)
			end
		end
	end
	-- make sure that with mod MSP30 we are not blocked on that tech:
	bobmods.lib.tech.remove_science_pack("advanced-electronics", "more-science-pack-9")
	bobmods.lib.tech.remove_science_pack("advanced-electronics", "more-science-pack-10")


	-- Fix batteries:
	momoTweak.replace_with_ingredient_in_all_recipes("battery", "battery-1")
	momoTweak.replace_with_ingredient_in_all_recipes("lithium-ion-battery", "battery-3")
	momoTweak.replace_with_ingredient_in_all_recipes("silver-zinc-battery", "battery-6")
	momoTweak.replace_with_ingredient("lithium-ion-battery", "lithium-cobalt-oxide", {"solid-lithium", 2})
	momoTweak.replace_with_ingredient("lithium-ion-battery", "battery", {"battery-1", 1})
	bobmods.lib.recipe.add_ingredient("lithium-ion-battery", {"battery-2", 1})
	momoTweak.replace_with_ingredient("momo-py-superconductor-N4", "battery-6", {"battery-4", 4})
	momoTweak.replace_with_ingredient("utility-science-pack", "battery-3", {"silver-zinc-battery", 4})
	-- fix battery in this because otherwise battery-6 will not be craftable? :
	momoTweak.replace_with_ingredient("anotherworld-structure-components", "battery-6", {"battery-5", 300})

	-- Restore Bobs/Momos electronic components in those:
	for _,item_data in pairs(angelsindustries_affected_electronics) do
		for _,replacement in pairs(angelsindustries_restore_electronics) do
			if data.raw.recipe[item_data.name] ~= nil then
				bobmods.lib.recipe.replace_ingredient(item_data.name, replacement[2], replacement[1])
			end
		end
	end

	-- Add Bobs/Momos electronic components to "angelsindustries" circuits:
	bobmods.lib.recipe.add_ingredient("circuit-red-loaded", {"electronic-circuit", 1})
	bobmods.lib.recipe.add_ingredient("circuit-green-loaded", {"electronic-circuit", 2})
	bobmods.lib.recipe.add_ingredient("circuit-orange-loaded", {"advanced-circuit", 1})
	bobmods.lib.recipe.add_ingredient("circuit-blue-loaded", {"processing-unit", 1})
	bobmods.lib.recipe.add_ingredient("circuit-yellow-loaded", {"advanced-processing-unit", 1})

	-- Fix tiers in other recipes:
	bobmods.lib.recipe.remove_ingredient("stone-wall", "block-construction-2")
	momoTweak.replace_with_ingredient("electric-chemical-mixing-furnace", "construction-frame-5", "construction-frame-4")
	momoIRTweak.recipe.reEnableRecipe("boiler", true)

	-- make sure those machines are craftable in early game:
	if data.raw.recipe["angels-chemical-plant"] ~= nil then
		bobmods.lib.recipe.remove_ingredient("angels-chemical-plant", "block-production-1")
	end
	if data.raw.recipe["liquifier"] ~= nil then
		bobmods.lib.recipe.remove_ingredient("liquifier", "block-production-1")
	end

end


if mods["P-U-M-P-S"] then
	local pumpsModBrokenSciencePack5 = false
	if data.raw.recipe["more-science-pack-5"] ~= nil and data.raw.recipe["more-science-pack-5"].ingredients ~= nil then
		for _,ingredient in pairs(data.raw.recipe["more-science-pack-5"].ingredients) do
			if ingredient.name == "OSM-hoffman-void-recipe" then
				pumpsModBrokenSciencePack5 = true
			end
		end
	end

	if pumpsModBrokenSciencePack5 then
		momoTweak.replace_with_ingredient("more-science-pack-5", "OSM-hoffman-void-recipe", {"boiler", 4})
		bobmods.lib.recipe.add_ingredient("more-science-pack-5", {"basic-circuit-board", 3})
		data.raw.recipe["more-science-pack-5"].category = "basic-crafting"
		data.raw.recipe["more-science-pack-5"].icons = nil
		data.raw.recipe["more-science-pack-5"].localised_description = nil

		momoIRTweak.recipe.reEnableRecipe("boiler", true)
	end
end


if mods["Bio_Industries"] then
	if data.raw.recipe["bi-production-science-pack"] ~= nil then
		data.raw.recipe["bi-production-science-pack"].enabled = false
		data.raw.recipe["bi-production-science-pack"].hidden = true
	end
end



require("prototypes.sci.sct-pre-process")

if not momoTweak.isLoadScienceRecipeInUpdates then
	if (momoTweak.mods.sct) then
		momoTweak.require.SctPreProcess()
	end
	
	momoTweak.require.SciRecipe()
	momoTweak.require.Sci30Recipe()
	momoTweak.require.Sci30Extreme()
	
	if (momoTweak.mods.sct) then
		momoTweak.sct.AddToTechnology()
		momoTweak.sct.PostProcessRecipe()
	end
end

require("prototypes.sci.final-fix")

data.raw.item[momoTweak.burner].subgroup = data.raw.item["assembling-machine-1"].subgroup

require("prototypes.fix-angels-machine")
require("prototypes.fix-seablock-machines")
require("prototypes.fix-clowns-angelbob-nuclear-machines")
require("prototypes.sci.sci30result-preset")

if not momoTweak.isLoadScienceRecipeInUpdates then
	momoTweak.sct.IncreaseSciencePackAmount()
end

require("prototypes.sci.vial-recipe")
require("prototypes.machine-restriction")

if (momoTweak.mods.bioIndustries) then
	momoTweak.compatibility.bioIndustries.FixDuplicateProductionSciencePack()
end

if (momoTweak.mods.angelBio) then
	momoTweak.angelBio.FinalFixed()
end

momoTweak.angelChemFluidPower()

-- require("pycom.final")
-- current not support for py

momoTweak.ReworkAngelIndGroup()
momoTweak.ReworkPressureTank()

require("fix")






local count = 0
for	c, r in pairs(data.raw.recipe) do
	count = count + 1
end

log("Total recipe = " .. count)

count = 0
for	c, t in pairs(data.raw.technology) do
	count = count + 1
end

log("Total technology = " .. count)



--[[
log("Momo data-final-fixes.lua::end - begin printing electronic recipes")
-- Note: we should keep this in sync with angelsmods.industries.general_replace from "prototypes/overrides/replacement-fallbacks.lua" from "angelsindustries" mod
for _,item_data in pairs(angelsindustries_affected_electronics) do
	if data.raw["recipe"][item_data.name] ~= nil then
		log("Momo data-final-fixes.lua::end - recipe " .. item_data.name .. ": " .. tostring(serpent.block(data.raw["recipe"][item_data.name])))
	else
		log("Momo data-final-fixes.lua::end - recipe " .. item_data.name .. " - DOESNT EXISTS")
	end
end
log("Momo data-final-fixes.lua::end - finished printing electronic recipes")
--]]



-- You can run tests there for both difficulties:
--require("function-tests")
--automatic_mod_tests.functions.executeTests('normal')
--automatic_mod_tests.functions.executeTests('expensive')
