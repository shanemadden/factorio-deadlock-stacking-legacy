-- public-facing hooks
local DSB = require "prototypes.shared"

deadlock_stacking = {}

function deadlock_stacking.create_stack(item_name, graphic_path, target_tech, icon_size)
	DSB.debug("DSB: importing mod item: "..item_name)
	DSB.create_stacked_item(item_name, graphic_path, icon_size)
	DSB.create_stacking_recipes(item_name, icon_size)
	DSB.add_stacks_to_tech(item_name, target_tech)
end

function deadlock_stacking.create(item_name, graphic_path, target_tech, icon_size)
    deadlock_stacking.create_stack(item_name, graphic_path, target_tech, icon_size)
end

function deadlock_stacking.reset()
    for i=1,DSB.TIERS do
        local e = data.raw.technology[DSB.TECH_PREFIX..i].effects
        if e then 
            while e[2] do table.remove(e,2) end
        end
    end
    DSB.debug("DSB: Technologies cleared.")
end

function deadlock_stacking.remove(target_tech)
    for i=1,DSB.TIERS do
        local e = data.raw.technology[DSB.TECH_PREFIX..i].effects
        if e then 
            local j = 2
            while e[j] do
                if e[j].type == "unlock-recipe" and string.find(e[j].recipe, target_tech, 1, true) then
                    DSB.debug("DSB: Recipe "..e[j].recipe.." cleared.")
                    table.remove(e,j)
                else
                    j = j + 1
                end
            end
        end
    end
end
