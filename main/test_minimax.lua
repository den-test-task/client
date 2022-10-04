
local minimax_abp = require 'common.minimax_abp'

local M = {}

local my_step = true

local boardState = {
	'', '', '',
	'', '', '',
	'', '', ''
}

local function log_map()
	print()
	local s = ''
	for i = 1, 9 do
		s = s .. (boardState[i] == '' and '0' or boardState[i])
		if i%3 == 0 then
			print(math.ceil(i/3) .. ':  ' .. s)
			s = ''
		end
	end
end

local function do_move(i, is_player)
	boardState[i] = is_player and 'o' or 'x'
	log_map()
end

function M.init()
	do_move(minimax_abp.chooseBestMove(boardState))
end

function M.inp(num)
	if my_step and num then
		do_move(num, true)
		my_step = not my_step
		local ai_step = minimax_abp.chooseBestMove(boardState)
		if ai_step then
			do_move(ai_step)
			local result = minimax_abp.checkEndState(boardState)
			if result == 3 then
				print('TIE')
			elseif result == 'x' then
				print('Winner X')
			elseif result == 'o' then
				print('Winner O')
			end
		else
			print('Game Is Over')
		end
		my_step = not my_step
	end
end

return M
