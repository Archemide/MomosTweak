if not momoTweak.angelBio then momoTweak.angelBio = {} end

local tree = "solid-tree"
local seed = {}
seed.temp = "tree-temperate-seed"
seed.swamp = "tree-swamp-seed"
seed.desert = "tree-desert-seed"
local garden = {}
garden.temp = "temperate-garden"
garden.desert = "desert-garden"
garden.swamp = "swamp-garden"
local token = "token-bio"
local aboretum_category = "angels-arboretum"

local press_category = "bio-pressing"
local procss_category = "bio-processor"

local aboretum_tech = "bio-arboretum-1"
local aboretum_tech2 = "bio-arboretum-2"
local aboretum_tech3 = "bio-arboretum-3"
local biome_tech = {}
biome_tech.temp = "bio-arboretum-temperate"
biome_tech.desert = "bio-arboretum-desert"
biome_tech.swamp = "bio-arboretum-swamp"

local biome_tech_farm = {}
biome_tech_farm.temp = {"bio-temperate-farming-1", "bio-temperate-farm", "bio-temperate-farming-2"}
biome_tech_farm.desert = {"bio-desert-farming-1", "bio-desert-farm", "bio-desert-farming-2"}
biome_tech_farm.swamp = {"bio-swamp-farming-1", "bio-swamp-farm", "bio-swamp-farming-2"}

local catalyst = {}
catalyst.metal = "catalyst-metal-carrier"
catalyst.red = "catalyst-metal-red"
catalyst.blue = "catalyst-metal-blue" 
catalyst.green = "catalyst-metal-green"
catalyst.yellow = "catalyst-metal-yellow"

local product = {}
product.temp =   {"temperate-1", "temperate-2", "temperate-3", "temperate-4", "temperate-5"}
product.desert = {"desert-1",    "desert-2",    "desert-3",    "desert-4",    "desert-5"}
product.swamp =  {"swamp-1",     "swamp-2",     "swamp-3",     "swamp-4",     "swamp-5"}

local biome = {"temp", "swamp", "desert"}

function momoTweak.angelBio.Data()
	local ICON = "__MomosTweak__/graphics/icons/"
	local count = 0
	local function AddBioItem(Name)
		data:extend({{
			type = "item",
			name = Name,
			icon = ICON .. Name .. ".png",
			icon_size = 32,
			subgroup = "momo-bio-materials",
			order = "f[" .. count .. "]",
			stack_size = 200
		}})
		count = count + 1
	end

	momoTweak.angelBio.refSubgroup = data.raw["item-subgroup"][data.raw.item["temperate-1"].subgroup]
	data:extend({{
		type = "item-subgroup",
		name = "momo-bio-materials",
		group = momoTweak.angelBio.refSubgroup.group,
		order = "zzzzz"
	}})
	
	AddBioItem("momo-oil-pack")

	AddBioItem("bio-grade-1")
	AddBioItem("bio-grade-2")
	AddBioItem("bio-grade-3")
	
	AddBioItem("bio-temp")
	AddBioItem("bio-desert")
	AddBioItem("bio-swamp")
end

