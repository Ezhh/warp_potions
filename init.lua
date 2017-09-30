
-- register potions

local potion_list = {
	{"1", },
	{"2", },
	{"3", },
	{"4", },
	{"5", },
	{"6", },
	{"7", },
	{"8", }
}

for i in ipairs(potion_list) do
	local number = potion_list[i][1]

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
end
