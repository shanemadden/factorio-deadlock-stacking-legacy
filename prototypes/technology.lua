local DSB = require("prototypes.shared")

-- generate research by tier, only if base research exists
for i=1,DSB.TIERS do
	if data.raw.technology[DSB.BASE_RESEARCH[i]] then
		local recipe_effects = {
			{
			type = "unlock-recipe",
			recipe = "deadlock-beltbox-recipe-"..i,
			},
		}
		for _,recipe in pairs(DSB.ITEM_TIER[i]) do
			table.insert(recipe_effects,   
				{
				type = "unlock-recipe",
				recipe = DSB.RECIPE_PREFIX.."stack-"..recipe,
				}
			)
			table.insert(recipe_effects,   
				{
				type = "unlock-recipe",
				recipe = DSB.RECIPE_PREFIX.."unstack-"..recipe,
				}
			)
		end
		local research = table.deepcopy(data.raw.technology[DSB.BASE_RESEARCH[i]])
		research.effects = recipe_effects
		research.icon = "__DeadlockStacking__/graphics/deadlock-stacking.png"
		research.name = DSB.TECH_PREFIX..i
		research.unit.count = research.unit.count * 1.5
		research.prerequisites = DSB.PREREQS[i]
		research.upgrade = false
		data:extend({research})
	else
		debug("DSB: Skipping research tier "..i..", no base exists")
	end
end