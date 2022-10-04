
local profile = require 'common.profile'
local ai_names = require 'common.ai_names'
local minimax_abp = require 'common.minimax_abp'

local M = {}

local empty_cell = ''
local function random_move(map)
	local free = {}
	for i = 1, 9 do
		if map[i] == empty_cell then
			free[#free + 1] = i
		end
	end
	return free[math.random(#free)], #free
end

function M.get_ai(simulate_user)
	local set_move = nil
	return {
		ai = true,
		avatar = nil,
		score = 0,
		revenge = true,
		name = simulate_user and ai_names[math.random(1, #ai_names)] or 'Robot',
		get_move = function(map, callback)
			set_move = callback
			if not callback then return end
			local move, frees = random_move(map)
			if frees < 9 then
				move = minimax_abp.chooseBestMove(map)
			end
			timer.delay(simulate_user and math.random(1, 20)*0.1 or 0.1, false, function()
				if set_move then
					set_move(move)
				end
			end)
		end,
	}
end

--[[
id
session_id
name
value
revenge
score
--]]

function M.get_me()
	local set_move = nil
	return {
		me = true,
		avatar = nil,
		score = 0,
		name = profile.get_name(),
		get_move = function(map, callback)
			set_move = callback
		end,
		on_touch = function(cell_index)
			if set_move then
				set_move(cell_index)
			else
				return false
			end
		end,
	}
end

function M.get_pc_player()
	local set_move = nil
	return {
		pc_player = true,
		avatar = nil,
		score = 0,
		revenge = true,
		name = 'Second PC player',
		get_move = function(map, callback)
			set_move = callback
		end,
		on_touch = function(cell_index)
			if set_move and set_move(cell_index) then
				set_move = nil
			else
				return false
			end
		end,
	}
end

function M.get_enemy()
	local set_move = nil
	return {
		enemy = true,
		avatar = nil,
		score = 0,
		revenge = nil,
		name = '',
		get_move = function(map, callback)
			set_move = callback
		end,
		on_touch = function(cell_index)
			if set_move then
				set_move(cell_index)
			else
				return false
			end
		end,
	}
end

return M
