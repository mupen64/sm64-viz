--
-- Copyright (c) 2025, sm64-viz maintainers, contributors, and original authors (MKDasher, Xander, ShadoXFM)
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

folder = debug.getinfo(1).source:sub(2):match("(.*\\)")
lib_path = folder .. "lib\\"

---@module 'breitbandgraphics'
BreitbandGraphics = dofile(lib_path .. "breitbandgraphics.lua")

PATH = debug.getinfo(1).source:sub(2):match("(.*\\)") .. "\\viz\\"

Joypad = { input = { X = 0, Y = 0 } }

dofile(PATH .. "Drawing.lua")
dofile(PATH .. "Memory.lua")
dofile(PATH .. "Angles.lua")
dofile(PATH .. "Engine.lua")
dofile(PATH .. "MoreMaths.lua")
dofile(PATH .. "Actions.lua")

local function update_memory()
	Memory.Refresh()
end

emu.atinput(function()
	Memory.UpdatePrevPos()
end)

emu.atvi(function()
	Joypad.input = joypad.get(1)
	update_memory()
end)

emu.atdrawd2d(function()
	Drawing.paint()
end)

update_memory()
Memory.UpdatePrevPos()
Drawing.resizeScreen()
