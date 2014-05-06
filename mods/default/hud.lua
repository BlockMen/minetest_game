default.hud = {}

-- HUD statbar ids
default.hud.healthbar = {}
default.hud.breathbar = {}

-- HUD statbar definitions
local healthbar_def =  {
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "heart.png",
		number = 20,
		alignment = {x = -1,y = -1},
		offset = {x = -262, y = -85},
		size = {x = 24, y = 24},
		}

local breathbar_def =  {
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "bubble.png",
		number = 0,
		alignment = {x = -1, y = -1},
		offset = {x = 15, y = -85},
		size = {x = 24, y = 24},
		}

-- Eventhandler
local function player_event_handler(player, eventname)
	if not player or not player:is_player() or
	   not minetest.setting_getbool("enable_damage") then
		return
	end

	local name = player:get_player_name()

	if eventname == "health_changed" then
		local bar_id = default.hud.healthbar[name]
		if bar_id ~= nil then
			default.hud.update_statbars(player, bar_id, player:get_hp())
			return true
		end
	end

	if eventname == "breath_changed" then
		local bar_id = default.hud.breathbar[name]
		if bar_id ~= nil then
			local air = player:get_breath()
			if air > 10 then air = 0 end
			default.hud.update_statbars(player, bar_id, air*2)
			return true
		end
	end
 
	return false
end

-- Init and handling
local function initialize_statbars(player)
	if not player or not player:is_player() or
	   not minetest.setting_getbool("enable_damage") then
		return
	end
	
	local name = player:get_player_name()

	default.hud.healthbar[name] = player:hud_add(healthbar_def)
	default.hud.breathbar[name] = player:hud_add(breathbar_def)

	-- set correct values
	player_event_handler(player, "health_changed")
	player_event_handler(player, "breath_changed")
end

function default.hud.update_statbars(player, id, value)
	if not player or not player:is_player() then
		return
	end

	player:hud_change(id, "number", value)
end

function default.hud.cleanup_statbars(player, remove)
	if not player or not player:is_player() then
		return
	end

	local name = player:get_player_name()

	-- remove from HUD if wanted
	if remove then
		player:hud_remove(default.hud.healthbar[name])
		player:hud_remove(default.hud.breathbar[name])
	end

	-- clean ids
	default.hud.healthbar[name] = nil
	default.hud.breathbar[name] = nil
end

-- Registrations
minetest.register_on_joinplayer(initialize_statbars)
minetest.register_on_leaveplayer(default.hud.cleanup_statbars)
minetest.register_playerevent(player_event_handler)
