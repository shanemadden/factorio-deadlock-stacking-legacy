-- data and functions used across the mod
local DSB = {}

-- print to log for non-errors
DSB.LOGGING = false
function DSB.debug(message)
	if DSB.LOGGING then log(message) end
end

-- "contents" of a stacked item. don't change this, bad stuff happens
DSB.STACK_SIZE = 5

-- base time for stacking recipes at machine speed 1 to perfectly compress a red belt
DSB.CRAFT_TIME = 3*DSB.STACK_SIZE/80

-- menu order for items which are auto-generated and with hidden recipes
DSB.GLOBAL_ORDER = 0

-- tiers
DSB.TIERS = 3
DSB.TIER_COLOURS = {
	[1] = {r=225,g=165,b=10},
	[2] = {r=225,g=25,b=10},
	[3] = {r=10,g=165,b=225}
}
DSB.PREREQS = {
	[1] = {"logistics", "electronics"},
	[2] = {"logistics-2", "deadlock-stacking-1"},
	[3] = {"logistics-3", "deadlock-stacking-2"},
}
DSB.BASE_RESEARCH = {
	[1] = "logistics",
	[2] = "logistics-2",
	[3] = "logistics-3",
}
DSB.BELTS = {
    [1] = "transport-belt",
    [2] = "fast-transport-belt",
    [3] = "express-transport-belt",
}
DSB.LOCALISATION_PREFIX = "deadlock"

if mods["xander-mod"] then
	DSB.TIER_COLOURS[3] = {r=10,g=225,b=25,a=255}
	DSB.TIER_COLOURS[4] = {r=10,g=165,b=225,a=255}
	DSB.BELTS[3] = "expedited-transport-belt"
	DSB.BELTS[4] = "express-transport-belt"
	DSB.PREREQS[4] = {"logistics-4", "deadlock-stacking-3"}
	DSB.BASE_RESEARCH[4] = "logistics-4"
	DSB.TIERS = 4
    DSB.LOCALISATION_PREFIX = "xander"
elseif mods["boblogistics"] then 
	DSB.TIER_COLOURS[4] = {r=165,g=10,b=225}
	DSB.TIER_COLOURS[5] = {r=10,g=225,b=25}
	DSB.PREREQS[4] = {"bob-logistics-4", "deadlock-stacking-3"}
	DSB.PREREQS[5] = {"bob-logistics-5", "deadlock-stacking-4"}
	DSB.BASE_RESEARCH[4] = "bob-logistics-4"
	DSB.BASE_RESEARCH[5] = "bob-logistics-5"
	DSB.BELTS[4] = "turbo-transport-belt"
	DSB.BELTS[5] = "ultimate-transport-belt"
	DSB.TIERS = 5
    DSB.LOCALISATION_PREFIX = "bob"
elseif mods["FactorioExtended-Transport"] then 
	DSB.TIER_COLOURS[4] = {r=10,g=225,b=25}
	DSB.TIER_COLOURS[5] = {r=10,g=25,b=225}
	DSB.PREREQS[4] = {"logistics-4", "deadlock-stacking-3"}
	DSB.PREREQS[5] = {"logistics-5", "deadlock-stacking-4"}
	DSB.BASE_RESEARCH[4] = "logistics-4"
	DSB.BASE_RESEARCH[5] = "logistics-5"
	DSB.BELTS[4] = "blistering-transport-belt"
	DSB.BELTS[5] = "furious-transport-belt"
	DSB.TIERS = 5
    DSB.LOCALISATION_PREFIX = "fextended"
elseif mods["FactorioExtended-Plus-Transport"] then 
	DSB.TIER_COLOURS[4] = {r=10,g=225,b=25}
	DSB.TIER_COLOURS[5] = {r=225,g=25,b=225}
	DSB.PREREQS[4] = {"logistics-4", "deadlock-stacking-3"}
	DSB.PREREQS[5] = {"logistics-5", "deadlock-stacking-4"}
	DSB.BASE_RESEARCH[4] = "logistics-4"
	DSB.BASE_RESEARCH[5] = "logistics-5"
	DSB.BELTS[4] = "rapid-transport-belt-mk1"
	DSB.BELTS[5] = "rapid-transport-belt-mk2"
	DSB.TIERS = 5
    DSB.LOCALISATION_PREFIX = "fextendedplus"
