
local storage = require 'common.storage'

local M = {}

local default_name = storage.get_default_name()
local name = default_name

function M.get_name()
	name = storage.load_name()
	return utf8.len(name) < 1 and default_name or name
end

function M.reset_name(text)
	name = text
	storage.save_name(M.get_name())
end

function M.refresh_name(char)
	if char then
		name = name == default_name and char or name .. char
	else
		name = utf8.sub(name, 0, math.max(utf8.len(name) - 1, 0))
		--name = utf8.len(name) < 1 and default_name or name
	end
	storage.save_name(name)
end

return M
