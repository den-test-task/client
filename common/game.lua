
local tictactoe = require 'common.tictactoe'

local M = {}

local game = nil

local x = 'x'
local o = 'o'
local empty = ''
local ROUND_TIME = 15

local api = {
	set_current_turn = 'set_current_turn',
	on_game_over = 'on_game_over',
	on_move = 'on_move',
	on_new_round = 'on_new_round',
}

local function safe_call(callback, ...)
	local func = api[callback] and M[callback]
	if func then
		func(...)
	end
end

function M.get_player(value)
	return game.players[value]
end

function M.new_game(p1, p2)
	game = {
		logic = tictactoe.new(),
		players = {},
		started = false,
		result = false,
		is_over = false,
	}
end

function M.set_score()
	
end

function M.new_round()
	game.logic = tictactoe.new()
	game.started = false
	game.result = false
	game.is_over = false
	local p1 = game.players.x
	local p2 = game.players.o
	p1.avatar, p2.avatar = p2.avatar, p1.avatar
	game.players[p1.avatar] = p1
	game.players[p2.avatar] = p2
	safe_call(api.on_new_round)
end

function M.set_players(p1, p2)
	game.players[p1.avatar] = p1
	game.players[p2.avatar] = p2
end

function M.get_players()
	return game.players
end

function M.refresh_players()
	local result = {}
	for _, p in pairs(game.players) do
		result[p.avatar] = p
	end
	game.players = result
end

function M.get_winner()
	return game.result and game.players[game.result] or false
end

function M.move_timer_over()
	local turn, grid = game.logic:get_state()
	game.players[turn].get_move()
	local winner = game.logic:set_ended()
	game.result = winner
	game.is_over = true
	safe_call(api.on_game_over, nil, winner)
end

function M.is_my_turn()
	local turn, grid = game.logic:get_state()
	local player = M.get_player(turn)
	return player and player.me and player.avatar or false
end

function M.move()
	local turn, grid = game.logic:get_state()
	safe_call(api.set_current_turn, turn, ROUND_TIME)
	game.players[turn].get_move(grid, function(cell_index)
		local move_ok, game_over, win_steps = game.logic:on_move(cell_index, turn)
		if move_ok then
			safe_call(api.on_move, cell_index, turn, game_over)
			if game_over then
				game.is_over = true
				game.result = win_steps and grid[win_steps[1]] or false
				safe_call(api.on_game_over, win_steps, win_steps and turn or false)
			end
		end
	end, turn)
end

local function cancel_start_timer(game)
	if game.start_timer then
		timer.cancel(game.start_timer)
		game.start_timer = nil
	end
end

function M.start_round_timer(callback)
	cancel_start_timer(game)
	local start_time = 3
	callback(start_time)
	game.start_timer = timer.delay(1, true, function()
		start_time = start_time - 1
		if start_time <= 0 then
			cancel_start_timer(game)
			game.started = true
			M.move()
		end
		callback(start_time)
	end)
end

function M.pick_cell(index)
	if game and game.started then
		local move, grid = game.logic:get_state()
		if move then
			local touch_handler = game.players[move].on_touch
			if touch_handler then
				touch_handler(index, M.is_my_turn())
			end
		end
	end
end

function M.leave()
	cancel_start_timer(game)
	game = nil
end

return M
