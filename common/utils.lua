
local table_type = 'table'

-- Quick & Dirty
function table.clone(t)
	return { unpack(t) }
end

function table.deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == table_type then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
		end
		setmetatable(copy, table.deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

function table.get_min_max(evalTable)
	table.sort(evalTable)
	return {evalTable[1],evalTable[#evalTable]}
end

function gui.wrap_func(self, f)
	local gui_instance = lua_script_instance.Get()
	return function(...)
		local orig_instance = lua_script_instance.Get()
		local need_swap = gui_instance ~= orig_instance
		if need_swap then
			lua_script_instance.Set(gui_instance)
		end
		f(self, ...)
		if need_swap then
			lua_script_instance.Set(orig_instance)
		end
	end
end
