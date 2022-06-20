if not momoTweak then momoTweak = {} end
if not momoTweak.settings then momoTweak.settings = {} end
if not momoTweak.mods then momoTweak.mods = {} end
if not momoTweak.require then momoTweak.require = {} end
if not momoTweak.compatibility then momoTweak.compatibility = {} end
if not momoTweak.sct then momoTweak.sct = {} end

momoTweak.settings.isLoadBobExtended = true

momoTweak.mods.sct = mods["ScienceCostTweakerM"]
momoTweak.mods.angelBio = mods["angelsbioprocessing"]
momoTweak.mods.msp = mods["MoreSciencePacks"] or mods["MoreSciencePacks-for1_1"]
momoTweak.mods.bioIndustries = mods["Bio_Industries"]
momoTweak.mods.modularChests = mods["LB-Modular-Chests"]
momoTweak.mods.undergroundPipePack = mods["underground-pipe-pack"]

if not momoTweak.py then momoTweak.py = {} end


if mods["SeaBlock"] then

    -- Set Angel's triggers - is to revert SeaBlock changes which removed those plates:
    -- see: https://github.com/KiwiHawk/SeaBlock/blob/0f68adb0797f3989e96962085db735b7f8110a17/SeaBlock/data/misc.lua#L15-L23
    -- see: https://github.com/KiwiHawk/SeaBlock/blob/805b3a133d73af1a5dead0c6679a9856806efb12/SeaBlock/data-updates/misc.lua#L211-L214

    --angelsmods.trigger.smelting_products['copper'].powder = true
    angelsmods.trigger.smelting_products['nickel'].plate = true
    angelsmods.trigger.smelting_products['zinc'].plate = true
    angelsmods.trigger.smelting_products['cobalt'].plate = true
    --angelsmods.trigger.ores['platinum'] = true
    --angelsmods.trigger.smelting_products['platinum'].plate = true
    --angelsmods.trigger.smelting_products['platinum'].wire = true
    angelsmods.trigger.smelting_products["gunmetal"].plate = true
end





--- Init IR lib
require("function.helper")
require("function.subgroup")
require("function.item")
require("function.recipe")
require("function.technology")
momoIRTweak.Init("AB")
momoIRTweak.InitItemsLib("__MomosTweak__/graphics/icons/", false)

require("function")
require("const-name")
-- still dont support py yet
-- require("pycom.init")

-- enable cobalt plate:
-- it was hidden in Angels Smelting: https://github.com/Arch666Angel/mods/blob/d6f95b4964c0c995e4a4847bf3f0bd28686d8b93/angelssmelting/data.lua#L69
if (angelsmods ~= nil) and (angelsmods.trigger ~= nil) and (angelsmods.trigger.smelting_products["cobalt"] ~= nil) and (mods["bobplates"] ~= nil) then
    angelsmods.trigger.smelting_products["cobalt"].plate = mods["bobplates"] and true or false
end

require("prototypes.sci.item")
require("prototypes.bobextended.bobextended-data")
require("prototypes.angel-bio")

-- compatibility file load here
require("compatibility.bio-industries")
require("compatibility.modular-chests")
require("compatibility.underground-pipe-pack")

if momoTweak.settings.isLoadBobExtended then
	momoTweak.require.BobExtendedData()
end
-- check for aai before all burner ass
momoTweak.burner = "assembling-machine-0"
if data.raw["assembling-machine"]["burner-assembling-machine"] then
	momoTweak.burner = "burner-assembling-machine"
else
	-- Burner assembler should provided by bob assembly mod
	if (settings.startup["bobmods-assembly-burner"] ~= nil) and (settings.startup["bobmods-assembly-burner"].value == false) then
	    require("prototypes.burner-assembler")
	end
end

if (momoTweak.mods.angelBio) then
	momoTweak.angelBio.Data()
end

data:extend({{
    type = "recipe-category",
    name = "momo-sci-recipe"
}})

data:extend({{
  	type = "custom-input",
  	name = "momo-debug",
  	key_sequence =  "CONTROL + SHIFT + F2",
	consuming = "none"
}})

function momoTweak.GetScienceCraftingCategory()
	if  data.raw["assembling-machine"]["angels-chemical-plant"] and settings.startup["momo-fix-angels-chemistry-machine"].value then
		return "momo-sci-recipe"
	else
		return "crafting"
	end
end

