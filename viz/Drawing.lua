--
-- Copyright (c) 2025, sm64-viz maintainers, contributors, and original authors (MKDasher, Xander, ShadoXFM)
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

local BACKGROUND_COLOUR = "#222222"
local TEXT_COLOUR = "#FFFFFF"

Drawing = {
	TOP_BOTTOM_MARGIN = 20,
	PAD = 10,
	JOY_RADIUS = 0,
	LARGE_FONT_SIZE = 0,
	MEDIUM_FONT_SIZE = 0,
	SMALL_FONT_SIZE = 0,
	effective_width_offset = 0,
	initial_size = { width = 0, height = 0 },
	size = { width = 0, height = 0 },
}

local function adjust_width_for_aspect_ratio(target_width, height)
	local target_aspect = 16 / 9
	local ideal_width = math.floor(height * target_aspect + 0.5)

	local best_width = ideal_width
	while best_width < target_width do
		best_width = best_width + 1
		local ratio = best_width / height
		if math.abs(ratio - target_aspect) < 0.01 then
			break
		end
	end
	return best_width
end

local function update_scaled_variables()
	Drawing.SMALL_FONT_SIZE = 12 * Drawing.scale
	Drawing.MEDIUM_FONT_SIZE = 14 * Drawing.scale
	Drawing.LARGE_FONT_SIZE = 16 * Drawing.scale
	Drawing.JOY_RADIUS = 80 * Drawing.scale
end

function Drawing.size_up()
	Drawing.initial_size = wgui.info()

	local best_width = adjust_width_for_aspect_ratio(Drawing.initial_size.width,
		Drawing.initial_size.height - Drawing.TOP_BOTTOM_MARGIN * 2)
	Drawing.effective_width_offset = best_width - Drawing.initial_size.width
	Drawing.size = { width = best_width, height = Drawing.initial_size.height }

	Drawing.scale = (Drawing.initial_size.height - 23) / 600
	Drawing.scale = MoreMaths.Round(Drawing.scale, 2)

	update_scaled_variables()

	wgui.resize(Drawing.size.width, Drawing.size.height)
end

function Drawing.size_down()
	wgui.resize(Drawing.size.width - Drawing.effective_width_offset, Drawing.size.height)
end

function Drawing.paint()
	-- DEBUG: Change scale with cursor
	if false then
		Drawing.scale = math.max(0.1, (input.get().xmouse / 800))
		update_scaled_variables()
	end

	BreitbandGraphics.fill_rectangle(
		{ x = Drawing.initial_size.width, y = 0, width = Drawing.effective_width_offset, height = Drawing.size.height },
		BACKGROUND_COLOUR)

	local base_x = Drawing.initial_size.width + 10
	local current_y = Drawing.TOP_BOTTOM_MARGIN

	local joy_rect = Drawing.draw_joystick(base_x, current_y)

	current_y = current_y + joy_rect.height + Drawing.PAD

	local buttons_rect = Drawing.draw_buttons(base_x, current_y)

	current_y = current_y + buttons_rect.height + Drawing.PAD

	Drawing.drawMiscData(base_x, current_y)
end

function Drawing.draw_joystick(x, y)
	local rect = { x = x, y = y, width = Drawing.JOY_RADIUS * 2, height = Drawing.JOY_RADIUS * 2 }

	local joy_x = x + Drawing.JOY_RADIUS + Joypad.input.X * Drawing.JOY_RADIUS / 128
	local joy_y = y + Drawing.JOY_RADIUS - Joypad.input.Y * Drawing.JOY_RADIUS / 128
	local line_width = 3 * Drawing.scale
	local tip_size = 10 * Drawing.scale

	BreitbandGraphics.draw_rectangle(rect, TEXT_COLOUR, 1)
	BreitbandGraphics.fill_ellipse(rect, "#343434")
	BreitbandGraphics.draw_ellipse(rect, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x, y = y + Drawing.JOY_RADIUS },
		{ x = x + Drawing.JOY_RADIUS * 2, y = y + Drawing.JOY_RADIUS }, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x + Drawing.JOY_RADIUS, y = y },
		{ x = x + Drawing.JOY_RADIUS, y = y + Drawing.JOY_RADIUS * 2 }, TEXT_COLOUR, 1)
	BreitbandGraphics.draw_line({ x = x + Drawing.JOY_RADIUS, y = y + Drawing.JOY_RADIUS }, { x = joy_x, y = joy_y },
		"#00FF08", line_width)
	BreitbandGraphics.fill_ellipse(
		{ x = joy_x - tip_size / 2, y = joy_y - tip_size / 2, width = tip_size, height = tip_size }, "#FF0000")

	BreitbandGraphics.draw_text2({
		text = "x: " .. Joypad.input.X,
		rectangle = { x = x + Drawing.JOY_RADIUS * 2 + Drawing.PAD, y = y + Drawing.JOY_RADIUS - 25 * Drawing.scale, width = 100 * Drawing.scale, height = 20 * Drawing.scale },
		font_name = "Arial",
		font_size = Drawing.MEDIUM_FONT_SIZE,
		color = TEXT_COLOUR,
		align_x = BreitbandGraphics.alignment.start,
	})
	BreitbandGraphics.draw_text2({
		text = "y: " .. -Joypad.input.Y,
		rectangle = { x = x + Drawing.JOY_RADIUS * 2 + Drawing.PAD, y = y + Drawing.JOY_RADIUS, width = 100 * Drawing.scale, height = 20 * Drawing.scale },
		font_name = "Arial",
		font_size = Drawing.MEDIUM_FONT_SIZE,
		color = TEXT_COLOUR,
		align_x = BreitbandGraphics.alignment.start,
	})

	return rect
