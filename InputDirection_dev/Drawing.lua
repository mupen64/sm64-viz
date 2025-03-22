local BACKGROUND_COLOUR = "#222222"
local TEXT_COLOUR = "#FFFFFF"

Drawing = {
	WIDTH_OFFSET = 233,
	Screen = {
		Height = 0,
		Width = 0
	}
}

function Drawing.resizeScreen()
	screen = wgui.info()
	Drawing.Screen.Height = screen.height
	width10 = screen.width % 10
	if width10 == 0 or width10 == 4 or width10 == 8 then
		Drawing.Screen.Width = screen.width
		wgui.resize(screen.width + Drawing.WIDTH_OFFSET, screen.height)
	else
		Drawing.Screen.Width = screen.width - Drawing.WIDTH_OFFSET
	end
end

local LARGE_FONT_SIZE = 16
local MEDIUM_FONT_SIZE = 14
local SMALL_FONT_SIZE = 12

function Drawing.paint()
	BreitbandGraphics.fill_rectangle(
		{ x = Drawing.Screen.Width, y = 0, width = Drawing.WIDTH_OFFSET, height = Drawing.Screen.Height },
		BACKGROUND_COLOUR)
	local offset = 5
	Drawing.drawAnalogStick(Drawing.Screen.Width + Drawing.WIDTH_OFFSET / 3 + 13, 90 + offset)
	Memory.Refresh()
	Drawing.drawInputButtons(Drawing.Screen.Width + Drawing.WIDTH_OFFSET / 3 + 13, -230 + offset)
	Drawing.drawMiscData(Drawing.Screen.Width + 13, 245 + offset)
end


function Drawing.drawAnalogStick(x, y)
	local r = 80 -- radius
	local m = 128 -- max input

	local rect = { x = x - 80, y = y - 80, width = 160, height = 160 }

	BreitbandGraphics.draw_rectangle(rect, TEXT_COLOUR, 1)
	BreitbandGraphics.fill_ellipse(rect, "#343434")
	BreitbandGraphics.draw_ellipse(rect, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x - r, y = y }, { x = x + r, y = y }, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x, y = y - r }, { x = x, y = y + r }, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x, y = y }, { x = x + Joypad.input.X * r / m, y = y - Joypad.input.Y * r / m },
		"#00FF08", 3)
	BreitbandGraphics.fill_ellipse(
		{ x = x + Joypad.input.X * r / m - 4, y = y - Joypad.input.Y * r / m - 4, width = 8, height = 8 }, "#FF0000")

	BreitbandGraphics.draw_text2({
		text = "x: " .. Joypad.input.X,
		rectangle = { x = x + r + 6, y = y - 25, width = 100, height = 20 },
		font_name = "Arial",
		font_size = 16,
		color = TEXT_COLOUR,
		align_x = BreitbandGraphics.alignment.start,
	})
	BreitbandGraphics.draw_text2({
		text = "y: " .. -Joypad.input.Y,
		rectangle = { x = x + r + 6, y = y, width = 100, height = 20 },
		font_name = "Arial",
		font_size = 16,
		color = TEXT_COLOUR,
		align_x = BreitbandGraphics.alignment.start,
	})
end

-- pass wgui.rect or wgui.ellipse to the shape param
local function drawInputButton(pressed, highlightedColour, text, shape, x, y, w, h, textoffset_x, textoffset_y, font)
	local rect = { x = x, y = y, width = w, height = h }
	local text_color = TEXT_COLOUR

	if shape == "ellipse" then
		if pressed then
			BreitbandGraphics.fill_ellipse(rect, highlightedColour)
		end
		BreitbandGraphics.draw_ellipse(rect, TEXT_COLOUR, 1)
	elseif shape == "rect" then
		if pressed then
			BreitbandGraphics.fill_rectangle(rect, highlightedColour)
			text_color = "#000000"
		end
		BreitbandGraphics.draw_rectangle(rect, TEXT_COLOUR, 1)
	end

	if textoffset_x == nil then textoffset_x = 6 end
	if textoffset_y == nil then textoffset_y = 8 end


	BreitbandGraphics.draw_text2({
		text = text,
		rectangle = rect,
		font_name = font,
		font_size = 16,
		color = text_color,
	})
	-- wgui.text(x + w / 2 - textoffset_x, y + h / 2 - textoffset_y, text)
