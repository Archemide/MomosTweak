if momoTweak.mods.clownsAngelBobNuclear then
	-- move "Tead combination plate" recipes to "Steel processing" technology:
	-- (is to make "Basic Structure components" actually craftable)
	bobmods.lib.tech.add_recipe_unlock("steel-processing", "momo-plate-pack-1-N1")
	bobmods.lib.tech.add_recipe_unlock("steel-processing", "momo-tinplate-pack-1-N1")

	bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-1", "momo-plate-pack-1-N1")
	bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-1", "momo-tinplate-pack-1-N1")

	bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-1", "basic-structure-components")
end
