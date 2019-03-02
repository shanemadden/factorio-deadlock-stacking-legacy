local DSB = require("prototypes.shared")

-- beltboxes
for i=1,DSB.TIERS do
	data:extend({
		{
			type = "item",
			name = "deadlock-beltbox-item-"..i,
			localised_name = {"entity-name."..DSB.LOCALISATION_PREFIX.."-beltbox-"..i},
			localised_description = {"entity-description.deadlock-beltbox"},
			icons = {
				{ icon = "__DeadlockStacking__/graphics/beltbox-icon-base.png" },
				{ icon = "__DeadlockStacking__/graphics/beltbox-icon-mask.png", tint = DSB.TIER_COLOURS[i] },
			},
			icon_size = 32,
			stack_size = 50,
			flags = {},
			place_result = "deadlock-beltbox-entity-"..i,
			group = "logistics",
			subgroup = "beltboxes",
			order = string.char(97+i),
		}
	})
end

-- generate vanilla stacked items
for i,item in pairs(DSB.ITEM_LIST) do
	if DSB.ITEMS_WITH_ICONS[item] then
		DSB.create_stacked_item(item, "__DeadlockStacking__/graphics/stacked-"..item..".png")
	else
		DSB.create_stacked_item(item)
	end
end