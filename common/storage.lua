
local defsave = require 'defsave.defsave'

local project_title = sys.get_config('project.title')
local player_profile = 'player_profile'

local M = {}

local profile = nil
local player_name = 'player_name'

M.defaults = {
	[project_title] = {
		[player_profile] = {
			[player_name] = 'Nickname',
		}
	}
}

function M.get_default_name()
	return M.defaults[project_title].player_profile.player_name
end

function M.initialize()
	defsave.set_appname(project_title)
	defsave.default_data = M.defaults
	defsave.load(player_profile)
	--defsave.reset_to_default(player_profile)
end

function M.save_name(name)
	defsave.set(player_profile, player_name, name or '')
	defsave.save(player_profile)
end

function M.load_name()
	return defsave.get(player_profile, player_name)
end

return M
