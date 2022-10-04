
local monarch = require 'monarch.monarch'
local screens = require 'common.screens'
local game = require 'common.game'

local players = require 'common.players'

local M = {}

local mode_actions = {
	VS_ROBOT = function(rand_name)
		local me = players.get_me()
		local ai = players.get_ai(rand_name)
		local rand_move = math.random(1,2) == 1 
		me.avatar = rand_move and 'x' or 'o'
		ai.avatar = rand_move and 'o' or 'x'
		game.new_game()
		game.set_players(me, ai)
		monarch.replace(screens.game, {clear = true})
		msg.post('main:/sound#sounds', 'screen')
	end,
	VS_PLAYER = function()

		game.new_game()
		local me, enemy = players.get_me(), players.get_enemy()
		local rand_move = math.random(1,2) == 1 
		me.avatar = rand_move and 'x' or 'o'
		enemy.avatar = rand_move and 'o' or 'x'
		game.set_players(me, enemy)

		monarch.show(screens.find_room, nil, { random = true })
		msg.post('main:/sound#sounds', 'screen')
	end,
	VS_FRIEND = function()
		local me = players.get_me()
		local player = players.get_pc_player()
		local rand_move = math.random(1,2) == 1 
		me.avatar = rand_move and 'x' or 'o'
		player.avatar = rand_move and 'o' or 'x'
		game.new_game()
		game.set_players(me, player)
		monarch.replace(screens.game, {clear = true})
		msg.post('main:/sound#sounds', 'screen')
	end,
	PRIVATE_GAME = function()
		game.new_game()
		local me, enemy = players.get_me(), players.get_enemy()
		me.avatar = 'x'
		enemy.avatar = 'o'
		game.set_players(me, enemy)
		monarch.show(screens.find_room, nil, { private = true })
		msg.post('main:/sound#sounds', 'screen')
	end,
}

local function check_revenge()
	for _, player in pairs(game.get_players()) do
		if not player.revenge then
			return false
		end
	end
	msg.post('main:/sound#sounds', 'screen')
	monarch.back(nil, function()
		local winner = game.get_winner()
		if winner then
			winner.score = (winner.score or 0) + 1
		end
		game.new_round()
	end)
	return true
end

function M.start_game()
	monarch.show(screens.game, {clear = true})
	msg.post('main:/sound#sounds', 'screen')
end

function M.set_ui(ui)
	game.refresh_players()
	ui.set_players(game.get_players())
	game.set_current_turn = ui.set_current_turn
	game.on_move = function(index, value, game_over)
		ui.stop_turn_timer()
		ui.turn(index, value)
		if game_over then
			msg.post('main:/sound#sounds', 'gameover')
		else
			msg.post('main:/sound#sounds', 'move_'..value)
			game.move()
		end
	end
	game.start_round_timer(ui.start_round_timer)
	game.on_game_over = function(steps, winner)
		ui.stop_turn_timer()
		ui.gameover(steps, winner, function()
			monarch.show(screens.game_over, nil, { win = game.get_winner(), winner = winner })
			msg.post('main:/sound#sounds', 'screen')
		end)
		if M.on_game_over then
			M.on_game_over(winner)
		end
	end
	game.on_new_round = function()
		ui.on_new_round()
		ui.set_players(game.get_players())
		game.start_round_timer(ui.start_round_timer)
	end
	ui.on_move_timer_over = game.move_timer_over
end

local function on_cell_touched(cell_number)
	game.pick_cell(cell_number)
end

local function leave_game()
	game.leave()
end

function M.get_player(is_me)
	for _, player in pairs(game.get_players()) do
		if is_me and player.me then
			return player
		elseif not is_me and not player.me then
			return player
		end
	end
end

local function revenge(me)
	for _, player in pairs(game.get_players()) do
		if me and player.me then
			player.revenge = true
			if player.on_revenge then
				on_revenge()
			end
		elseif not me and not player.me then
			player.revenge = true
		end
	end
	return check_revenge()
end

function M.on_message(message_id, message)
	if message_id == hash('show_game_screen') then
		mode_actions[message.mode](message.data)
	elseif message_id == hash('revenge') then
		revenge(message.me)
	elseif messge_id == hash('leave_game') then
		leave_game()
	elseif message_id == hash('on_cell_touched') then
		on_cell_touched(message.index)
	end
end

return M