end

-- box speeds
DSB.SPEEDS = {}
for i=1,DSB.TIERS do
    DSB.SPEEDS[i] = data.raw["transport-belt"][DSB.BELTS[i]].speed * 16
end

-- internal name prefixes
DSB.ITEM_PREFIX = "deadlock-stack-"
DSB.RECIPE_PREFIX = "deadlock-stacks-"
DSB.TECH_PREFIX = "deadlock-stacking-"

-- what vanilla items are stackable, and which research tier are they in
DSB.ITEM_TIER = {
	[1] = { "raw-wood", "iron-ore", "copper-ore", "stone", "coal", "iron-plate", "copper-plate", "steel-plate", "stone-brick" },
	[2] = { "copper-cable", "iron-gear-wheel", "iron-stick", "sulfur", "plastic-bar", "solid-fuel", "electronic-circuit", "advanced-circuit" },
	[3] = { "processing-unit", "battery", "uranium-ore", "uranium-235", "uranium-238" },
	[4] = {}, -- not used without other mods
	[5] = {}, -- not used without other mods
}

-- the above in one long list
DSB.ITEM_LIST = {}
for i=1,DSB.TIERS do
	for i,v in pairs(DSB.ITEM_TIER[i]) do table.insert(DSB.ITEM_LIST,v) end
end

-- use custom sprites for these vanilla items
local icons = {
	"iron-plate",
	"copper-plate",
	"steel-plate",
	"stone-brick",
	"plastic-bar",
	"copper-cable",
	"iron-gear-wheel",
	"electronic-circuit",
	"advanced-circuit",
	"processing-unit",
	"raw-wood",
	"solid-fuel",
	"iron-ore",
	"copper-ore",
	"stone",
	"coal",
	"uranium-ore",
	"uranium-235",
	"uranium-238",
	"battery",
	"iron-stick",
	"sulfur",
}
DSB.ITEMS_WITH_ICONS = {}
for _,v in pairs(icons) do
	DSB.ITEMS_WITH_ICONS[v] = true
end

-- get the crafting tab group an item is in
function DSB.get_group(item)
    local g = data.raw["item-group"][data.raw["item-subgroup"][data.raw.item[item].subgroup].group].name
    if not g then g = "intermediate-products" end
    return g
end

