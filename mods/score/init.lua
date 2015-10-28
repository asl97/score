
--
-- Content
--

local LEVEL_EXTENT = 300
local LEVEL_MAX = 100
for level = 1, LEVEL_MAX do

	local image
	if level % 2 == 1 then
		image = 1
	else
		image = 2
	end

	minetest.register_node("score:stone_" .. level, {
		description = "Stone Level " .. level,
		tiles = { "score_stone_" .. image .. ".png" },
		groups = { stone = level },
		light_source = 1,
		sounds = {
			footstep = { name = "score_footstep", gain = 1.0 },
			place = { name=" score_place ", gain = 1.0 },
			dig = { name="score_dig", gain = 0.5 },
		},
	})

	minetest.register_node("score:iron_" .. level, {
		description = "Iron Level " .. level,
		tiles = { "score_stone_" .. image .. ".png^score_iron.png" },
		groups = { stone = level + 1 },
		light_source = 1,
		sounds = {
			footstep = { name = "score_footstep", gain = 1.0 },
			place = { name=" score_place ", gain = 1.0 },
			dig = { name="score_dig", gain = 0.5 },
		},
	})

	minetest.register_ore({
		ore_type = "scatter",
		ore = "score:iron_" .. level,
		wherein = "score:stone_" .. level,
		clust_scarcity = 8 * 8 * 8,
		clust_num_ores = 5,
		clust_size = 3,
	})

	minetest.register_node("score:coal_" .. level, {
		description = "Coal Level " .. level,
		tiles = { "score_stone_" .. image .. ".png^score_coal.png" },
		groups = { stone = level + 1 },
		light_source = 1,
		sounds = {
			footstep = { name = "score_footstep", gain = 1.0 },
			place = { name=" score_place ", gain = 1.0 },
			dig = { name="score_dig", gain = 0.5 },
		},
	})

	minetest.register_ore({
		ore_type = "scatter",
		ore = "score:coal_" .. level,
		wherein = "score:stone_" .. level,
		clust_scarcity = 8 * 8 * 8,
		clust_num_ores = 8,
		clust_size = 4,
	})

	minetest.register_node("score:score_ore_" .. level, {
		tiles = { "score_stone_" .. image .. ".png^score_score.png" },
		groups = { stone = level + 1 },
		drop = "score:score " .. level,
		light_source = 1,
		sounds = {
			footstep = { name = "score_footstep", gain = 1.0 },
			place = { name=" score_place ", gain = 1.0 },
			dig = { name="score_dig", gain = 0.5 },
		},
	})

	minetest.register_ore({
		ore_type = "scatter",
		ore = "score:score_ore_" .. level,
		wherein = "score:stone_" .. level,
		clust_scarcity = 12 * 12 * 12,
		clust_num_ores = 1,
		clust_size = 1,
	})

	local pick_capabilities = {
		groupcaps = {
			stone = { times = {}, uses = 0 },
		},
	}

	for i = 1, level do
		pick_capabilities.groupcaps.stone.times[i] = math.max(0.6 ^ (level - i), 0.2)
	end
	pick_capabilities.groupcaps.stone.times[level + 1] = 1.0

	minetest.register_tool("score:pick_" .. level, {
		description = "Pick Level " .. level,
		inventory_image = "score_pick_" .. image .. ".png",
		tool_capabilities = pick_capabilities,
		on_drop = function(itemstack, dropper, pos)
			return itemstack
		end,
	})

end

minetest.register_node("score:light", {
	description = "Light",
	tiles = { "score_light.png" },
	groups = { dig_immediate = 3 },
	light_source = 15,
	sounds = {
		footstep = { name = "score_footstep", gain = 1.0 },
		place = { name=" score_dig ", gain = 0.5 },
		dug = { name="score_dig", gain = 0.5 },
	},
	on_drop = function(itemstack, dropper, pos)
		return itemstack
	end,
})

minetest.register_craftitem("score:score", {
	description = "Score",
})

minetest.register_tool(":", {
	type = "none",
	wield_image = "hand.png",
	wield_scale = {x=1,y=1,z=1.5},
	range = 4,
})

--
-- Player
--

local INV_PICK_INDEX = 1
local INV_LIGHT_INDEX = 2
local INV_SIZE = 2

local inventories = {
	--[[
	playername = {
		itemname = count,
	},
	]]
}

local function save_inventories()
	local file = io.open(minetest.get_worldpath() .. "/score_inventory", "w")
	if not file then
		minetest.log("error", "Can't save inventories")
		return
	end
	file:write(minetest.serialize(inventories))
	file:close()
end

local function load_inventories()
	local file = io.open(minetest.get_worldpath() .. "/score_inventory", "r")
	if not file then
		minetest.log("error", "Can't load inventories")
		return
	end
	inventories = minetest.deserialize(file:read("*all"))
	file:close()
