local sys = {}

sys.defaults = {
    name = 'System',
    interval = 1,

    top = 10,
    left = 10,
    width = 210,
    height = 215,

    color = 0xff7f00,
    transparency = 0.3,
    radius = 10,
    background_image = nil,

    title_x_offset = 5,
    title_y_offset = 20,
    title_font = 'Sans',
    title_font_size = 16,
    title_font_color = 0x5cd65c,
    label_font = 'Sans',
    label_font_size = 12,
    label_font_color = 0x8ae28a,

    bar_foreground = 0xf5cd65c,
    bar_background = 0x0B8904,
    ok_color = 0x5cd65c,
    warn_color = 0xffd24c,
    error_color = 0xff4c4c,

    -- Specific to this module
    num_cpus = 4,
    monitor_paths = {'/var', '/usr', '/home', '/usr/local'},
    memory_warn_pct = 75,
    memory_error_pct = 90,
    swap_warn_pct = 10,
    swap_error_pct = 25,
    disk_warn_pct = 75,
    disk_error_pct = 90,
    cpu_warn_pct = 90,
    cpu_error_pct = 95,

    cpu_ring_background_color = 0x0B8904,
    cpu_ring_background_alpha = 0.2,
    mem_ring_background_color = 0x0B8904,
    mem_ring_background_alpha = 0.2,
    disk_ring_background_color = 0x0B8904,
    disk_ring_background_alpha = 0.2,
    net_ring_background_color = 0x0B8904,
    net_ring_background_alpha = 0.2,

    ring_thickness = 7,
    small_ring_thickness = 4,
    small_ring_separator = 2,
    ring_separator = 4,
}