function momoTweak.angelBio.Update()
	for i, name in pairs({"temp", "swamp", "desert"}) do
		-- alternate recipe for gardens (easier, but more expensive):
		momoTweak.createRecipe(aboretum_category, {{garden[name], 1}}, {
			{seed[name], 200},
			{tree, 100}
		}, 700, aboretum_tech2)
		-- flora paste recipe:
		momoTweak.createRecipe("crafting", {{"bio-" .. name, 3}},{
			{product[name][1], 8},
			{product[name][2], 8},
			{product[name][3], 8},
			{product[name][4], 8},
			{product[name][5], 8}
		}, 10, biome_tech[name] .. "-1")

		-- make sure flora pastes are craftable (they are required for Chemical science):
		for i, biome_tech_farm_name in pairs(biome_tech_farm[name]) do
			bobmods.lib.tech.remove_prerequisite(biome_tech_farm_name, "chemical-science-pack")
			bobmods.lib.tech.remove_science_pack(biome_tech_farm_name, "chemical-science-pack")
		end
	end


	-- alternate recipe for "token-bio" ("Alien plant-life sample") - easier, but more expensive:
	momoTweak.createRecipe(procss_category, {{token, 1}}, {
		{tree, 120},
		{"momo-vial", 4}
	}, 300, aboretum_tech)
	
	local board2 = momoTweak.ele.board[2]
	for	i, name in pairs({board2, momoTweak.recipe.tin_board2}) do
		momoTweak.replace_with_ingredient(name, "wood", {"solid-paper", 3})
	end
	
	momoTweak.createRecipe("crafting", {{"bio-grade-1", 1}}, {
		{token, 2},
		{"bio-temp", 2},
	}, 3, aboretum_tech2, "1")
	momoTweak.createRecipe("crafting", {{"bio-grade-1", 1}}, {
		{token, 2},
		{"bio-swamp", 2},
	}, 3, aboretum_tech2, "2")
	momoTweak.createRecipe("crafting", {{"bio-grade-1", 1}}, {
		{token, 2},
		{"bio-desert", 2},
	}, 3, aboretum_tech2, "3")
	
	momoTweak.createRecipe("crafting", {{"bio-grade-2", 1}}, {
		{token, 2},
		{"red-cellulose-fiber", 18},
		{"bio-swamp", 1},
		{"bio-desert", 1}
	}, 3, aboretum_tech3, "1")
	
	momoTweak.createRecipe("crafting", {{"bio-grade-2", 1}}, {
		{token, 2},
		{"red-cellulose-fiber", 18},
		{"bio-temp", 1},
		{"bio-desert", 1}
	}, 3, aboretum_tech3, "2")
	
	momoTweak.createRecipe("crafting", {{"bio-grade-2", 1}}, {
		{token, 2},
		{"red-cellulose-fiber", 18},
		{"bio-temp", 1},
		{"bio-swamp", 1}
	}, 3, aboretum_tech3, "3")
	
	momoTweak.createRecipe("crafting", {{"bio-grade-3", 1}}, {
		{"blue-cellulose-fiber", 18},
		{token, 2},
		{"bio-grade-1", 3},
		{"bio-temp", 3},
		{"bio-desert", 3},
		{"bio-swamp", 3}
	}, 3, aboretum_tech3)
	
	bobmods.lib.recipe.add_ingredient("solid-alginic-acid", {"algae-green", 6})
	
	--- wood pulp to cellulose-fiber
	if (data.raw.item["bi-woodpulp"]) then
		momoTweak.createRecipe("crafting", {{"cellulose-fiber", 4}}, {
			{"bi-woodpulp", 4}
		}, 2.5, momoTweak.get_tech_of_recipe("cellulose-fiber-raw-wood"))
	end

	if momoTweak.mods.msp then
		-- make sure resin is craftable in early game:
		bobmods.lib.tech.add_recipe_unlock("electronics", "bob-resin-wood")
		momoTweak.replace_with_ingredient("bob-resin-wood", "wood", {"wood", 24})
		bobmods.lib.recipe.set_energy_required("bob-resin-wood", 24)
	end
end

function momoTweak.angelBio.FinalFixed()
	bobmods.lib.recipe.add_ingredient(momoTweak.sci3, {"bio-grade-1", 1})
	bobmods.lib.recipe.add_ingredient(momoTweak.sciProduction, {"bio-grade-2", 1})
	bobmods.lib.recipe.add_ingredient(momoTweak.sciLogistic, {"bio-grade-2", 1})
	bobmods.lib.recipe.add_ingredient(momoTweak.sciTech, {"bio-grade-3", 1})

	if (momoTweak.mods.sct) then
		local pack = "sct-bio-science-pack"
		bobmods.lib.recipe.add_ingredient(pack, {"momo-vial", momoTweak.get_result_amount(pack)})
		bobmods.lib.recipe.add_ingredient(pack, {"red-sci", 2})
		bobmods.lib.recipe.add_ingredient(pack, {"b1", 1})
		local sample = "sct-bio-ground-sample"
		bobmods.lib.recipe.add_ingredient(sample, {"plate-pack-1", 1})
		bobmods.lib.recipe.add_ingredient(sample, {"solid-alginic-acid", 2})
	end
	
end

function momoTweak.angel_electrolysis_recipe()
	data.raw.recipe["solid-alginic-acid"].category = "electrolysis"


	-- Create alternate handcraftable recipe for Alginic acid - so mods like SeaBlock are not blocked if basic circuits needs paper (electrolyzer would be impossible to craft in such case):
	local alginicAcidAlternate = table.deepcopy(data.raw.recipe["solid-alginic-acid"])

	alginicAcidAlternate.category = "crafting"
	alginicAcidAlternate.name = "solid-alginic-acid-handcraftable"
	alginicAcidAlternate.ingredients = {
		{"algae-green", 18},
		{"algae-brown", 30}
	}
	alginicAcidAlternate.localised_name = "Alginic acid (handcraftable)"

	data:extend({alginicAcidAlternate})

	bobmods.lib.tech.add_recipe_unlock(momoTweak.get_tech_of_recipe("solid-alginic-acid"), "solid-alginic-acid-handcraftable")
end
