local DSB = require("prototypes.shared")

-- the beltbox entity
for i=1,DSB.TIERS do
	data:extend({
		{
		type = "furnace",
		name = "deadlock-beltbox-entity-"..i,
		localised_name = {"entity-name."..DSB.LOCALISATION_PREFIX.."-beltbox-"..i},
        localised_description = {"entity-description.deadlock-beltbox"},
		icons = data.raw["item"]["deadlock-beltbox-item-"..i].icons,
		icon_size = 32,
		order = "a",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		fast_replaceable_group = "transport-belt",
		animation = {
			layers = {
				{
				draw_as_shadow = true,
				hr_version = {
					draw_as_shadow = true,
					filename = "__DeadlockStacking__/graphics/hr-beltbox-shadow.png",
					frame_count = 8,
					animation_speed = 1/i*2,
					height = 64,
					priority = "high",
					scale = 0.5,
					shift = {0.25, 0},
					width = 64
				},
				filename = "__DeadlockStacking__/graphics/lr-beltbox-shadow.png",
				frame_count = 8,
				animation_speed = 1/i*2,
				height = 32,
				priority = "high",
				scale = 1,
				shift = {0.25, 0},
				width = 32	
				},
				{
				hr_version = {
					filename = "__DeadlockStacking__/graphics/hr-beltbox-base.png",
					frame_count = 8,
					animation_speed = 1/i*2,
					height = 64,
					width = 64,
					priority = "extra-high",
					scale = 0.5,
				},
				filename = "__DeadlockStacking__/graphics/lr-beltbox-base.png",
				frame_count = 8,
				animation_speed = 1/i*2,
				height = 32,
				width = 32,
				priority = "extra-high",
				scale = 1,
				},
				{
				hr_version = {
					filename = "__DeadlockStacking__/graphics/hr-beltbox-mask.png",
					frame_count = 8,
					animation_speed = 1/i*2,
					height = 64,
					width = 64,
					priority = "high",
					scale = 0.5,
					tint = DSB.TIER_COLOURS[i],
				},
				filename = "__DeadlockStacking__/graphics/lr-beltbox-mask.png",
				frame_count = 8,
				animation_speed = 1/i*2,
				height = 32,
				width = 32,
				priority = "high",
				scale = 1,
				tint = DSB.TIER_COLOURS[i],
				},
			},
		},
		dying_explosion = "explosion",
		corpse = "small-remnants",
		minable = {hardness = 0.2, mining_time = 0.5, result = "deadlock-beltbox-item-"..i},
		module_specification = { module_slots = 0, module_info_icon_shift = {0,0.25} },
		allowed_effects = { "consumption" },
		max_health = 180,
		corpse = "small-remnants",
		collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		result_inventory_size = 1,
		source_inventory_size = 1,
		crafting_categories = {"stacking", "unstacking"},
		crafting_speed = DSB.SPEEDS[i],
		energy_source = {
			type = "electric",
			emissions = ((0.01)-((0.009/DSB.TIERS)*i))/DSB.SPEEDS[i],
			usage_priority = "secondary-input",
			drain = "15kW",
		},
		energy_usage = i*90 .. "kW",
		resistances = {
			{
			type = "fire",
			percent = 50
			},
		},
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 1.0 },	
		working_sound = {
			match_speed_to_activity = true,
			idle_sound = {
			  filename = "__base__/sound/idle1.ogg",
			  volume = 0.6
			},
			sound = {
			  filename = "__DeadlockStacking__/sounds/fan.ogg",
			  volume = 1.0
			},
			max_sounds_per_type = 3,
		},
		}
	})
end