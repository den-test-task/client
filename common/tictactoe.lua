
local M = {}
M.__index = M

local x_cell = 'x'
local o_cell = 'o'
local empty_cell = ''
local empty_grid = {'','','','','','','','',''}

function M:new()
	local tictactoe = {
		grid = table.clone(empty_grid),
		empty_cells = 9,
		move = x_cell,
		ended = nil,
		win_steps = nil,
	}
	setmetatable(tictactoe, M)
	return tictactoe
end

function M:get_state()
	return not self.ended and self.move or nil, self.grid
end

function M:set_ended()
	self.ended = true
	return self.move == x_cell and o_cell or x_cell
end

function M:on_move(index, value)
	if value and value == self.move and self.grid[index] == empty_cell then
		self.grid[index] = value
		self.empty_cells = self.empty_cells - 1
		self:check_end()
		self.move = self.move == x_cell and o_cell or x_cell
		return true, self.ended, self.win_steps
	end
end

function M:check_end()
	if self.empty_cells <= 0 then
		self.ended = true
	end
	local grid = self.grid
	local win_steps = self.win_steps
	local grid_1 = grid[1]
	local grid_5 = grid[5]
	local grid_9 = grid[9]
	if not win_steps and grid_1 ~= empty_cell then
		win_steps = win_steps or grid_1 == grid[2] and grid_1 == grid[3] and { 1, 2, 3 }
		win_steps = win_steps or grid_1 == grid[4] and grid_1 == grid[7] and { 1, 4, 7 }
	end
	if not win_steps and grid_5 ~= empty_cell then
		win_steps = win_steps or grid_5 == grid[4] and grid_5 == grid[6] and { 4, 5, 6 }
		win_steps = win_steps or grid_5 == grid[2] and grid_5 == grid[8] and { 2, 5, 8 }
		win_steps = win_steps or grid_5 == grid_1 and grid_5 == grid_9 and { 1, 5, 9 }
		win_steps = win_steps or grid_5 == grid[3] and grid_5 == grid[7] and { 3, 5, 7 }
	end
	if not win_steps and grid_9 ~= empty_cell then
		win_steps = win_steps or grid_9 == grid[8] and grid_9 == grid[7] and { 7, 8, 9 }
		win_steps = win_steps or grid_9 == grid[6] and grid_9 == grid[3] and { 3, 6, 9 }
	end
	self.win_steps = win_steps
	self.ended = self.ended or self.win_steps and true
end

return M
