if not automatic_mod_tests then automatic_mod_tests = {} end
if not automatic_mod_tests.functions then automatic_mod_tests.functions = {} end

--[[
Goal: create automatic test for 'no progression blocker':
    * General algorithm should loop like this until it reaches satellite:
        vars: "researched_recipes", "craftable_items" (maybe?: "craftable_fluids")
        1. Gather all researched recipes (with enabled==true, hidden != true) - save in "researched_recipes"
            1a. TODO: Ignore recipes like: barelling/unbarreling, stacking/unstacking, boxes/unboxes (crates?), compressing/uncompressing fluids (pressurized fluids), burning in furnaces (in Pyanadon), crushing in crushers to nothing (AAI or SpaceExploration?), SpaceExploration capsules & unpacking of rocket sections/parts.
                ^ is mainly for performance reasons? Or maybe it will prevent false positive scenarios?
                ^ also: recipe.results contains: { amount = 1, name = "chemical-void" }
        2. Go through all items/fluids that can be "mined" (or pumped from "pumpjacks", "offshore pumps" etc) - add them to "craftable_items".
            2a. So start from looping through entities which are miners, pumps etc - and check what are they mining. Then loop through all resources which fit those machines and take items which are mined from them and put them in "craftable_items".
            2b. Make sure that each item is not hidden etc before adding it.
            2c. Make sure there is machine (mining drill, pumpjack) - which is researched and craftable - that can "mine" such item/fluid.
        3. Go through "researched_recipes" and for each check if is craftable - so if all ingredient items are in "craftable_items". :
            3a. Also check if there exists (researched and craftable) entity (machine) which can craft such recipe (check recipe category vs crafting categories of entity etc).
            3b. If such recipe is craftable then: Add all items from its result(s) to "craftable_items" and remove said recipe from "researched_recipes"
                ^ Make sure that each item is not hidden etc before adding it.
        4. Go through all technologies which are possible to research at this moment. For each check if all required science packs are craftable - if yes then consider such technology researched. In such case add all recipes which this technology unlocks to "researched_recipes"
            4a. Make sure to check https://wiki.factorio.com/Prototype/Technology#enabled is not false
            4b. Consider specific "technology difficulty" (normal or expensive) - https://wiki.factorio.com/Prototype/Technology#Technology_data
            4c. Make sure to check prerequisites
        5. If "satellite" is in "craftable_items" then end with success. If there was any change in "researched_recipes" or "craftable_items" or technologies researched (without infinite ones - https://wiki.factorio.com/Prototype/Technology#max_level ) then go to point 2, else end with failure.
            5a. in case of failure write to log: "researched_recipes", "craftable_items", technologies researched, technologies possible to research, science packs needed for said technologies.

    Other notes for tests:
    ** we should try doing whole loop for "normal" and "expensive" difficulty of recipes ( see https://wiki.factorio.com/Prototype/Recipe#Recipe_data )
    ** we should create a separate mod with such tests - this way will be easier to reuse it later (just add mod in Factorio and observe log etc).
        ^ Add dependencies for other mods to it - so this "test mod" will be loaded after all other mods.

    ** TODO: Test also scenarios with other mods combinations:
        - mods listed in "momoTweak.mods" variable (see data.lua) - especially momoTweak.mods.angelBio ("angelsbioprocessing")
        - SeaBlock
        ** ^ Is it possible to automatize such test scenarios with other mod combinations? Or always someone needs to restart the game manually with specific sets of mods per scenario?

    ** Balance:
        - TODO: add "anotherworld" modules to highest levels of machines (but dont break progress). Then iterate over those machines and add also +1 or +2 module slots ( https://wiki.factorio.com/Prototype/CraftingMachine#module_specification ) and maybe increase speed. It should be done because that ingredient is expensive, and there should be more reward for investing in such machine.


    ** Incompatibilities:
        - TODO: see momoTweak.mods.angelsindustries in data-final-fixes.lua notes
--]]

function automatic_mod_tests.functions.executeTests(difficulty)
    log("automatic_mod_tests.functions.executeTests::start - executing for difficulty: " .. difficulty)

    local researched_recipes = {}
    local researched_technologies = {}
    local craftable_items = {}
    local craftable_fluids = {}
    local craftable_mining_entities = {}
    local craftable_crafting_entities = {}
    craftable_crafting_entities['assembling-machine'] = {}
    craftable_crafting_entities['boiler'] = {}
    craftable_crafting_entities['furnace'] = {}
    local character_crafting_categories = data.raw.character['character'].crafting_categories


    local minable_resource_categories = {}

    local test_iteration_number = 0

    --log("automatic_mod_tests log => automatic_mod_tests.functions.executeTests - recipe electric-mining-drill: " .. tostring(serpent.block(data.raw.recipe['electric-mining-drill'])))
    --log("automatic_mod_tests log => automatic_mod_tests.functions.executeTests - recipe momo-building-pack-N1: " .. tostring(serpent.block(data.raw.recipe['momo-building-pack-N1'])))
    --log("automatic_mod_tests log => automatic_mod_tests.functions.executeTests - recipe more-science-pack-1: " .. tostring(serpent.block(data.raw.recipe['more-science-pack-1'])))
    --log("automatic_mod_tests log => automatic_mod_tests.functions.executeTests - recipe more-science-pack-5: " .. tostring(serpent.block(data.raw.recipe['more-science-pack-5'])))


    -- fish can be obtained from map manually:
    craftable_items['raw-fish'] = true
    -- lets assume steam is craftable:
    craftable_fluids['steam'] = true

    if mods["angelsbioprocessing"] ~= nil then
        -- add those big trees and gardens to craftable items because they can be mined manually from map by player:
        craftable_items['desert-tree'] = true
        craftable_items['swamp-tree'] = true
        craftable_items['temperate-tree'] = true
        craftable_items['desert-garden'] = true
        craftable_items['swamp-garden'] = true
        craftable_items['temperate-garden'] = true
    end

    if mods["SeaBlock"] then
        craftable_items['angels-ore1-crushed'] = true -- saphirite
        craftable_items['angels-ore3-crushed'] = true -- stiratite
        craftable_items['cellulose-fiber'] = true -- craftable by hand (infinite)
        craftable_items['stone-crushed'] = true
    end

    if mods["SeaBlock"] == nil then
        -- can be obtained from chopping wood:
        craftable_items['wood'] = true
    end


    -- Note: This is point 1 in our "automatic test plan"
    for _,recipe in pairs(data.raw.recipe) do
        if recipe[difficulty] ~= nil then
            if recipe[difficulty].enabled == true or recipe[difficulty].enabled == "true" or recipe[difficulty].enabled == nil then
                researched_recipes[recipe.name] = true
            end
        else
            if recipe.enabled == true or recipe.enabled == "true" or recipe.enabled == nil then
                researched_recipes[recipe.name] = true
            end
        end
    end


    while test_iteration_number < 120 do
        test_iteration_number = test_iteration_number + 1


        -- Note: This is point 2 in our "automatic test plan"
        automatic_mod_tests.functions.perform_point_2__populate_craftable_items_and_fluids_from_resources(researched_recipes, craftable_items, craftable_fluids, craftable_mining_entities, minable_resource_categories, test_iteration_number > 1)

        -- Note: This is point 3 in our "automatic test plan"
        automatic_mod_tests.functions.perform_point_3__populate_craftable_items_from_recipes(researched_recipes, craftable_items, craftable_fluids, craftable_crafting_entities, character_crafting_categories, test_iteration_number <= 2, difficulty)

        -- Note: This is point 4 in our "automatic test plan"
        automatic_mod_tests.functions.perform_point_4__research_technologies(researched_technologies, researched_recipes, craftable_items, difficulty)
    end


    if craftable_items['satellite'] == nil or craftable_items['rocket-silo'] == nil then
        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - satellite or rocket-silo is not craftable - please check debug data to find out why:")

        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - researched_recipes(" .. tostring(automatic_mod_tests.functions.tableLength(researched_recipes)) .. "): " .. tostring(serpent.block(researched_recipes)))

        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - craftable_items(" .. tostring(automatic_mod_tests.functions.tableLength(craftable_items)) .. "): " .. tostring(serpent.block(craftable_items)))
        --log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - craftable_items(" .. tostring(automatic_mod_tests.functions.tableLength(craftable_items)) .. "): " .. tostring(serpent.dump(craftable_items)))
        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - craftable_fluids(" .. tostring(automatic_mod_tests.functions.tableLength(craftable_fluids)) .. "): " .. tostring(serpent.block(craftable_fluids)))
        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - craftable_mining_entities(" .. tostring(automatic_mod_tests.functions.tableLength(craftable_mining_entities)) .. "): " .. tostring(serpent.block(craftable_mining_entities)))
        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - craftable_crafting_entities(" .. tostring(automatic_mod_tests.functions.tableLength(craftable_crafting_entities)) .. "): " .. tostring(serpent.block(craftable_crafting_entities)))
        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - minable_resource_categories(" .. tostring(automatic_mod_tests.functions.tableLength(minable_resource_categories)) .. "): " .. tostring(serpent.block(minable_resource_categories)))

        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - researched_technologies(" .. tostring(automatic_mod_tests.functions.tableLength(researched_technologies)) .. "): " .. tostring(serpent.block(researched_technologies)))


        automatic_mod_tests.functions.log_science_packs_missing_ingredients(craftable_items, craftable_fluids, researched_recipes, difficulty)
    else
        log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - satellite is craftable - congratulations!")
    end

    log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - finished for difficulty: " .. difficulty)


    -- Note: comment it out before commit (for manual debug only, big amount of data):
    --log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - list names in data.raw 2 levels deep:(" .. tostring(automatic_mod_tests.functions.tableLength(data.raw)) .. "): ")
    --for type_name,objects_of_type in pairs(data.raw) do
    --    log("data.raw[" .. type_name .."]:")
    --    for object_name,a_object in pairs(objects_of_type) do
    --        log("data.raw[" .. type_name .."][" .. object_name .. "]")
    --    end
    --end
    --log("function-tests.lua - automatic_mod_tests.functions.executeTests::end - list names in data.raw - end of dump")
end



-- -----------------------------------------------------------------------------
-- Functions to perform major steps of tests:


function automatic_mod_tests.functions.perform_point_2__populate_craftable_items_and_fluids_from_resources(researched_recipes, craftable_items, craftable_fluids, craftable_mining_entities, minable_resource_categories, is_beginning_of_game)
    for _,entity_type in pairs({"mining-drill", "offshore-pump"}) do
        for _,entity in pairs(data.raw[entity_type]) do
            -- only process entity if is craftable (if there is recipe for it):
            if automatic_mod_tests.functions.is_entity_craftable(researched_recipes, craftable_items, entity.name, is_beginning_of_game) then
                if craftable_mining_entities[entity.type] == nil then
                    craftable_mining_entities[entity.type] = {}
                end
                craftable_mining_entities[entity.type][entity.name] = true
            end
        end
    end

    for entity_type,entities in pairs(craftable_mining_entities) do
        for entity_name in pairs(entities) do
            if entity_type == "mining-drill" then
                for _,resource_category in pairs(data.raw[entity_type][entity_name].resource_categories) do
                    minable_resource_categories[resource_category] = true
                end
            elseif entity_type == "offshore-pump" then
                craftable_fluids[data.raw[entity_type][entity_name].fluid] = true
            end
        end
    end

    for _,entity in pairs(data.raw.resource) do
        local entity_category = entity.category or 'basic-solid'
        if minable_resource_categories[entity_category] ~= nil then
            if entity.minable.results ~= nil then
                for _,minable_result in pairs(entity.minable.results) do
                    if minable_result.type == 'item' then
                        craftable_items[minable_result.name] = true
                    elseif minable_result.type == 'fluid' then
                        craftable_fluids[minable_result.name] = true
                    end
                end
            else
                craftable_items[entity.minable.result] = true
            end
        end
    end
end

function automatic_mod_tests.functions.perform_point_3__populate_craftable_items_from_recipes(researched_recipes, craftable_items, craftable_fluids, craftable_crafting_entities, character_crafting_categories, is_first_iteration, difficulty)
    for recipe_name,_ in pairs(researched_recipes) do
        local recipeObject = data.raw.recipe[recipe_name]
        local converted_ingredients = automatic_mod_tests.functions.convert_recipe_ingredients(recipeObject, difficulty)

        local machineExistsToCraftThis = function(a_recipeObject, a_craftable_crafting_entities, a_character_crafting_categories, a_is_first_iteration)
            if a_is_first_iteration then
                return true
            end

            -- check if there is a machine which can use this recipe:

            if a_recipeObject.category == "crafting" or a_recipeObject.category == "angels-manual-crafting" or a_recipeObject.category == nil then
                -- can be crafted by hand
                return true
            end
            for _, category in pairs(a_character_crafting_categories) do
                if a_recipeObject.category == category then
                    -- can be crafted by hand
                    return true
                end
            end

            for type_name,entities_of_type in pairs(a_craftable_crafting_entities) do
                for entity_name,_ in pairs(entities_of_type) do
                    if (type_name == "assembling-machine" or type_name == "furnace") and data.raw[type_name][entity_name].crafting_categories ~= nil then
                        for _,entity_crafting_category in pairs(data.raw[type_name][entity_name].crafting_categories) do
                            if a_recipeObject.category == entity_crafting_category then
                                -- can be crafted by this entity
                                return true
                            end
                        end
                    end
                end
            end

            return false
        end

        local are_ingredients_craftable = function(a_converted_ingredients, a_craftable_items, a_craftable_fluids)
            for _,ingredient_item_name in pairs(a_converted_ingredients.craftable_items) do
                if a_craftable_items[ingredient_item_name] == nil then
                    -- not craftable
                    return false
                end
            end
            for _,ingredient_fluid_name in pairs(a_converted_ingredients.craftable_fluids) do
                if a_craftable_fluids[ingredient_fluid_name] == nil then
                    -- not craftable
                    return false
                end
            end
            return true
        end


        if machineExistsToCraftThis(recipeObject, craftable_crafting_entities, character_crafting_categories, is_first_iteration)
            and are_ingredients_craftable(converted_ingredients, craftable_items, craftable_fluids)
        then
            local converted_results = automatic_mod_tests.functions.convert_recipe_results(recipeObject, difficulty)

            for _,result_item_name in pairs(converted_results.craftable_items) do
                craftable_items[result_item_name] = true
                -- TODO: (performance) consider removing recipe from researched_recipes (we will not need it later?)

                -- check if item will place entity:
                local place_result = nil

                if data.raw.item[result_item_name] ~= nil then
                    place_result = data.raw.item[result_item_name].place_result
                end

                local entity_type = nil
                if place_result ~= nil then
                    entity_type = automatic_mod_tests.functions.get_crafting_entity_type(place_result)
                    if entity_type ~= nil then
                        craftable_crafting_entities[entity_type][place_result] = true
                    end
                end
            end

            for _,result_fluid_name in pairs(converted_results.craftable_fluids) do
                craftable_fluids[result_fluid_name] = true
            end
        end
    end
end


function automatic_mod_tests.functions.perform_point_4__research_technologies(researched_technologies, researched_recipes, craftable_items, difficulty)
    local technologyDataByDifficulty = {}
    local whitelist_ingredients = {}
    if mods["SeaBlock"] then
        whitelist_ingredients = {
            ["sb-angelsore3-tool"] = true,
            ["sb-algae-brown-tool"] = true,
            ["sb-basic-circuit-board-tool"] = true,
            ["sb-lab-tool"] = true,
        }
    end

    local are_prerequisites_met = function(technologyDataPrerequisites, a_researched_technologies)
        if technologyDataPrerequisites ~= nil and not automatic_mod_tests.functions.isTableEmpty(technologyDataPrerequisites) then
            for _,prerequisite in pairs(technologyDataPrerequisites) do
                if a_researched_technologies[prerequisite] == nil then
                    return false
                end
            end
        end
        return true
    end

    local are_ingredients_craftable = function(a_technologyData, a_craftable_items, a_whitelist_ingredients)
        if a_technologyData.unit == nil or automatic_mod_tests.functions.isTableEmpty(a_technologyData.unit) then
            return true
        end
        if a_technologyData.unit.ingredients == nil or automatic_mod_tests.functions.isTableEmpty(a_technologyData.unit.ingredients) then
            return true
        end

        local converted_ingredients = automatic_mod_tests.functions.convert_technology_ingredients(a_technologyData.unit.ingredients)

        for _,ingredient_item_name in pairs(converted_ingredients) do
            if a_whitelist_ingredients[ingredient_item_name] == nil and a_craftable_items[ingredient_item_name] == nil then
                return false
            end
        end

        return true
    end


    for _,tech in pairs(data.raw.technology) do
        if researched_technologies[tech.name] == nil then
            -- handle technology difficulty: https://wiki.factorio.com/Prototype/Technology#Technology_data
            if tech[difficulty] ~= nil then
                technologyDataByDifficulty = tech[difficulty]
            else
                technologyDataByDifficulty = tech
            end


            if technologyDataByDifficulty.max_level ~= "infinite"
                and are_prerequisites_met(technologyDataByDifficulty.prerequisites, researched_technologies)
                and are_ingredients_craftable(technologyDataByDifficulty, craftable_items, whitelist_ingredients)
            then
                researched_technologies[tech.name] = true

                if technologyDataByDifficulty.effects ~= nil and not automatic_mod_tests.functions.isTableEmpty(technologyDataByDifficulty.effects) then
                    for _,effect in pairs(technologyDataByDifficulty.effects) do
                        if effect.type == "unlock-recipe" then
                            researched_recipes[effect.recipe] = true
                        end
                    end
                end
            end

        end
    end
end



-- -----------------------------------------------------------------------------
-- Logging functions:


function automatic_mod_tests.functions.log_science_packs_missing_ingredients(craftable_items, craftable_fluids, researched_recipes, difficulty)
    -- type: lab, check property for science packs: "inputs"

    local all_lab_tools = {}

    for _, entity in pairs(data.raw.lab) do
        --[[
        example of entity.inputs (those are items of type "tool"):

        {
          "automation-science-pack",
          "logistic-science-pack",
          "military-science-pack",
          "chemical-science-pack",
          "production-science-pack",
          "utility-science-pack",
          "space-science-pack",
          "advanced-logistic-science-pack",
          "token-bio"
        }
        --]]

        if not automatic_mod_tests.functions.isTableEmpty(entity.inputs) then
            for _, tool_name in pairs(entity.inputs) do
                all_lab_tools[tool_name] = true
            end
        end
    end

    -- also show why satellite or rocket-silo is not craftable:
    all_lab_tools["satellite"] = true
    all_lab_tools["rocket-silo"] = true


    log("-----------------------------------------------------------------------------------------------")
    log("function-tests.lua - log => We will print information about craftability of each science pack: ")
    for tool_name, _ in pairs(all_lab_tools) do
        if craftable_items[tool_name] ~= nil then
            log("function-tests.lua - log => science pack '" .. tool_name .. "' is craftable - OK")
        else
            log("function-tests.lua - log => science pack '" .. tool_name .. "' is not craftable - WRONG - its ingredients: ");
            local indent_level = 1
            -- to prevent "infinite loop":
            local already_checked_items = {}
            automatic_mod_tests.functions.print_uncraftable_recipes_recurrent(tool_name, indent_level, already_checked_items, researched_recipes, craftable_items, craftable_fluids, difficulty)
        end
    end
end


function automatic_mod_tests.functions.print_uncraftable_recipes_recurrent(item_to_check, indent_level, already_checked_items, researched_recipes, craftable_items, craftable_fluids, difficulty)
    local indent = automatic_mod_tests.functions.make_indent(indent_level)

    if (craftable_items[item_to_check] ~= nil) or (craftable_fluids[item_to_check] ~= nil) then
        log(indent .. "'" .. item_to_check .. "' - craftable (OK)")
        return
    end

    if already_checked_items[item_to_check] ~= nil then
        log(indent .. "    " .. item_to_check .. " not craftable (WRONG, already checked)")
        return
    end

    already_checked_items[item_to_check] = true

    log(indent .. "'" .. item_to_check .. "' not craftable (WRONG) - possible recipes:")

    local anyRecipeFound = false

    for researched_recipe_name, _ in pairs(researched_recipes) do
        local recipe_results = automatic_mod_tests.functions.convert_recipe_results(data.raw.recipe[researched_recipe_name], difficulty)

        if automatic_mod_tests.functions.tableFindValue(recipe_results.craftable_items, item_to_check) or automatic_mod_tests.functions.tableFindValue(recipe_results.craftable_fluids, item_to_check) then
            anyRecipeFound = true

            local ingredients = automatic_mod_tests.functions.convert_recipe_ingredients(data.raw.recipe[researched_recipe_name], difficulty)

            log(indent .. " - recipe '" .. researched_recipe_name .. "' ingredients:")
            for _, ingredient_name in pairs(ingredients.craftable_items) do
                automatic_mod_tests.functions.print_uncraftable_recipes_recurrent(ingredient_name, indent_level + 1, already_checked_items, researched_recipes, craftable_items, craftable_fluids, difficulty)
            end
            for _, ingredient_name in pairs(ingredients.craftable_fluids) do
                automatic_mod_tests.functions.print_uncraftable_recipes_recurrent(ingredient_name, indent_level + 1, already_checked_items, researched_recipes, craftable_items, craftable_fluids, difficulty)
            end
        end
    end

    if not anyRecipeFound then
        log (indent .. " - unable to find any researched recipe for '" .. item_to_check .. "'!")
    end
end

function automatic_mod_tests.functions.make_indent(indent_level)
    local indent = ""
    for _ = 1,indent_level do indent = indent .. "    " end
    return indent
end





-- -----------------------------------------------------------------------------
-- helper functions


function automatic_mod_tests.functions.is_item_craftable(craftable_items, item_name)
    if craftable_items[item_name] ~= nil then
        return true
    end
    return false
end

-- Note: use it only once initially. Later check craftable_items instead
function automatic_mod_tests.functions.is_entity_craftable(researched_recipes, craftable_items, item_name, is_beginning_of_game)
    if is_beginning_of_game then
        if researched_recipes[item_name] ~= nil then
            return true
        end
    else
        -- TODO: improve this check: find item which corresponds to the entity (because maybe they have different names?)
        if craftable_items[item_name] ~= nil then
            return true
        end
    end
    return false
end


function automatic_mod_tests.functions.convert_recipe_results(recipeObject, difficulty)
    local results = { craftable_items = {}, craftable_fluids = {}}
    local recipeObjectByDifficulty = {}

    if recipeObject[difficulty] ~= nil then
        recipeObjectByDifficulty = recipeObject[difficulty]
    else
        recipeObjectByDifficulty = recipeObject
    end

    if recipeObjectByDifficulty.results then
        for _,result in pairs(recipeObjectByDifficulty.results) do
            if result.name ~= nil then
                if result.type == nil or result.type == 'item' then
                    table.insert(results.craftable_items, result.name)
                elseif result.type == 'fluid' then
                    table.insert(results.craftable_fluids, result.name)
                end
            else
                table.insert(results.craftable_items, result[1])
            end
        end
        return results
    end

    if recipeObjectByDifficulty.result then
        table.insert(results.craftable_items, recipeObjectByDifficulty.result)
        return results
    end

    return results;
end

function automatic_mod_tests.functions.convert_recipe_ingredients(recipeObject, difficulty)
    local results = { craftable_items = {}, craftable_fluids = {}}
    local recipeObjectByDifficulty = {};

    if recipeObject[difficulty] ~= nil then
        recipeObjectByDifficulty = recipeObject[difficulty]
    else
        recipeObjectByDifficulty = recipeObject
    end

    if recipeObjectByDifficulty.ingredients then
        for _,result in pairs(recipeObjectByDifficulty.ingredients) do
            if result.name ~= nil then
                if result.type == nil or result.type == 'item' then
                    table.insert(results.craftable_items, result.name)
                elseif result.type == 'fluid' then
                    table.insert(results.craftable_fluids, result.name)
                end
            else
                table.insert(results.craftable_items, result[1])
            end
        end
        return results
    end

    return results
end


function automatic_mod_tests.functions.convert_technology_ingredients(ingredients)
    local results = {}

    for _,result in pairs(ingredients) do
        if result.name ~= nil then
            if result.type == nil or result.type == 'item' or result.type == 'tool' then
                table.insert(results, result.name)
            end
        else
            table.insert(results, result[1])
        end
    end
    return results
end


-- inspired by function bobmods.lib.item.get_type(name) from "bobliblary" mod by Bobingabout:
function automatic_mod_tests.functions.get_crafting_entity_type(entity_name)
    if type(entity_name) == "string" then
        local item_types = {
            "assembling-machine",
            "boiler",
            "furnace"
        }
        for i, type_name in pairs(item_types) do
            if data.raw[type_name][entity_name] ~= nil then return type_name end
        end
    end
    return nil
end



function automatic_mod_tests.functions.ternary(cond, T, F)
    -- function by user daurnimator from https://stackoverflow.com/questions/5525817/inline-conditions-in-lua-a-b-yes-no/5529577#5529577
    if cond then return T else return F end
end

function automatic_mod_tests.functions.tableFindValue(aTable, value)
    for _, v in pairs(aTable) do
        if (v == value) then
            return true
        end
    end
    return false
end

function automatic_mod_tests.functions.tableLength(myTable)
    -- function by user u0b34a0f6ae from https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table/2705804#2705804
    local count = 0
    for _ in pairs(myTable) do count = count + 1 end
    return count
end

function automatic_mod_tests.functions.isTableEmpty(myTable)
    -- function by user Norman Ramsey: https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries/1252776#1252776
    if next(myTable) == nil then
        return true
    end
    return false
end
