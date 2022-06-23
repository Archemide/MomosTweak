if mods["SeaBlock"] then
	-- remove "Basic Structure components" ingredient from machines which are essential to SeaBlock's early game:
	bobmods.lib.recipe.remove_ingredient("angels-electrolyser", "basic-structure-components")
	bobmods.lib.recipe.remove_ingredient("crystallizer", "basic-structure-components")
	bobmods.lib.recipe.remove_ingredient("filtration-unit", "basic-structure-components")

	-- move "Tead combination plate" recipes to "Steel processing" technology:
	-- (is to make "Basic Structure components" actually craftable)
	bobmods.lib.tech.add_recipe_unlock("steel-processing", "momo-plate-pack-1-N1")
	bobmods.lib.tech.add_recipe_unlock("steel-processing", "momo-tinplate-pack-1-N1")
	bobmods.lib.tech.remove_recipe_unlock("logistic-science-pack", "momo-plate-pack-1-N1")
	bobmods.lib.tech.remove_recipe_unlock("logistic-science-pack", "momo-tinplate-pack-1-N1")
end
