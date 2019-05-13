local DSB = require("prototypes.shared")

-- crafting categories
data:extend({
	{
	type = "recipe-category",
	name = "stacking",
	},
	{
	type = "recipe-category",
	name = "unstacking",
	},
})

-- as of 0.16.22 we can disallow recipes being used in intermediates and re-allow player unstacking 
table.insert(data.raw["character"]["character"].crafting_categories,"unstacking")

-- crafting tab groups
data:extend({
	{
	type = "item-subgroup",
	name = "beltboxes",
	group = "logistics",
	order = "bb",
	},
})
-- make a subgroup at the bottom of each crafting tab
for _,group in pairs(data.raw["item-group"]) do
    data:extend({
        {
        type = "item-subgroup",
        name = "stacks-"..group.name,
        group = group.name,
        order = "zzzzz",
        },
    })
end
    
-- beltbox recipe ingredients per tier
local prereq_item1 = {
	[1] = {"transport-belt",4},
	[2] = {"deadlock-beltbox-item-1",1},
	[3] = {"deadlock-beltbox-item-2",1},
	[4] = {"deadlock-beltbox-item-3",1},
	[5] = {"deadlock-beltbox-item-4",1},
}
local prereq_item2 = {
	[1] = {"electronic-circuit",4},
	[2] = {"advanced-circuit",2},
	[3] = {amount = 100, name = "lubricant", type = "fluid"},
	[4] = {"processing-unit",5},
	[5] = {"processing-unit",20},
}
local crafting_category = {
	[1] = "crafting",
	[2] = "crafting",
	[3] = "crafting-with-fluid",
	[4] = "crafting",
	[5] = "crafting",
}

-- beltbox recipes
for i=1,DSB.TIERS do
	data:extend({
		{
		type = "recipe",
		name = "deadlock-beltbox-recipe-"..i,
		localised_name = {"entity-name."..DSB.LOCALISATION_PREFIX.."-beltbox-"..i},
        localised_description = {"entity-description.deadlock-beltbox"},
		category = crafting_category[i],
		group = "logistics",
		subgroup = "beltboxes",
		order = string.char(97+i),
		enabled = false,
		ingredients = {
		 prereq_item1[i],
		 {"iron-plate",i*10},
		 {"iron-gear-wheel",i*10},
		 prereq_item2[i],
		},
		result = "deadlock-beltbox-item-"..i,
		energy_required = 3.0,
		},
	})
end

-- move vanilla loaders to the same group as beltboxes, for menu tidiness
for i,v in ipairs({"loader","fast-loader","express-loader"}) do
	data.raw.recipe[v].subgroup = "beltboxes"
	data.raw.recipe[v].order = "z"..i
	data.raw.item[v].subgroup = "beltboxes"
	data.raw.item[v].order = "z"..i
end

-- generate vanilla stacked item recipes
for _,item in pairs(DSB.ITEM_LIST) do
	DSB.create_stacking_recipes(item)
end
