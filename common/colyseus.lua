
local M = {}

local colyseus_client = require 'colyseus.client'

local _client = nil
local _room = nil

local url = 'wss://den-test-task.herokuapp.com/'
--local url = 'ws://127.0.0.1:2567'
local room_name = 'my_room'

function M.connect(me, enemy, private, callback, on_game_start)
	if _room then
		_room:leave(false)
	end
	_client = colyseus_client.new(url)
	_client:join_or_create(room_name, { name = me.name or 'anonymous', private = private or false }, function(err, room)
		if err then
			callback(false)
		else
			_room = room
			local on_turn = nil
			room.state.players.on_add = function(player, key)
				local who = enemy
				if key == room.sessionId then
					callback(true, room.id)
					who.on_revenge = function()
						_room:send('on_revenge')
					end
					who = me
				end
				who.get_move = function(_, turn_callback, turn)
					on_turn = turn_callback
				end
				who.on_touch = function(index, is_my_turn)
					room:send('do_move', { index = index, value = who.avatar })
				end
				player.on_change = function(changes)
					for i, change in ipairs(changes) do
						who[change.field] = change.value
						if who ~= me and change.value and change.field == 'revenge' then
							msg.post('main:/main#main', 'revenge', { })
						end
					end
				end
			end

			room:on_message('new_move', function(data)
				if on_turn then
					on_turn(data.index)
				end
			end)

			room.state.on_change = function(changes)
				for i, change in ipairs(changes) do
					if change.field == 'started' then
						if change.value == true then
							on_game_start()
						end
					end
				end
			end

		end
	end)
end

function M.on_gameover(winner)
	if _room then
		_room:send('gameover', { winner = winner or "" })
	end
end

function M.leave()
	if _room then
		_room:send('imleaver')
		_room:leave(false)
	end
end

return M