end

-- in the future: make these a ratio instead of hardcoded numbers
-- adapted from ShadoXFM's code
function Drawing.drawInputButtons(x, y)
	drawInputButton(Joypad.input.A, "#3366CC", "A", "ellipse", x + 4, y + 470, 29, 29, nil, nil, "Arial")
	drawInputButton(Joypad.input.B, "#009245", "B", "ellipse", x - 15, y + 441, 29, 29, nil, nil, "Arial")
	drawInputButton(Joypad.input.start, "#EE1C24", "S", "ellipse", x - 47, y + 470, 29, 29, nil, nil, "Arial")
	drawInputButton(Joypad.input.R, "#DDDDDD", "R", "rect", x + 20, y + 410, 72, 21, nil, nil, "Arial")
	drawInputButton(Joypad.input.L, "#DDDDDD", "L", "rect", x - 69, y + 410, 72, 21, nil, nil, "Arial")
	drawInputButton(Joypad.input.Z, "#DDDDDD", "Z", "rect", x - 78, y + 440, 21, 59, nil, nil, "Arial")

	drawInputButton(Joypad.input.Cleft, "#FFFF00", "3", "ellipse", x + 38, y + 457, 21, 21, 8, 7, "Marlett")
	drawInputButton(Joypad.input.Cright, "#FFFF00", "4", "ellipse", x + 77, y + 457, 21, 21, 9, 7, "Marlett")
	drawInputButton(Joypad.input.Cup, "#FFFF00", "5", "ellipse", x + 57, y + 438, 21, 21, 8, 8, "Marlett")
	drawInputButton(Joypad.input.Cdown, "#FFFF00", "6", "ellipse", x + 57, y + 478, 21, 21, 8, 8, "Marlett")
end

function Drawing.drawMiscData(x, y_0, display_input_text)
	speed = 0
	if Memory.Mario.VSpeed > 0 then
		speed = MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.VSpeed), 6)
	end

	local elements = {
		function(y)
			return
			{ text = "Frame: " .. emu.samplecount(), size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Yaw (Facing): " .. Memory.Mario.FacingYaw, size = LARGE_FONT_SIZE }
		end,
		function(y)
			return { text = "Yaw (Intended): " .. Memory.Mario.IntendedYaw, size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "H Spd: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed), 3), size =
			LARGE_FONT_SIZE }
		end,
		function(y)
			return { text = "H Sliding Spd: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 2), size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 2), size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = string.format("Spd Efficiency: %.2f%%", Engine.GetSpeedEfficiency()), size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Y Spd: " .. speed, size = LARGE_FONT_SIZE }
		end,
		function(y)
			return { text = "Mario X: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2), size =
			SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Mario Y: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2), size =
			SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Mario Z: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2), size =
			SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Action: " .. Engine.GetCurrentAction(), size = MEDIUM_FONT_SIZE }
		end
	}

	local spacing = { 30, 32, 25, 32, 25, 20, 20, 32, 25, 20, 20, 32 }

	local y = y_0

	local width = Drawing.Screen.Width + Drawing.WIDTH_OFFSET - x - 10
	for i = 1, table.getn(elements) do
		y = y + spacing[i]
		local result = elements[i](y)
		BreitbandGraphics.draw_text2({
			text = result.text,
			rectangle = { x = x, y = y, width = width, height = 20 },
			font_name = "Arial",
			font_size = result.size + 4,
			color = TEXT_COLOUR,
			align_x = BreitbandGraphics.alignment.start,
			fit = true
		})
	end

	--[[
	wgui.setcolor(TEXT_COLOUR)
	x = x + 18
	wgui.text(x, 50, "Like")
	wgui.text(x+30, 80, "Comment")
	wgui.text(x+80, 110, "Subscribe")
	wgui.setfont(75,"Impact","")
	wgui.text(140, 600, "POV: YOU ARE BULLY")]]
end
