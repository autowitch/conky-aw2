local draw = {}

require 'cairo'

function draw.rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255.,
           ((colour / 0x100) % 0x100) / 255.,
           (colour % 0x100) / 255.,
           alpha
end

function draw.draw_ring(cr, t, pt)
    local w, h=conky_window.width, conky_window.height

    local warn_color = 0xffff00
    local error_color = 0xff0000
    local warn_pct = 101
    local error_pct = 102

    local xc, yc, ring_r, ring_w,sa,ea = pt['x'], pt['y'], pt['radius'], pt['thickness'], pt['start_angle'], pt['end_angle']
    local bgc, bga, fgc, fga = pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']
    if pt['warn_color'] ~= nil then
        warn_color = pt['warn_color']
    end
    if pt['error_color'] ~= nil then
        error_color = pt['error_color']
    end
    if pt['warn_pct'] ~= nil then
        warn_pct = pt['warn_pct']
    end
    if pt['error_pct'] ~= nil then
        error_pct = pt['error_pct']
    end

    if t >= error_pct/100 then
        fgc = error_color
    elseif t >= warn_pct/100 then
        fgc = warn_color
    end

    local angle_0 = sa * (2 * math.pi / 360) - math.pi / 2
    local angle_f = ea * (2 * math.pi / 360) - math.pi / 2
    local t_arc = t * (angle_f - angle_0)

    -- Draw background ring

    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_f)
    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(bgc, bga))
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)

    -- Draw indicator ring

    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_0 + t_arc)
    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(fgc, fga))
    cairo_stroke(cr)
end

function draw.round_rect(cr, x0, y0, w, h, r, colour, alpha)

    local function rgb_to_r_g_b(colour, alpha)
        return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
    end

    cairo_move_to(cr, x0, y0)
    cairo_rel_move_to(cr, r, 0)
    cairo_rel_line_to(cr, w - 2 * r, 0)
    cairo_rel_curve_to(cr, r, 0, r, 0, r, r)
    cairo_rel_line_to(cr, 0, h - 2 * r)
    cairo_rel_curve_to(cr, 0, r, 0, r, -r, r)
    cairo_rel_line_to(cr, -(w-2*r), 0)
    cairo_rel_curve_to(cr, -r, 0, -r, 0, -r, -r)
    cairo_rel_line_to(cr, 0, -(h-2*r))
    cairo_rel_curve_to(cr, 0, -r, 0, -r, r, -r)
    cairo_close_path(cr)

    cairo_set_source_rgba(cr, rgb_to_r_g_b(colour, alpha))
    cairo_fill(cr)

--        cairo_set_source_rgba(cr, 0.0, 1, 0, 0.8)
--        cairo_rectangle (cr, 410, 20, all_val_per, -15)
--        cairo_fill (cr)
end

function draw.left(ws, gs)
    -- Returns left side of widget drawing area
    return ws.left + gs.margins.left
end

function draw.right(ws, gs)
    -- Returns right side of widget drawing area
    return ws.left + ws.width - gs.margins.right
end

function draw.full_top(ws, gs)
    -- Draws outer top (which includes the title) for the widget drawing area
    -- Use this for when you intend to use the title area of the widget when
    -- drawing.
    return ws.top + gs.margins.top
end

function draw.top(ws, gs)
    -- Draws the inner top (which excludes the title). In most cases, use this
    -- for the top. It assumes that you will not be drawing onto the title
    -- itself.
    return draw.full_top(ws, gs) + ws.title_y_offset + ws.gap_size
end

function draw.bottom(ws, gs)
    -- Returns the bottom of the widget drawing area
    return ws.top + ws.height - gs.margins.bottom
end

function draw.mid_x(ws, gs)
    -- Returns the xposition of the widget midpoint
    return draw.left(ws, gs) + (draw.right(ws, gs) - draw.left(ws, gs)) / 2
end

function draw.mid_y(ws, gs)
    -- Returns the y position of the wdiget midpoint (excluding title)
    return draw.top(ws, gs) + (draw.bottom(ws, gs) - draw.top(ws, gs)) / 2
end

function draw.full_mid_y(ws, gs)
    -- Returns the y position of the wdiget midpoint (including title)
    return draw.full_top(ws, gs) + (draw.bottom(ws, gs) - draw.full_top(ws, gs)) / 2
end

function draw.show_widget_grid(cr, ws, gs)

    -- Make sure to call cairo_stroke(cr) after calling this. I don't know
    -- why that is necessary.
    local left = draw.left(ws, gs)
    local right = draw.right(ws, gs)
    local full_top = draw.full_top(ws, gs)
    local top = draw.top(ws, gs)
    local bottom = draw.bottom(ws, gs)
    local mid_x = draw.mid_x(ws, gs)
    local mid_y = draw.mid_y(ws, gs)
    local full_mid_y = draw.full_mid_y(ws, gs)

    cairo_set_line_width(cr, 1)
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(0xff0000, 1))
    cairo_move_to(cr, left, full_top)
    cairo_line_to(cr, right, full_top)
    cairo_line_to(cr, right, bottom)
    cairo_line_to(cr, left, bottom)
    cairo_line_to(cr, left, full_top)
    cairo_stroke(cr)

    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(0xff00ff, 1))
    cairo_move_to(cr, left, top)
    cairo_line_to(cr, right, top)
    cairo_move_to(cr, left, full_mid_y)
    cairo_line_to(cr, right, full_mid_y)
    cairo_stroke(cr)

    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(0xffff00, 1))
    cairo_move_to(cr, mid_x, top)
    cairo_line_to(cr, mid_x, bottom)
    cairo_move_to(cr, left, mid_y)
    cairo_line_to(cr, right, mid_y)
    cairo_stroke(cr)
end


return draw
