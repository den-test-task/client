
local M = {}

M.KEYBOARD_INPUT = hash("keyboard_input")

local function log(text)
	print(text)
	msg.post(".", "log", { text = text })
end

function M.create_keyboard()
	if html5 then
		html5.run([[
		var e = document.createElement("input");
		e.setAttribute('type', 'text');
		e.setAttribute('value', '');
		e.id = "defoldinputkeyboard";
		e.style = "position:absolute; left:-10000px; top:auto; width:1px; height:1px; overflow:hidden; pointer-events:none;";
		document.body.appendChild(e);
		]])
	end
end

function M.set_value(value)
	if html5 then
		value = value or ''
		html5.run('var e = document.getElementById("defoldinputkeyboard"); e.setAttribute("value", "'..value..'");')
	end
end

local ttt = nil
function M.show_keyboard()
	if html5 then
		html5.run('var e = document.getElementById("defoldinputkeyboard"); e.focus();')
		ttt = timer.delay(0.2222, true, function()
			local text = html5.run('document.getElementById("defoldinputkeyboard").value')
			msg.post(".", M.KEYBOARD_INPUT, { text = text })
		end)
	end
end

function M.hide_keyboard()
	if html5 then
		if ttt then
			timer.cancel(ttt)
			ttt = nil
		end
	end
end

return M