-- make a new stacked item
function DSB.create_stacked_item(item_name, graphic_path, icon_size)
	if not data.raw.item[item_name] then
		log("ERROR: DSB asked to create stacks from a non-existent item ("..item_name..")")
		return
	end
    if icon_size and (icon_size ~= 32 and icon_size ~= 64 and icon_size ~= 128) then
		log("ERROR: DSB asked to use icon_size that is not 32, 64 or 128 ("..item-name..", icon size "..icon_size..")")
		return
    end
    if not icon_size then icon_size = 32 end
	local temp_icons, stacked_icons, this_fuel_category, this_fuel_acceleration_multiplier, this_fuel_top_speed_multiplier, this_fuel_value, this_fuel_emissions_multiplier
	if graphic_path then
		stacked_icons = { { icon = graphic_path, icon_size = icon_size } }
	else
		if data.raw.item[item_name].icon then
			temp_icons = { { icon = data.raw.item[item_name].icon, icon_size = icon_size } }
			log("WARNING: DSB creating layered stack icon ("..item_name.."), this is 4x more rendering effort than a custom icon")
		elseif data.raw.item[item_name].icons then
			temp_icons = data.raw.item[item_name].icons
			log("WARNING: DSB creating layers-of-layers stack icon ("..item_name.."), this is "..1+(#temp_icons*3).."x more rendering effort than a custom icon!")
		else
			log("ERROR: DSB asked to create stacks for item with no icon properties ("..item_name..")")
			return
		end
		stacked_icons = { { icon = "__DeadlockStacking__/graphics/blank.png", scale = 1, icon_size = 32 } }
		for i = 1, -1, -1 do
			for _,layer in pairs(temp_icons) do
				layer.shift = {0, i*3}
				layer.scale = 0.85 * 32/icon_size
                layer.icon_size = icon_size
				table.insert(stacked_icons, table.deepcopy(layer))
			end
		end
	end
	if data.raw.item[item_name].fuel_value then
		this_fuel_category = data.raw.item[item_name].fuel_category
		this_fuel_acceleration_multiplier = data.raw.item[item_name].fuel_acceleration_multiplier
		this_fuel_top_speed_multiplier = data.raw.item[item_name].fuel_top_speed_multiplier
		this_fuel_emissions_multiplier = data.raw.item[item_name].fuel_emissions_multiplier
		-- great, the fuel value is a string, with SI units. how very easy to work with
		this_fuel_value = (tonumber(string.match(data.raw.item[item_name].fuel_value, "%d+")) * DSB.STACK_SIZE) .. string.match(data.raw.item[item_name].fuel_value, "%a+")
	end
	local menu_order = string.format("%03d",DSB.GLOBAL_ORDER)
	DSB.GLOBAL_ORDER = DSB.GLOBAL_ORDER + 1
	data:extend({
		{
			type = "item",
			name = DSB.ITEM_PREFIX..item_name,
			localised_name = {"item-name.deadlock-stacking-stack", {"item-name."..item_name}, DSB.STACK_SIZE},
			icons = stacked_icons,
            icon_size = icon_size, 
			stack_size = math.floor(data.raw.item[item_name].stack_size/DSB.STACK_SIZE),
			flags = {},
			subgroup = "stacks-"..DSB.get_group(item_name),
			order = menu_order,
			allow_decomposition = false,
			fuel_category = this_fuel_category,
			fuel_acceleration_multiplier = this_fuel_acceleration_multiplier,
			fuel_top_speed_multiplier = this_fuel_top_speed_multiplier,
			fuel_emissions_multiplier = this_fuel_emissions_multiplier,
			fuel_value = this_fuel_value,
		}
	})
	DSB.debug("DSB: Created stacked item: "..item_name)
end

-- make stacking/unstacking recipes for a base item
function DSB.create_stacking_recipes(item_name, icon_size)
	if not data.raw.item[item_name] then
		log("ERROR: DSB asked to create recipes from a non-existent item ("..item_name..")")
		return
	end
	if not data.raw.item[DSB.ITEM_PREFIX..item_name] then
		log("ERROR: DSB asked to create recipes from a non-existent stacked item ("..DSB.ITEM_PREFIX..item_name..")")
		return
	end
    if icon_size and (icon_size ~= 32 and icon_size ~= 64 and icon_size ~= 128) then
		log("ERROR: DSB asked to use icon_size that is not 32, 64 or 128 ("..item_name..")")
		return
    end
    if not icon_size then icon_size = 32 end
	-- icon prep
	local menu_order = string.format("%03d",DSB.GLOBAL_ORDER)
	DSB.GLOBAL_ORDER = DSB.GLOBAL_ORDER + 1
	local base_icon = data.raw.item[DSB.ITEM_PREFIX..item_name].icon
	local base_icons = data.raw.item[DSB.ITEM_PREFIX..item_name].icons
	if not base_icons then
		base_icons = { { icon = base_icon } }
	end
	local temp_icons = table.deepcopy(base_icons)
	table.insert(temp_icons, 
		{
			icon = "__DeadlockStacking__/graphics/arrow-d-"..icon_size..".png",
            scale = 0.5 * 32 / icon_size,
            icon_size = icon_size,
		}
	)
	-- stacking
	if not data.raw.recipe[DSB.RECIPE_PREFIX.."stack-"..item_name] then
		data:extend({
			{
			type = "recipe",
			name = DSB.RECIPE_PREFIX.."stack-"..item_name,
			localised_name = {"recipe-name.deadlock-stacking-stack", {"item-name."..item_name}},
			category = "stacking",
			group = "intermediate-products",
			subgroup = data.raw.item[DSB.ITEM_PREFIX..item_name].subgroup,
			order = menu_order.."[a]",
			enabled = false,
			allow_decomposition = false,
			ingredients = { {item_name, DSB.STACK_SIZE} },
			result = DSB.ITEM_PREFIX..item_name,
			result_count = 1,
			energy_required = DSB.CRAFT_TIME,
			icons = temp_icons,
	        icon_size = icon_size, 
			hidden = true,
			allow_as_intermediate = false,
	        hide_from_stats = true,
			},
		})
	end
	-- unstacking
	temp_icons = table.deepcopy(base_icons)
	table.insert(temp_icons, 
		{
			icon = "__DeadlockStacking__/graphics/arrow-u-"..icon_size..".png",
            scale = 0.5 * 32 / icon_size
		}
	)
	if not data.raw.recipe[DSB.RECIPE_PREFIX.."unstack-"..item_name] then
	    local hidden = settings.startup["deadlock-stacking-hide-unstacking"].value
		data:extend({
			{
			type = "recipe",
			name = DSB.RECIPE_PREFIX.."unstack-"..item_name,
			localised_name = {"recipe-name.deadlock-stacking-unstack", {"item-name."..item_name}},
			category = "unstacking",
			group = "intermediate-products",
			subgroup = data.raw.item[DSB.ITEM_PREFIX..item_name].subgroup,
			order = menu_order.."[b]",
			enabled = false,
			allow_decomposition = false,
			ingredients = { {DSB.ITEM_PREFIX..item_name, 1} },
			result = item_name,
			result_count = DSB.STACK_SIZE,
			energy_required = DSB.CRAFT_TIME,
			icons = temp_icons,
	        icon_size = icon_size, 
			hidden = hidden,
			allow_as_intermediate = false,
	        hide_from_stats = true,
			},
		})
	end
	DSB.debug("DSB: Created recipes: "..item_name)
end

-- make the stacking recipes depend on a technology
function DSB.add_stacks_to_tech(item_name, target_technology)
	if not target_technology then
		DSB.debug("DSB: Skipping technology insert, no tech specified ("..item_name..")")
		return
	end
	if not data.raw.recipe[DSB.RECIPE_PREFIX.."stack-"..item_name] then
		log("ERROR: DSB asked to use non-existent stacking recipe ("..item_name..")")
		return
	end
	if not data.raw.recipe[DSB.RECIPE_PREFIX.."unstack-"..item_name] then
		log("ERROR: DSB asked to use non-existent unstacking recipe ("..item_name..")")
		return
	end
	if not data.raw.technology[target_technology] then
		log("ERROR: DSB asked to use non-existent technology ("..target_technology..")")
		return
	end
	-- request by orzelek - remove previous recipe unlocks if we're re-adding something that was changed by another mod
    if data.raw.technology[target_technology].effects then
        local neweffects = {}
        for _,effect in ipairs(data.raw.technology[target_technology].effects) do
            if effect.recipe then
                if (effect.recipe ~= DSB.RECIPE_PREFIX.."stack-"..item_name) and (effect.recipe ~= DSB.RECIPE_PREFIX.."unstack-"..item_name) then
                    table.insert(neweffects, effect)
                else
                    DSB.debug("DSB: Removed previous recipe unlock ("..item_name..")")
                end
            end
        end
        data.raw.technology[target_technology].effects = table.deepcopy(neweffects)
    end
	-- insert stacking recipe
	table.insert(data.raw.technology[target_technology].effects,
		{
		type = "unlock-recipe",
		recipe = DSB.RECIPE_PREFIX.."stack-"..item_name,
		}
	)
	-- insert unstacking recipe
	table.insert(data.raw.technology[target_technology].effects,
		{
		type = "unlock-recipe",
		recipe = DSB.RECIPE_PREFIX.."unstack-"..item_name,
		}
	)
	DSB.debug("DSB: Modified technology: "..target_technology)
end

return DSB
