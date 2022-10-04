
local game_controller = require 'common.game_controller'
local colyseus = require 'common.colyseus'
local game = require 'common.game'

local M = {}

local temp_timer = nil

function M.create_private_room(_, sender)
	local me = game_controller.get_player(true)
	local enemy = game_controller.get_player()
	colyseus.connect(me, enemy, true, function(success, room_id)
		msg.post(sender, 'create_private_room', { room_id = success and room_id or false })
	end, function()
		print('private [created] game started')
		game_controller.start_game()
	end)
end

function M.join_private_room(room_id, sender)
	local me = game_controller.get_player(true)
	local enemy = game_controller.get_player()
	colyseus.connect(me, enemy, room_id, function(success)
		msg.post(sender, 'join_private_room', { success = success })
	end, function()
		print('private [joined] game started')
		game_controller.on_game_over = colyseus.on_gameover
		game_controller.start_game()
	end)
end

local leave_publick = false
function M.join_or_create_public_room()
	leave_publick = false
	temp_timer = timer.delay(15, false, function()
		colyseus.leave()
		msg.post('main:/main#main', 'show_game_screen', {mode = 'VS_ROBOT', data = true})
	end)
	local me = game_controller.get_player(true)
	local enemy = game_controller.get_player()
	colyseus.connect(me, enemy, false, function(success, room_id)
		if success and room_id then
		else
		end
	end, function()
		if temp_timer then
			timer.cancel(temp_timer)
			temp_timer = nil
		end
		game_controller.start_game()
	end)

end

function M.on_leave_find_room_screen()
	colyseus.leave()
	if temp_timer then
		timer.cancel(temp_timer)
		temp_timer = nil
	end
end

function M.on_message(message, sender)
	M[message.f](message.data, sender)
end

return M
