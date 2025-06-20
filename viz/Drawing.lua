--
-- Copyright (c) 2025, sm64-viz maintainers, contributors, and original authors (MKDasher, Xander, ShadoXFM)
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

Drawing = {
	TOP_BOTTOM_MARGIN = 20,
	PAD = 10,
	JOY_RADIUS = 0,
	LARGE_FONT_SIZE = 0,
	MEDIUM_FONT_SIZE = 0,
	SMALL_FONT_SIZE = 0,
	TEXT_COLOR = nil,
	BACKGROUND_COLOUR = "#222222",
	FONT = "Cascadia Code",
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
	Drawing.SMALL_FONT_SIZE = 14 * Drawing.scale
	Drawing.MEDIUM_FONT_SIZE = 16 * Drawing.scale
	Drawing.LARGE_FONT_SIZE = 20 * Drawing.scale
	Drawing.JOY_RADIUS = 80 * Drawing.scale
end

local function get_text_color_for_background(color)
	if color.r * 0.299 + color.g * 0.587 + color.b * 0.114 > 148 then
		return BreitbandGraphics.colors.black
	end
	return BreitbandGraphics.colors.white
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

	Drawing.TEXT_COLOR = get_text_color_for_background(BreitbandGraphics.float_to_color(BreitbandGraphics
		.color_to_float(Drawing.BACKGROUND_COLOUR)))

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
		Drawing.BACKGROUND_COLOUR)

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

	BreitbandGraphics.draw_rectangle(rect, Drawing.TEXT_COLOR, 1)
	BreitbandGraphics.fill_ellipse(rect, "#343434")
	BreitbandGraphics.draw_ellipse(rect, Drawing.TEXT_COLOR, 1)
	BreitbandGraphics.draw_line({ x = x, y = y + Drawing.JOY_RADIUS },
		{ x = x + Drawing.JOY_RADIUS * 2, y = y + Drawing.JOY_RADIUS }, Drawing.TEXT_COLOR, 1)
	BreitbandGraphics.draw_line({ x = x + Drawing.JOY_RADIUS, y = y },
		{ x = x + Drawing.JOY_RADIUS, y = y + Drawing.JOY_RADIUS * 2 }, Drawing.TEXT_COLOR, 1)
	BreitbandGraphics.draw_line({ x = x + Drawing.JOY_RADIUS, y = y + Drawing.JOY_RADIUS }, { x = joy_x, y = joy_y },
		"#00FF08", line_width)
	BreitbandGraphics.fill_ellipse(
		{ x = joy_x - tip_size / 2, y = joy_y - tip_size / 2, width = tip_size, height = tip_size }, "#FF0000")

	BreitbandGraphics.draw_text2({
		text = "x: " .. Joypad.input.X,
		rectangle = { x = x + Drawing.JOY_RADIUS * 2 + Drawing.PAD, y = y + Drawing.JOY_RADIUS - 25 * Drawing.scale, width = 100 * Drawing.scale, height = 20 * Drawing.scale },
		font_name = Drawing.FONT,
		font_size = Drawing.MEDIUM_FONT_SIZE,
		color = Drawing.TEXT_COLOR,
		align_x = BreitbandGraphics.alignment.start,
	})
	BreitbandGraphics.draw_text2({
		text = "y: " .. -Joypad.input.Y,
		rectangle = { x = x + Drawing.JOY_RADIUS * 2 + Drawing.PAD, y = y + Drawing.JOY_RADIUS, width = 100 * Drawing.scale, height = 20 * Drawing.scale },
		font_name = Drawing.FONT,
		font_size = Drawing.MEDIUM_FONT_SIZE,
		color = Drawing.TEXT_COLOR,
		align_x = BreitbandGraphics.alignment.start,
	})

	return rect
end

