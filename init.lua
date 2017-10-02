
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


-- warp function

local function warp(player, warp_point)
	if minetest.string_to_pos(player:get_attribute("warp_point_"..warp_point)) == nil then
		minetest.chat_send_player(player:get_player_name(),"Invalid or un-set warp point.") 
		return
	end

	local inv = player:get_inventory()
	if not inv:contains_item("potion_inv", ItemStack("warp_potions:potion_"..warp_point.." 1")) then
		minetest.chat_send_player(player:get_player_name(),"You don't have the right potion!")
		return
	end

	inv:remove_item("potion_inv", ItemStack("warp_potions:potion_"..warp_point.." 1"))
	player:set_pos(minetest.string_to_pos(player:get_attribute("warp_point_"..warp_point)))
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


-- on join check for inv

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	if inv:get_size("potion_inv") == 0 then
		inv:set_size("potion_inv", 8)
	end
end)


-- test command, remove later

minetest.register_chatcommand("fs", { 
	func = function(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		local inv = player:get_inventory()
		minetest.show_formspec(player_name, "warp_potions:potions_form",
			"size[8,10]" ..

			-- inventory slots
			"label[0,0;Potion Inventory:]" ..

			"list[current_player;potion_inv;1,1;1,1;0]" ..
			"list[current_player;potion_inv;3,1;1,1;1]" ..
			"list[current_player;potion_inv;5,1;1,1;2]" ..
			"list[current_player;potion_inv;7,1;1,1;3]" ..

			"list[current_player;potion_inv;1,2.5;1,1;4]" ..
			"list[current_player;potion_inv;3,2.5;1,1;5]" ..
			"list[current_player;potion_inv;5,2.5;1,1;6]" ..
			"list[current_player;potion_inv;7,2.5;1,1;7]" ..

			-- buttons
			"button[0.2,1;1,1;1;Use]" ..
			"button[2.2,1;1,1;3;Use]" ..
			"button[4.2,1;1,1;5;Use]" ..
			"button[6.2,1;1,1;7;Use]" ..

			"button[0.2,2.5;1,1;2;Use]" ..
			"button[2.2,2.5;1,1;4;Use]" ..
			"button[4.2,2.5;1,1;6;Use]" ..
			"button[6.2,2.5;1,1;8;Use]" ..

			"list[current_player;main;0,5;8,4;]")
	end
})


-- when pressing buttons

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "warp_potions:potions_form" then
		return
	end
	for i = 1, 8 do
		if fields[tostring(i)] then
			warp(player, tostring(i))
		end
	end	
end)