function sys.draw(cr, ws, gs, cache)

    local function make_color_range(cur_v, min_v, max_v, alpha)
        if max_v - min_v == 0 then
            max_v = max_v + 0.01
        end
        local red = (cur_v - min_v)/(max_v - min_v)
        local green = 1 - red
        return red, green, 0, alpha
    end

    local function get_value(name, arg)
        str = string.format('${%s %s}', name, arg)
        str = conky_parse(str)

        value = tonumber(str)
        if value == nil then
            return 0
        end
        if value > 100 then
            value = 100
        end
        pct = value / 100
        return pct
    end

    local function cpu(cr, ws, gs, x, y, r)
        cpu_ring = {
            bg_colour   = 0x0B8904,
            bg_alpha    = 0.2,
            fg_colour   = ws.ok_color,
            fg_alpha    = 0.8,
            x           = x,
            y           = y,
            radius      = r,
            thickness   = ws.ring_thickness,
            start_angle = -90,
            end_angle   = 180,
            warn_pct = ws.cpu_warn_pct,
            error_pct = ws.cpu_error_pct,
            warn_color = ws.warn_color,
            error_color = ws.error_color,
        }
        draw.draw_ring(cr, get_value('cpu', 'cpu0'), cpu_ring)
        local cur_r = r - ws.ring_thickness - ws.ring_separator
        for i = 1, ws.num_cpus do
            cpu_ring = {
                bg_colour   = 0x0B8904,
                bg_alpha    = 0.2,
                fg_colour   = ws.ok_color,
                fg_alpha    = 0.8,
                x           = x,
                y           = y,
                radius      = cur_r,
                thickness   = ws.small_ring_thickness,
                start_angle = -90,
                end_angle   = 180,
                warn_pct = ws.cpu_warn_pct,
                error_pct = ws.cpu_error_pct,
                warn_color = ws.warn_color,
                error_color = ws.error_color,
            }
            draw.draw_ring(cr, get_value('cpu', 'cpu' .. i), cpu_ring)
            cur_r = cur_r - ws.small_ring_thickness - ws.small_ring_separator
        end

        cairo_select_font_face(cr, ws.label_small_font, ws.label_small_font_slant,
                               ws.label_small_font_weight);
        cairo_set_font_size(cr, ws.label_small_font_size)
        cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                    ws.label_small_font_transparency))

        local label0 = 'CPU'
        local label1 = conky_parse('${freq}')
        local label2 = conky_parse('${exec sensors | grep "Core 0:" | cut -f 2 -d "+" | cut -f 1 -d " "}')
        local label3 = conky_parse('${exec sensors | grep "Core 1:" | cut -f 2 -d "+" | cut -f 1 -d " "}')
        local value2 = string.gmatch(label2, '[0-9.]+')()
        local value3 = string.gmatch(label3, '[0-9.]+')()
        if value2 ~= nil then
            value2 = tonumber(value2)
        else
            value2 = 0
        end
        if value3 ~= nil then
            value3 = tonumber(value2)
        else
            value3 = 0
        end
        local extents=cairo_text_extents_t:create()
        tolua.takeownership(extents)
        cairo_text_extents(cr, label0, extents)
        local h = extents.height
        local w = extents.width
        tolua.releaseownership(extents)
        cairo_move_to(cr, x - w - ws.gap_size*2, y + h + h/2)
        cairo_show_text(cr, label0)
        cairo_stroke(cr)

        local extents=cairo_text_extents_t:create()
        tolua.takeownership(extents)
        cairo_text_extents(cr, label1, extents)
        local h = extents.height
        local w = extents.width
        tolua.releaseownership(extents)
        cairo_move_to(cr, x - w - ws.gap_size*2, y + h*2 + h/2 + ws.gap_size)
        cairo_show_text(cr, label1)
        cairo_stroke(cr)

        extents=cairo_text_extents_t:create()
        tolua.takeownership(extents)
        cairo_text_extents(cr, label2, extents)
        h = extents.height
        w = extents.width
        tolua.releaseownership(extents)
        if value2 > 80 then
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.error_color,
                                                        ws.label_small_font_transparency))
        elseif value2 > 70 then
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.warn_color,
                                                        ws.label_small_font_transparency))
        else
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                        ws.label_small_font_transparency))
        end
        cairo_move_to(cr, x - w - ws.gap_size*2, y + h*3 + ws.gap_size*2 + h/2)
        cairo_show_text(cr, label2)
        cairo_stroke(cr)

        extents=cairo_text_extents_t:create()
        tolua.takeownership(extents)
        cairo_text_extents(cr, label3, extents)
        h = extents.height
        w = extents.width
        tolua.releaseownership(extents)
        if value3 > 80 then
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.error_color,
                                                        ws.label_small_font_transparency))
        elseif value3 > 70 then
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.warn_color,
                                                        ws.label_small_font_transparency))
        else
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                        ws.label_small_font_transparency))
        end
        cairo_move_to(cr, x - w - ws.gap_size*2, y + h*4 + ws.gap_size*3 + h/2)
        cairo_show_text(cr, label3)
        cairo_stroke(cr)

        cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                    ws.label_small_font_transparency))


    end

    local function mem(cr, ws, gs, x, y, r)
        mem_ring = {
            bg_colour   = 0x0B8904,
            bg_alpha    = 0.2,
            fg_colour   = ws.ok_color,
            fg_alpha    = 0.8,
            x           = x,
            y           = y,
            radius      = r,
            thickness   = ws.ring_thickness,
            start_angle = -90,
            end_angle   = 180,
            warn_pct = ws.memory_warn_pct,
            error_pct = ws.memory_error_pct,
            warn_color = ws.warn_color,
            error_color = ws.error_color,
        }
        swap_ring = {
            bg_colour   = 0x0B8904,
            bg_alpha    = 0.2,
            fg_colour   = ws.ok_color,
            fg_alpha    = 0.8,
            x           = x,
            y           = y,
            radius      = r - ws.ring_thickness - ws.ring_separator,
            thickness   = ws.ring_thickness,
            start_angle = -90,
            end_angle   = 180,
            warn_pct = ws.swap_warn_pct,
            error_pct = ws.swap_error_pct,
            warn_color = ws.warn_color,
            error_color = ws.error_color,
        }

        draw.draw_ring(cr, get_value('memperc', ''), mem_ring)
        draw.draw_ring(cr, get_value('swapperc', ''), swap_ring)

        cairo_select_font_face(cr, ws.label_small_font, ws.label_small_font_slant,
                               ws.label_small_font_weight);
        cairo_set_font_size(cr, ws.label_small_font_size)
        cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                    ws.label_small_font_transparency))
        local extents=cairo_text_extents_t:create()
        tolua.takeownership(extents)
        cairo_text_extents(cr, 'RAM', extents)
        local h = extents.height
        local w = extents.width
        tolua.releaseownership(extents)
        cairo_move_to(cr, x - ws.gap_size*2 - w, y + r + h/2)
        cairo_show_text(cr, 'RAM')
        cairo_stroke(cr)

        extents=cairo_text_extents_t:create()
        tolua.takeownership(extents)
        cairo_text_extents(cr, 'Swap', extents)
        h = extents.height
        w = extents.width
        tolua.releaseownership(extents)
        cairo_move_to(cr, x - ws.gap_size*2 - w,
                      y + r - ws.ring_thickness - ws.ring_separator + h/2)
        cairo_show_text(cr, 'Swap')
        cairo_stroke(cr)

        local avg_01 = tonumber(conky_parse('${loadavg 1}'))
        local avg_05 = tonumber(conky_parse('${loadavg 2}'))
        local avg_15 = tonumber(conky_parse('${loadavg 3}'))
        if cache['max_avg'] == nil then
            cache['max_avg'] = 2 -- Set a default max value
        end
        if avg_01 > cache['max_avg'] then
            cache['max_avg'] = avg_01
            print("Max load avg is now " .. avg_01)
        end
        if avg_05 > cache['max_avg'] then
            cache['max_avg'] = avg_05
            print("Max load avg is now " .. avg_05)
        end
        if avg_15 > cache['max_avg'] then
            cache['max_avg'] = avg_15
            print("Max load avg is now " .. avg_15)
        end
        if cache['min_avg'] == nil then -- or cache['min_avg'] == 0 then
            cache['min_avg'] = 9999
        end
        if avg_01 < cache['min_avg'] then
            cache['min_avg'] = avg_01
            print("Min load avg is now " .. avg_01)
        end
        if avg_05 < cache['min_avg'] then
            cache['min_avg'] = avg_05
            print("Min load avg is now " .. avg_05)
        end
        if avg_15 < cache['min_avg'] then
            cache['min_avg'] = avg_15
            print("Min load avg is now " .. avg_15)
        end

        cairo_set_source_rgba(cr, make_color_range(avg_15, cache['min_avg'], cache['max_avg'],
                                                   ws.label_small_font_transparency))
        cairo_set_line_width(cr, ws.small_ring_thickness - 1)
        cairo_arc(cr, x, y, ws.small_ring_thickness*3.5, 0, 2*math.pi)
        cairo_stroke(cr)

        cairo_set_source_rgba(cr, make_color_range(avg_05, cache['min_avg'], cache['max_avg'],
                                                   ws.label_small_font_transparency))
        cairo_arc(cr, x, y, ws.small_ring_thickness*2.5, 0, 2*math.pi)
        cairo_stroke(cr)

        cairo_set_source_rgba(cr, make_color_range(avg_01, cache['min_avg'], cache['max_avg'],
                                                   ws.label_small_font_transparency))
        cairo_arc(cr, x, y, ws.small_ring_thickness*1.5, 0, 2*math.pi)
        cairo_stroke(cr)

    end

    local function disk(cr, ws, gs, x, y, r)
        local cur_r = r

        cairo_select_font_face(cr, ws.label_small_font, ws.label_small_font_slant,
                               ws.label_small_font_weight);
        cairo_set_font_size(cr, ws.label_small_font_size)
        cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                    ws.label_small_font_transparency))

        for d in seq.iter(ws.monitor_paths) do
            disk_ring = {
                bg_colour   = 0x0B8904,
                bg_alpha    = 0.2,
                fg_colour   = ws.ok_color,
                fg_alpha    = 0.8,
                x           = x,
                y           = y,
                radius      = cur_r,
                thickness   = ws.ring_thickness,
                start_angle = -90,
                end_angle   = 180,
                warn_pct = ws.disk_warn_pct,
                error_pct = ws.disk_error_pct,
                warn_color = ws.warn_color,
                error_color = ws.error_color,
            }
            draw.draw_ring(cr, get_value('fs_used_perc', d), disk_ring)

            local extents=cairo_text_extents_t:create()
            tolua.takeownership(extents)
            cairo_text_extents(cr, d, extents)
            local h = extents.height
            local w = extents.width
            tolua.releaseownership(extents)
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                        ws.label_small_font_transparency))
            cairo_move_to(cr, x - ws.gap_size*2 - w, y + cur_r + h/2)
            cairo_show_text(cr, d)
            cairo_stroke(cr)

            cur_r = cur_r - ws.ring_thickness - ws.ring_separator
        end
    end

    local function net(cr, ws, gs, x, y, r)
        local metric = {'downspeedf', 'upspeedf', 'downspeedf', 'upspeedf'}
        local arg = {'eth0', 'eth0', 'wlan0', 'wlan0'}
        local caption = {'e down', 'e up', 'w down', 'w up'}
        local cur_r = r

        cairo_select_font_face(cr, ws.label_small_font, ws.label_small_font_slant,
                               ws.label_small_font_weight);
        cairo_set_font_size(cr, ws.label_small_font_size)
        cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                    ws.label_small_font_transparency))

        for i = 1,4 do
            disk_ring = {
                bg_colour   = 0x0B8904,
                bg_alpha    = 0.2,
                fg_colour   = ws.ok_color,
                fg_alpha    = 0.8,
                x           = x,
                y           = y,
                radius      = cur_r,
                thickness   = ws.ring_thickness,
                start_angle = -90,
                end_angle   = 180,
            }
            draw.draw_ring(cr, get_value(metric[i], arg[i]), disk_ring)

            local extents=cairo_text_extents_t:create()
            tolua.takeownership(extents)
            cairo_text_extents(cr, caption[i], extents)
            local h = extents.height
            local w = extents.width
            tolua.releaseownership(extents)
            cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.label_small_font_color,
                                                        ws.label_small_font_transparency))
            cairo_move_to(cr, x - ws.gap_size*2 - w, y + cur_r + h/2)
            cairo_show_text(cr, caption[i])
            cairo_stroke(cr)

            cur_r = cur_r - ws.ring_thickness - ws.ring_separator
        end
    end

    -- Determine positions and sized of all the system indicators
    local r = (draw.mid_x(ws, gs) - draw.left(ws, gs)) / 2 - ws.gap_size * 2
    local r2 = (draw.mid_y(ws, gs) - draw.top(ws, gs)) /2 - ws.gap_size * 2
    if r2 < r then
        r = r2
    end
    local cpu_x = draw.left(ws, gs) + (draw.mid_x(ws, gs) - draw.left(ws, gs)) / 2
    local cpu_y = draw.top(ws, gs) + (draw.mid_y(ws, gs) - draw.top(ws, gs)) /2
    local mem_x = draw.mid_x(ws, gs) + (draw.right(ws, gs) - draw.mid_x(ws, gs)) / 2
    local mem_y = cpu_y
    local disk_x = cpu_x
    local disk_y = draw.mid_y(ws, gs) + (draw.bottom(ws, gs) - draw.mid_y(ws, gs)) /2
    local net_x = mem_x
    local net_y = disk_y

    cpu(cr, ws, gs, cpu_x, cpu_y, r, extents)
    mem(cr, ws, gs, mem_x, mem_y, r, extents)
    disk(cr, ws, gs, disk_x, disk_y, r, extents)
    net(cr, ws, gs, net_x, net_y, r, extents)

end

return sys
