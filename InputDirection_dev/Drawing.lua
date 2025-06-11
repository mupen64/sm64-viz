local BACKGROUND_COLOUR = "#222222"
local TEXT_COLOUR = "#FFFFFF"

Drawing = {
	WIDTH_OFFSET = 233,
	TOP_MARGIN = 20,
	BOTTOM_MARGIN = 20,
	PAD = 10,
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

	local base_x = Drawing.Screen.Width + 10
	Drawing.drawAnalogStick(base_x, Drawing.TOP_MARGIN)
	Drawing.drawInputButtons(base_x, Drawing.TOP_MARGIN + 160 + Drawing.PAD)
	Drawing.drawMiscData(base_x, Drawing.TOP_MARGIN + 255 + Drawing.PAD)
end

function Drawing.drawAnalogStick(x, y)
	local r = 80 -- radius
	local m = 128 -- max input

	local rect = { x = x, y = y, width = 160, height = 160 }

	local joy_x = x + r + Joypad.input.X * r / m
	local joy_y = y + r - Joypad.input.Y * r / m
	local tip_size = 10

	BreitbandGraphics.draw_rectangle(rect, TEXT_COLOUR, 1)
	BreitbandGraphics.fill_ellipse(rect, "#343434")
	BreitbandGraphics.draw_ellipse(rect, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x, y = y + r }, { x = x + r * 2, y = y + r }, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x + r, y = y }, { x = x + r, y = y + r * 2 }, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x + r, y = y + r }, { x = joy_x, y = joy_y }, "#00FF08", 3)
	BreitbandGraphics.fill_ellipse(
	{ x = joy_x - tip_size / 2, y = joy_y - tip_size / 2, width = tip_size, height = tip_size }, "#FF0000")

	BreitbandGraphics.draw_text2({
		text = "x: " .. Joypad.input.X,
		rectangle = { x = x + r * 2 + 6, y = y + r - 25, width = 100, height = 20 },
		font_name = "Arial",
		font_size = 16,
		color = TEXT_COLOUR,
		align_x = BreitbandGraphics.alignment.start,
	})
	BreitbandGraphics.draw_text2({
		text = "y: " .. -Joypad.input.Y,
		rectangle = { x = x + r * 2 + 6, y = y + r, width = 100, height = 20 },
		font_name = "Arial",
		font_size = 16,
		color = TEXT_COLOUR,
		align_x = BreitbandGraphics.alignment.start,
	})
end

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
end

function Drawing.drawInputButtons(x, y)
	drawInputButton(Joypad.input.A, "#3366CC", "A", "ellipse", x + 82, y + 60, 29, 29, nil, nil, "Arial")
	drawInputButton(Joypad.input.B, "#009245", "B", "ellipse", x + 63, y + 31, 29, 29, nil, nil, "Arial")
	drawInputButton(Joypad.input.start, "#EE1C24", "S", "ellipse", x + 31, y + 60, 29, 29, nil, nil, "Arial")
	drawInputButton(Joypad.input.R, "#DDDDDD", "R", "rect", x + 98, y + 0, 72, 21, nil, nil, "Arial")
	drawInputButton(Joypad.input.L, "#DDDDDD", "L", "rect", x + 9, y + 0, 72, 21, nil, nil, "Arial")
	drawInputButton(Joypad.input.Z, "#DDDDDD", "Z", "rect", x + 0, y + 30, 21, 59, nil, nil, "Arial")

	drawInputButton(Joypad.input.Cleft, "#FFFF00", "3", "ellipse", x + 116, y + 47, 21, 21, 8, 7, "Marlett")
	drawInputButton(Joypad.input.Cright, "#FFFF00", "4", "ellipse", x + 155, y + 47, 21, 21, 9, 7, "Marlett")
	drawInputButton(Joypad.input.Cup, "#FFFF00", "5", "ellipse", x + 135, y + 28, 21, 21, 8, 8, "Marlett")
	drawInputButton(Joypad.input.Cdown, "#FFFF00", "6", "ellipse", x + 135, y + 68, 21, 21, 8, 8, "Marlett")
end

function Drawing.drawMiscData(x, y_0)
	speed = 0
	if Memory.Mario.VSpeed > 0 then
		speed = MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.VSpeed), 6)
	end

	local elements = {
		function(y)
			local sample = emu.samplecount()
			local active = sample ~= 4294967295 
			return { text = active and "Frame: " .. emu.samplecount() or "No movie playing", size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Yaw (Facing): " .. Memory.Mario.FacingYaw, size = LARGE_FONT_SIZE }
		end,
		function(y)
			return { text = "Yaw (Intended): " .. Memory.Mario.IntendedYaw, size = SMALL_FONT_SIZE }
		end,
		function(y)
			return {
				text = "H Spd: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed), 3),
				size =
					LARGE_FONT_SIZE
			}
		end,
		function(y)
			return { text = "H Sliding Spd: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 2), size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 2), size = SMALL_FONT_SIZE }
		end,
		function(y)
			local spd_eff = Engine.GetSpeedEfficiency()
			local text
			if spd_eff > 100000 then
				text = "Spd Efficiency: ∞%"
			else
				text = string.format("Spd Efficiency: %.2f%%", Engine.GetSpeedEfficiency())
			end
			return { text = text, size = SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Y Spd: " .. speed, size = LARGE_FONT_SIZE }
		end,
		function(y)
			return {
				text = "Mario X: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2),
				size =
					SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				text = "Mario Y: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2),
				size =
					SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				text = "Mario Z: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2),
				size =
					SMALL_FONT_SIZE
			}
		end,
		function(y)
			return { text = "Action: " .. Engine.GetCurrentAction(), size = MEDIUM_FONT_SIZE }
		end
	}

	local BIG = 30
	local SMALL = 20

	local spacing = { 0, BIG, SMALL, BIG, SMALL, SMALL, SMALL, BIG, SMALL, SMALL, SMALL, BIG }

	local y = y_0

	local width = Drawing.Screen.Width + Drawing.WIDTH_OFFSET - x - 10
	for i = 1, #elements do
		y = y + spacing[i]
		local result = elements[i](y)
		BreitbandGraphics.draw_text2({
			text = result.text,
			rectangle = { x = x, y = y, width = width, height = 20 },
			font_name = "Arial",
			font_size = result.size + 4,
			color = TEXT_COLOUR,
			align_x = BreitbandGraphics.alignment.start,
			-- fit = true
		})
	end
end