local function draw_button(pressed, active_color, text, shape, origin_x, origin_y, x, y, w, h, textoffset_x,
						   textoffset_y, font)
	local rect = {
		x = origin_x + x * Drawing.scale,
		y = origin_y + y * Drawing.scale,
		width = w * Drawing.scale,
		height = h * Drawing.scale
	}

	local bg_color = Drawing.BACKGROUND_COLOUR

	if shape == "ellipse" then
		if pressed then
			bg_color = active_color
			BreitbandGraphics.fill_ellipse(rect, active_color)
		end
		BreitbandGraphics.draw_ellipse(rect, Drawing.TEXT_COLOR, 1)
	elseif shape == "rect" then
		if pressed then
			bg_color = active_color
			BreitbandGraphics.fill_rectangle(rect, active_color)
		end
		BreitbandGraphics.draw_rectangle(rect, Drawing.TEXT_COLOR, 1)
	end

	if textoffset_x == nil then textoffset_x = 6 end
	if textoffset_y == nil then textoffset_y = 8 end

	BreitbandGraphics.draw_text2({
		text = text,
		rectangle = rect,
		font_name = font,
		font_size = Drawing.MEDIUM_FONT_SIZE,
		color = get_text_color_for_background(BreitbandGraphics.float_to_color(BreitbandGraphics.color_to_float(bg_color))),
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

	track_max(draw_button(Joypad.input.A, "#3366CC", "A", "ellipse", x, y, 82, 60, 29, 29, nil, nil, Drawing.FONT))
	track_max(draw_button(Joypad.input.B, "#009245", "B", "ellipse", x, y, 63, 31, 29, 29, nil, nil, Drawing.FONT))
	track_max(draw_button(Joypad.input.start, "#EE1C24", "S", "ellipse", x, y, 31, 60, 29, 29, nil, nil, Drawing.FONT))
	track_max(draw_button(Joypad.input.R, "#DDDDDD", "R", "rect", x, y, 98, 0, 72, 21, nil, nil, Drawing.FONT))
	track_max(draw_button(Joypad.input.L, "#DDDDDD", "L", "rect", x, y, 9, 0, 72, 21, nil, nil, Drawing.FONT))
	track_max(draw_button(Joypad.input.Z, "#DDDDDD", "Z", "rect", x, y, 0, 30, 21, 59, nil, nil, Drawing.FONT))
	track_max(draw_button(Joypad.input.Cleft, "#FFFF00", "3", "ellipse", x, y, 116, 47, 21, 21, 8, 7, "Marlett"))
	track_max(draw_button(Joypad.input.Cright, "#FFFF00", "4", "ellipse", x, y, 155, 47, 21, 21, 9, 7, "Marlett"))
	track_max(draw_button(Joypad.input.Cup, "#FFFF00", "5", "ellipse", x, y, 135, 28, 21, 21, 8, 8, "Marlett"))
	track_max(draw_button(Joypad.input.Cdown, "#FFFF00", "6", "ellipse", x, y, 135, 68, 21, 21, 8, 8, "Marlett"))

	return { x = x, y = y, width = 0, height = max_bottom - y }
end

function Drawing.drawMiscData(x, y_0)
	local vspd = 0
	if Memory.Mario.VSpeed > 0 then
		vspd = MoreMaths.DecodeDecToFloat(Memory.Mario.VSpeed)
	end

	local elements = {
		function(y)
			local sample = emu.samplecount()
			local active = sample ~= 4294967295
			return {
				header = active and "Frame" or "No movie playing",
				text = active and emu.samplecount() or "",
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Yaw (Facing)",
				text = Memory.Mario.FacingYaw,
				size = Drawing.LARGE_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Yaw (Intended)",
				text = Memory.Mario.IntendedYaw,
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "H Spd",
				text = MoreMaths.round_pad_str(MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed), 3),
				size = Drawing.LARGE_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "H Sliding Spd",
				text = MoreMaths.round_pad_str(Engine.GetHSlidingSpeed(), 2),
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "XZ Movement",
				text = MoreMaths.round_pad_str(Engine.GetDistMoved(), 2),
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			local spd_eff = Engine.GetSpeedEfficiency()
			local text = spd_eff < 100000 and MoreMaths.round_pad_str(Engine.GetSpeedEfficiency(), 2) or "∞"
			return {
				header = "Spd Efficiency (%)",
				text = text,
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Y Spd",
				text = MoreMaths.round_pad_str(vspd, 3),
				size = Drawing.LARGE_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Mario X",
				text = MoreMaths.round_pad_str(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2),
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Mario Y",
				text = MoreMaths.round_pad_str(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2),
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Mario Z",
				text = MoreMaths.round_pad_str(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2),
				size = Drawing.SMALL_FONT_SIZE
			}
		end,
		function(y)
			return {
				header = "Action",
				text = Engine.GetCurrentAction(),
				size = Drawing.MEDIUM_FONT_SIZE
			}
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
		if i > 1 and spacing[i - 1] == BIG * Drawing.scale then
			y = y + 6 * Drawing.scale
		end
		local result = elements[i](y)
		local text = tostring(result.text)
		local header_size = BreitbandGraphics.get_text_size(result.header, result.size, Drawing.FONT)

		local header_color = BreitbandGraphics.color_to_float(Drawing.TEXT_COLOR)
		header_color.a = 0.85

		BreitbandGraphics.draw_text2({
			text = result.header,
			rectangle = { x = x, y = y, width = header_size.width + 1, height = header_size.height },
			font_name = Drawing.FONT,
			font_size = result.size,
			color = header_color,
			align_x = BreitbandGraphics.alignment.start,
		})

		local text_size = BreitbandGraphics.get_text_size(text, result.size, Drawing.FONT)
		local text_rect_x = Drawing.initial_size.width + Drawing.PAD + 4 * Drawing.scale + header_size.width
		local text_rect = {
			x = text_rect_x,
			y = y,
			width = Drawing.size.width - text_rect_x - Drawing.PAD,
			height =
				text_size.height
		}

		BreitbandGraphics.draw_text2({
			text = text,
			rectangle = { x = text_rect.x, y = text_rect.y, width = text_rect.width + 1, height = text_rect.height },
			font_name = Drawing.FONT,
			font_size = result.size,
			color = Drawing.TEXT_COLOR,
			align_x = BreitbandGraphics.alignment['end'],
			fit = true
		})

		if spacing[i] == BIG * Drawing.scale then
			local separator_y = y - (BIG - SMALL) * 0.5 * Drawing.scale
			local separator_color = BreitbandGraphics.color_to_float(Drawing.TEXT_COLOR)
			separator_color.a = 0.1

			BreitbandGraphics.draw_line({
				x = x + Drawing.PAD * 4,
				y = separator_y,
			}, {
				x = x + Drawing.effective_width_offset - Drawing.PAD * 2,
				y = separator_y,
			}, separator_color, 1)
		end
	end
end