end

local function draw_button(pressed, highlightedColour, text, shape, origin_x, origin_y, x, y, w, h, textoffset_x,
						   textoffset_y, font)
	local rect = {
		x = origin_x + x * Drawing.scale,
		y = origin_y + y * Drawing.scale,
		width = w * Drawing.scale,
		height = h * Drawing.scale
	}
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
		font_size = Drawing.MEDIUM_FONT_SIZE,
		color = text_color,
	})

	return rect
end

function Drawing.draw_buttons(x, y)
	local max_bottom = 0

	local function track_max(rect)
		local bottom = rect.y + rect.height
		if bottom > max_bottom then
			max_bottom = bottom
			max_rect = rect
		end
	end

	track_max(draw_button(Joypad.input.A, "#3366CC", "A", "ellipse", x, y, 82, 60, 29, 29, nil, nil, "Arial"))
	track_max(draw_button(Joypad.input.B, "#009245", "B", "ellipse", x, y, 63, 31, 29, 29, nil, nil, "Arial"))
	track_max(draw_button(Joypad.input.start, "#EE1C24", "S", "ellipse", x, y, 31, 60, 29, 29, nil, nil, "Arial"))
	track_max(draw_button(Joypad.input.R, "#DDDDDD", "R", "rect", x, y, 98, 0, 72, 21, nil, nil, "Arial"))
	track_max(draw_button(Joypad.input.L, "#DDDDDD", "L", "rect", x, y, 9, 0, 72, 21, nil, nil, "Arial"))
	track_max(draw_button(Joypad.input.Z, "#DDDDDD", "Z", "rect", x, y, 0, 30, 21, 59, nil, nil, "Arial"))
	track_max(draw_button(Joypad.input.Cleft, "#FFFF00", "3", "ellipse", x, y, 116, 47, 21, 21, 8, 7, "Marlett"))
	track_max(draw_button(Joypad.input.Cright, "#FFFF00", "4", "ellipse", x, y, 155, 47, 21, 21, 9, 7, "Marlett"))
	track_max(draw_button(Joypad.input.Cup, "#FFFF00", "5", "ellipse", x, y, 135, 28, 21, 21, 8, 8, "Marlett"))
	track_max(draw_button(Joypad.input.Cdown, "#FFFF00", "6", "ellipse", x, y, 135, 68, 21, 21, 8, 8, "Marlett"))

	return { x = x, y = y, width = 0, height = max_bottom - y }
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
			return {
				text = active and "Frame: " .. emu.samplecount() or "No movie playing",
				size = Drawing
					.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return { text = "Yaw (Facing): " .. Memory.Mario.FacingYaw, size = Drawing.LARGE_FONT_SIZE }
		end,
		function(y)
			return { text = "Yaw (Intended): " .. Memory.Mario.IntendedYaw, size = Drawing.SMALL_FONT_SIZE }
		end,
		function(y)
			return {
				text = "H Spd: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed), 3),
				size = Drawing.LARGE_FONT_SIZE
			}
		end,
		function(y)
			return {
				text = "H Sliding Spd: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 2),
				size = Drawing
					.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return { text = "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 2), size = Drawing.SMALL_FONT_SIZE }
		end,
		function(y)
			local spd_eff = Engine.GetSpeedEfficiency()
			local text
			if spd_eff > 100000 then
				text = "Spd Efficiency: ∞%"
			else
				text = string.format("Spd Efficiency: %.2f%%", Engine.GetSpeedEfficiency())
			end
			return { text = text, size = Drawing.SMALL_FONT_SIZE }
		end,
		function(y)
			return { text = "Y Spd: " .. speed, size = Drawing.LARGE_FONT_SIZE }
		end,
		function(y)
			return {
				text = "Mario X: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2),
				size =
					Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				text = "Mario Y: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2),
				size =
					Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				text = "Mario Z: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2),
				size =
					Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return { text = "Action: " .. Engine.GetCurrentAction(), size = Drawing.MEDIUM_FONT_SIZE }
		end
	}

	local BIG = 30
	local SMALL = 20

	local spacing = { 0, BIG, SMALL, BIG, SMALL, SMALL, SMALL, BIG, SMALL, SMALL, SMALL, BIG }

	for i = 1, #spacing, 1 do
		spacing[i] = spacing[i] * Drawing.scale
	end

	local y = y_0

	local width = Drawing.initial_size.width + Drawing.effective_width_offset - x - 10
	for i = 1, #elements do
		y = y + spacing[i]
		local result = elements[i](y)
		BreitbandGraphics.draw_text2({
			text = result.text,
			rectangle = { x = x, y = y, width = width, height = 20 * Drawing.scale },
			font_name = "Arial",
			font_size = result.size + 4,
			color = TEXT_COLOUR,
			align_x = BreitbandGraphics.alignment.start,
			-- fit = true
		})
	end
end
