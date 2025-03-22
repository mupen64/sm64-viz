-- Input Direction Lua "Encoding Version"
-- Authors: MKDasher, Xander, ShadoXFM
-- Hacker: Eddio0141
-- Special thanks to Pannenkoek2012 and Peter Fedak for angle calculation support.
-- Also thanks to MKDasher to making the code very clean
-- Other contributors:
--	Madghostek

folder = debug.getinfo(1).source:sub(2):match("(.*\\)")
lib_path = folder .. "lib\\"

---@module 'breitbandgraphics'
BreitbandGraphics = dofile(lib_path .. "breitbandgraphics.lua")

---@module 'mupen-lua-ugui'
ugui = dofile(lib_path .. "mupen-lua-ugui.lua")

---@module 'mupen-lua-ugui-ext'
ugui_ext = dofile(lib_path .. "mupen-lua-ugui-ext.lua")

PATH = debug.getinfo(1).source:sub(2):match("(.*\\)") .. "\\InputDirection_dev\\"

Joypad = { input = { X = 0, Y = 0 } }

dofile(PATH .. "Drawing.lua")
Drawing.resizeScreen()

dofile(PATH .. "Memory.lua")
dofile(PATH .. "Angles.lua")
dofile(PATH .. "Engine.lua")
dofile(PATH .. "MoreMaths.lua")
dofile(PATH .. "Actions.lua")

local function update_memory()
	Memory.UpdatePrevPos()
	Memory.Refresh()
end

update_memory()
Memory.UpdatePrevPos()

function atvi()
	Joypad.input = joypad.get(1)
	update_memory()
end

function atdrawd2d()
	Drawing.paint()
end

emu.atinput(atvi)
emu.atdrawd2d(atdrawd2d)