end

local function get_level(player)
	local hud_inv = player:get_inventory()
	local pick = hud_inv:get_stack("main", INV_PICK_INDEX)
	local current_level = math.min(tonumber(pick:get_name():match("^score:pick_([%d]+)$")) or 1, LEVEL_MAX)
	return current_level
end

local function get_pick_cost(level)
	local cost = {}
	cost["score:iron_" .. level] = math.ceil(45 * 1.1 ^ (level - 1))
	return cost
end

local function get_light_cost(level)
	local cost = {}
	for i = level - 1, level do
		if i > 0 then
			cost["score:coal_" .. i] = math.ceil((50 + 5 * level) * 1.5 ^ (level - i))
		end
	end
	return cost
end

local function update_formspec(player, not_enough_resources)
	local inv = inventories[player:get_player_name()]
	local hud_inv = player:get_inventory()

	local formspec = "size[5,7]"
	formspec = formspec .. "tableoptions[background=#00000000;border=false;highlight=#00000000]"
	formspec = formspec .. "tablecolumns[text;text]"
	formspec = formspec .. "table[0,0;5,5;;"

	local pick = hud_inv:get_stack("main", INV_PICK_INDEX)
	local light = hud_inv:get_stack("main", INV_LIGHT_INDEX)
	formspec = formspec .. pick:get_definition().description .. ",1,"
	formspec = formspec .. light:get_definition().description .. "," .. light:get_count() .. ","

	local lines = {}
	for itemname,count in pairs(inv) do
		table.insert(lines, {
			minetest.formspec_escape(minetest.registered_items[itemname].description),
			count,
		})
	end

	table.sort(lines, function(a, b)
		if b[1] == "Score" then
			return false
		end
		if a[1] == "Score" then
			return true
		end
		local a_level = tonumber(a[1]:match(".* Level ([%d]+)$"))
		local b_level = tonumber(b[1]:match(".* Level ([%d]+)$"))
		if not a_level or not b_level or a_level == b_level then
			return a[1] < b[1]
		end
		return a_level > b_level
	end)

	for _,line in ipairs(lines) do
		formspec = formspec .. line[1] .. "," .. line[2] .. ","
	end

	-- remove trailing comma
	if formspec:match(",$") then
		formspec = formspec:sub(1, -2)
	end

	formspec = formspec .. ";0]"

	formspec = formspec .. "button[0,5;2,1;btn_upgrade;Upgrade Pick]"
	formspec = formspec .. "tableoptions[background=#00000000;border=false;highlight=#00000000]"
	formspec = formspec .. "tablecolumns[color;text;text]"
	if not_enough_resources == "pick" then
		formspec = formspec .. "table[2,5;3,1;;#FF0000,Requires:,,"
	else
		formspec = formspec .. "table[2,5;3,1;;,Requires:,,"
	end
	local pick_cost = get_pick_cost(get_level(player))
	for item, required in pairs(pick_cost) do
		local name = minetest.registered_items[item].description
		formspec = formspec .. "," .. name .. "," .. required .. ","
	end
	-- remove trailing comma
	if formspec:match(",$") then
		formspec = formspec:sub(1, -2)
	end
	formspec = formspec .. ";0]"

	formspec = formspec .. "button[0,6;2,1;btn_light;Craft Light]"
	formspec = formspec .. "tableoptions[background=#00000000;border=false;highlight=#00000000]"
	formspec = formspec .. "tablecolumns[color;text;text]"
	if not_enough_resources == "light" then
		formspec = formspec .. "table[2,6;3,1;;#FF0000,Requires:,,"
	else
		formspec = formspec .. "table[2,6;3,1;;,Requires:,,"
	end
	local light_cost = get_light_cost(get_level(player))
	for item, required in pairs(light_cost) do
		local name = minetest.registered_items[item].description
		formspec = formspec .. "," .. name .. "," .. required .. ","
	end
	-- remove trailing comma
	if formspec:match(",$") then
		formspec = formspec:sub(1, -2)
	end
	formspec = formspec .. ";0]"

	if formspec ~= player:get_inventory_formspec() then
		player:set_inventory_formspec(formspec)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields["btn_upgrade"] then
		local inv = inventories[player:get_player_name()]
		local hud_inv = player:get_inventory()

		local current_level = get_level(player)

		local pick_cost = get_pick_cost(current_level)
		for item, required in pairs(pick_cost) do
			if not inv[item] or inv[item] < required then
				update_formspec(player, "pick")
				return true
			end
		end
		for item, required in pairs(pick_cost) do
			inv[item] = inv[item] - required
		end

		hud_inv:set_stack("main", INV_PICK_INDEX, ItemStack("score:pick_" .. (current_level + 1)))

		update_formspec(player)
		return true
	end

	if fields["btn_light"] then
		local inv = inventories[player:get_player_name()]
		local hud_inv = player:get_inventory()

		local current_level = get_level(player)
		local light_cost = get_light_cost(current_level)
		for item, required in pairs(light_cost) do
			if not inv[item] or inv[item] < required then
				update_formspec(player, "light")
				return true
			end
		end
		for item, required in pairs(light_cost) do
			inv[item] = inv[item] - required
		end

		local light = hud_inv:get_stack("main", INV_LIGHT_INDEX)
		light:add_item(ItemStack("score:light"))
		hud_inv:set_stack("main", INV_LIGHT_INDEX, light)

		update_formspec(player)
		return true
	end

	if fields["quit"] then
		update_formspec(player)
	end
