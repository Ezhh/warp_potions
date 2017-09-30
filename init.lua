
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
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			player:set_attribute("warp_point_"..number, minetest.pos_to_string(pos))
			minetest.set_node(pos, {name = "air"})
			return itemstack
		end
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


-- warp command

minetest.register_chatcommand("warp", {
	params = "<warp point>",
	description = "Teleport player to chosen warp point.",
	func = function(player_name, warp_point)
		local player = minetest.get_player_by_name(player_name)
		if minetest.string_to_pos(player:get_attribute("warp_point_"..warp_point)) == nil then
			minetest.chat_send_player(player_name,"Invalid or un-set warp point.") 
			return
		end

		local inv = player:get_inventory()
		if not inv:contains_item("main", ItemStack("warp_potions:potion_"..warp_point.." 1")) then
			minetest.chat_send_player(player_name,"You don't have the right potion!")
			return
		end

		inv:remove_item("main", ItemStack("warp_potions:potion_"..warp_point.." 1"))
		player:set_pos(minetest.string_to_pos(player:get_attribute("warp_point_"..warp_point)))
	end
})
