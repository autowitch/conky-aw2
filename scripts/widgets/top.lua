local top = {}

top.defaults = {
    name = 'Top Memory',
    interval = 1,

    top = 10,
    left = 10,
    width = 200,
    height = 180,
    memory_warn_pct = 20,
    cpu_warn_pct = 40,

    name_x_pos = 0,
    pct_x_pos = 115,
    pid_x_pos = 170,
}

function top.draw(cr, ws, gs, cache)
    local offset_x = ws.left + gs.margins.left + ws.title_x_offset
    local offset_y = ws.top + gs.margins.top
    local size_y = offset_y + ws.height - gs.margins.bottom
    local mid_y = (ws.height - gs.margins.bottom) / 2
    local inner_size_y = mid_y - ws.title_y_offset
    -- local inner_size_y2 = ws.height - ws.title_y_offset - mid_y - gs.margins.bottom
    -- print(inner_size_y1)
    -- print(inner_size_y2)
    local num_rows = math.floor(inner_size_y / ( ws.label_font_size + ws.gap_size)) - 1

    cairo_select_font_face(cr, ws.title_font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, ws.title_font_size)
    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.title_font_color, ws.title_transparency))

    cairo_move_to(cr, offset_x + ws.title_x_offset, offset_y + mid_y + ws.title_y_offset)
    cairo_show_text(cr, "Top CPU")

    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_font_color, ws.label_transparency))
    local ypos1 = offset_y + ws.title_y_offset + ws.label_font_size + ws.gap_size + ws.gap_size
    local ypos2 = offset_y + mid_y + ws.title_y_offset + ws.label_font_size + ws.gap_size + ws.gap_size
    for i = 1,num_rows do

        local ram = conky_parse('${top_mem name ' .. i .. '}')
        cairo_select_font_face(cr,ws.label_font, CAIRO_FONT_SLANT_NORMAL, 1)
        cairo_set_font_size(cr, ws.label_font_size)
        cairo_move_to(cr, offset_x + ws.name_x_pos, ypos1)
        cairo_show_text(cr, ram)
        local ram_pct = conky_parse('${top_mem mem ' .. i .. '}')
        cairo_move_to(cr, offset_x + ws.pct_x_pos, ypos1)
        cairo_show_text(cr, ram_pct .. '%')
        local ram_pid = conky_parse('${top_mem pid ' .. i .. '}')
        cairo_move_to(cr, offset_x + ws.pid_x_pos, ypos1)
        cairo_show_text(cr, ram_pid)


        local cpu = conky_parse('${top name ' .. i .. '}')
        cairo_move_to(cr, offset_x + ws.name_x_pos, ypos2)
        cairo_show_text(cr, cpu)
        cpu_pct = conky_parse('${top cpu ' .. i .. '}')
        cairo_move_to(cr, offset_x + ws.pct_x_pos, ypos2)
        cairo_show_text(cr, cpu_pct .. '%')
        cpu_pid = conky_parse('${top pid ' .. i .. '}')
        cairo_move_to(cr, offset_x + ws.pid_x_pos, ypos2)
        cairo_show_text(cr, cpu_pid)

        ypos1 = ypos1 + ws.label_font_size + ws.gap_size
        ypos2 = ypos2 + ws.label_font_size + ws.gap_size
    end



--     cairo_set_line_width(cr, 1)
--     cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
--     cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(0xff0000, 1))
--     cairo_move_to(cr, offset_x, offset_y) -- cairo_rel_move_to
--     cairo_rel_line_to(cr, ws.width - gs.margins.right - gs.margins.left, 0) -- cairo_line_to
--     cairo_rel_line_to(cr, 0, ws.height - gs.margins.bottom - gs.margins.top) -- cairo_line_to
--     cairo_rel_line_to(cr, -1 * (ws.width - gs.margins.right - gs.margins.left), 0) -- cairo_line_to
--     cairo_rel_line_to(cr, 0, -1 * (ws.height - gs.margins.bottom - gs.margins.top)) -- cairo_line_to
--     cairo_stroke(cr)

--     cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(0xffff00, 1))
--     cairo_move_to(cr, offset_x, offset_y + mid_y) -- cairo_rel_move_to
--     cairo_rel_line_to(cr, ws.width - gs.margins.right - gs.margins.left, 0) -- cairo_line_to
    cairo_stroke(cr)
end

return top