end)

minetest.register_on_joinplayer(function(player)
	player:set_properties({ textures = {} })
	player:set_sky("0x000000", "plain", {})
	player:hud_set_hotbar_itemcount(INV_SIZE)
	
	local hud_inv = player:get_inventory()
	hud_inv:set_size("main", INV_SIZE)
	if not hud_inv:get_stack("main", INV_PICK_INDEX):get_name():match("^score:pick_") or
			hud_inv:get_stack("main", INV_LIGHT_INDEX):get_name() ~= "score:light" then
		hud_inv:set_stack("main", INV_PICK_INDEX, ItemStack("score:pick_1"))
		hud_inv:set_stack("main", INV_LIGHT_INDEX, ItemStack("score:light 10"))
	end

	local inv = inventories[player:get_player_name()]
	if not inv then
		inventories[player:get_player_name()] = {
			["score:score"] = 0
		}
	end

	update_formspec(player)
end)

minetest.handle_node_drops = function(pos, drops, player)
	for _, dropped_item in ipairs(drops) do
		dropped_item = ItemStack(dropped_item)
		local item_name = dropped_item:get_name()
		if item_name == "score:light" then
			local hud_inv = player:get_inventory()
			local light = hud_inv:get_stack("main", INV_LIGHT_INDEX)
			light:add_item(dropped_item)
			hud_inv:set_stack("main", INV_LIGHT_INDEX, light)
		else
			local inv = inventories[player:get_player_name()]
			if not inv[item_name] then
				inv[item_name] = dropped_item:get_count()
			else
				inv[item_name] = inv[item_name] + dropped_item:get_count()
			end
		end
	end
	update_formspec(player)
end

local save_interval = tonumber(minetest.setting_get("server_map_save_interval")) or 5.3
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > save_interval then
		timer = 0
		save_inventories()
	end
end)


load_inventories()
minetest.setting_set("static_spawnpoint", "1,-80,0")
minetest.setting_set("enable_damage", "false")

--
-- Mapgen
--

local mg_params = minetest.get_mapgen_params()
local mg_noise_params = {
	offset = 0.0,
	scale = 1.0,
	spread = { x = 25, y = 25, z = 25 },
	seed = mg_params.seed,
	octaves = 4,
	persistence = 0.5,
}

minetest.set_mapgen_params({
	mgname = "singlenode",
	flags = "nolight",
})


local c_air
local c_stones = {}

minetest.register_on_generated(function(minp, maxp, seed)
	local c_air = c_air or minetest.get_content_id("air")

	local vox_manip, vox_minp, vox_maxp = minetest.get_mapgen_object("voxelmanip")
	local vox_data = vox_manip:get_data()
	local vox_area = VoxelArea:new({ MinEdge = vox_minp, MaxEdge = vox_maxp })

	local noise_map = PerlinNoiseMap(mg_noise_params,
			{ x = maxp.x - minp.x + 1, y = maxp.y - minp.y + 1, z = maxp.z - minp.z + 1 })
	local noise_table = noise_map:get3dMap_flat(minp)
	local noise_index = 0

	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
	for x = minp.x, maxp.x do
		local vox_index = vox_area:index(x, y, z)
		noise_index = noise_index + 1
		
		local radius = math.sqrt(x * x + z * z)
		local level = math.min(math.ceil(radius / LEVEL_EXTENT), LEVEL_MAX)

		local noise = noise_table[noise_index] + math.abs((y + 50) / 32.0) - 0.8

		if noise > 0.0 then
			if not c_stones[level] then
				c_stones[level] = minetest.get_content_id("score:stone_" .. level)
			end
			vox_data[vox_index] = c_stones[level]
		else
			vox_data[vox_index] = c_air
		end
	end
	end
	end

	vox_manip:set_data(vox_data)
	minetest.generate_ores(vox_manip, minp, maxp)
	vox_manip:calc_lighting()
	vox_manip:write_to_map()
end)

-- Some aliases to supress error messages
minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_", "air")
minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_river_water_source", "air")
