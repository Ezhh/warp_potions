
-- register potions

local potion_list = {
	{"1", "group:leaves"},
	{"2", "default:coal_lump"},
	{"3", "group:flower"},
	{"4", "default:copper_lump"},
	{"5", "default:cactus"},
	{"6", "default:mese_crystal"},
	{"7", "default:diamond"},
	{"8", "default:obsidian"}
}

for i in ipairs(potion_list) do
	local number = potion_list[i][1]
	local ingredient = potion_list[i][2]

	minetest.register_node("warp_potions:potion_"..number, {
		description = "Warp Potion "..number,
		drawtype = "plantlike",
		tiles = {"warp_potion_"..number..".png"},
		visual_scale = 0.8,
		selection_box = {
			type = "fixed",
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
		},
		paramtype = "light",
		groups = {oddly_breakable_by_hand = 3, attached_node = 1},
		walkable = false,
	})

	minetest.register_craft({
		output = "warp_potions:potion_"..number.." 1",
		recipe = {
			{ingredient, "", ingredient},
			{"", "vessels:glass_bottle", ""},
			{ingredient, "", ingredient}
		}
	})
end
