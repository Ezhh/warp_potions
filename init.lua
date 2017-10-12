
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
			if minetest.is_protected(pos, player:get_player_name()) then
				return
			end
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


-- check inventory

local m_ip = minetest.get_modpath('inventory_plus')
local m_ui = minetest.get_modpath('unified_inventory')


-- warp function

local function warp(player, warp_point)
	if minetest.string_to_pos(player:get_attribute("warp_point_"..warp_point)) == nil then
		minetest.chat_send_player(player:get_player_name(),"Invalid or un-set warp point.")
		return
	end

	local inv = minetest.get_inventory({type='detached', name=player:get_player_name().."_potion_inv"})
	if not inv:contains_item("potions", ItemStack("warp_potions:potion_"..warp_point.." 1")) then
		minetest.chat_send_player(player:get_player_name(),"You don't have the right potion!")
		return
	end

	inv:remove_item("potions", ItemStack("warp_potions:potion_"..warp_point.." 1"))
	local pos = minetest.string_to_pos(player:get_attribute("warp_point_"..warp_point))
	player:set_pos(pos)

	-- remove warp point if another player protected destination
	minetest.after(2, function(pos, player, warp_point) 
		if minetest.is_protected(pos, player:get_player_name()) then
			player:set_attribute("warp_point_"..warp_point, "")
			minetest.chat_send_player(player:get_player_name(), "Area is protected: Warp point lost!")
		end
	end, pos, player, warp_point)
end


-- inventory sort function

local function potion_inv_sort(player)
	local name = player:get_player_name()
	local p_inv = player:get_inventory()
	local w_inv = minetest.get_inventory({type="detached", name=name.."_potion_inv"})
	-- sort according to slot, returning any leftover. Stack max is 99
	for i=1,8 do
		-- check stack is in correct slot!
		local stack = w_inv:get_stack("potions", i)
		if not stack:is_empty() then -- catch error
			local index = tonumber(string.match(stack:get_name(),"%d"))
			if i ~= index then
				-- wrong slot, fix it!
				local dest = w_inv:get_stack("potions", index)
				local leftover = dest:add_item(stack)
				w_inv:set_stack("potions", i, {})
				w_inv:set_stack("potions", index, dest)
				p_inv:add_item("main", leftover)
			end
		end
	end
	p_inv:set_list("potions", w_inv:get_list("potions")) -- shadow changes
end


-- formspec function

local function get_formspec(name, part)
	local a, b, c

	a = 'size[8,9;]'..
		"label[0,0;Potion Inventory:]"

	b =  "list[detached:"..name.."_potion_inv;potions;1,1;1,1;0]" ..
		"list[detached:"..name.."_potion_inv;potions;3,1;1,1;2]" ..
		"list[detached:"..name.."_potion_inv;potions;5,1;1,1;4]" ..
		"list[detached:"..name.."_potion_inv;potions;7,1;1,1;6]" ..

		"list[detached:"..name.."_potion_inv;potions;1,2.5;1,1;1]" ..
		"list[detached:"..name.."_potion_inv;potions;3,2.5;1,1;3]" ..
		"list[detached:"..name.."_potion_inv;potions;5,2.5;1,1;5]" ..
		"list[detached:"..name.."_potion_inv;potions;7,2.5;1,1;7]" ..

		"button[0.2,1;1,1;1;Use]" ..
		"button[2.2,1;1,1;3;Use]" ..
		"button[4.2,1;1,1;5;Use]" ..
		"button[6.2,1;1,1;7;Use]" ..

		"button[0.2,2.5;1,1;2;Use]" ..
		"button[2.2,2.5;1,1;4;Use]" ..
		"button[4.2,2.5;1,1;6;Use]" ..
		"button[6.2,2.5;1,1;8;Use]"

	c = "list[current_player;main;0,5;8,4;]"

	if part then return b end
	return a..b..c
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


-- on join event

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	local name = player:get_player_name()
	-- create inventory
	local potion_inv = minetest.create_detached_inventory(name.."_potion_inv",{
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_put = function(inv, listname, index, stack, player)
			if string.find(stack:get_name(), "warp_potion") == nil then return 0 end
			return 99
		end,
		on_take = function(inv, listname, index, stack, player)
			local p_inv = player:get_inventory()
			p_inv:set_list("potions", inv:get_list("potions")) -- record state
		end,
		on_put = function(inv, listname, index, stack, player)
			minetest.after(0, potion_inv_sort, player)
		end
	}, player:get_player_name())
	-- initialise inventory
	local i_list = inv:get_lists()
	local p_list = potion_inv:get_lists()
	if p_list.potions == nil then
		potion_inv:set_size("potions", 4*2)
	end
	-- initialise copy
	if i_list.potions == nil then
		inv:set_size("potions", 4*2)
	else
		potion_inv:set_list("potions", inv:get_list("potions"))
	end
	-- inventory plus
	if m_ip then
		inventory_plus.register_button(player, "warp_potion", "Warp Potions")
	end
end)


-- test command, remove later

minetest.register_chatcommand("fs", {
	func = function(player_name, param)
		minetest.show_formspec(player_name,
		"warp_potions:potions_form", get_formspec(player_name))
	end
})


-- when pressing buttons

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- support inventory plus
	if m_ip then
		if fields.warp_potion then
			-- show formspec
			local formspec = get_formspec(player:get_player_name())
			formspec = formspec.."button[6,0.1;2,0.5;main;Back]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			inventory_plus.set_inventory_formspec(player, formspec)
			return
		end
	end

	if formname ~= "warp_potions:potions_form" and
	formname ~= "" then return end

	for i = 1, 8 do
		if fields[tostring(i)] then
			warp(player, tostring(i))
			return
		end
	end
end)


-- unified inventory button

if m_ui then
	unified_inventory.register_button('potions', {
		type = 'image',
		image = 'warp_potion_3.png',
		tooltip = 'Warp Potions'

	})
	unified_inventory.register_page("potions", {
		get_formspec = function(player, perplayer_formspec)
			local name = player:get_player_name()
			local fy = perplayer_formspec.formspec_y
			local formspec = "background[0.06,"..fy..";7.92,7.52;potion_inv_ui_form.png]"
			.."label[0,0;Warp Potions]"
			..get_formspec(name,true)
			return {formspec=formspec}
	end
})
end


-- sfinv

sfinv.register_page("potions", {
	title = "Potions",
	get = function(self, player, context)
		local name = player:get_player_name()
		return sfinv.make_formspec(player, context,
			"label[0,0;Warp Potions]" ..
			get_formspec(name, true),
			true)
	end
})
