function fix_timeout(timeout)
    local last_char = string.sub(timeout, string.len(timeout))
    if last_char == 'S' or last_char == 's' then
        timeout = tonumber(string.sub(timeout, 1, string.len(timeout)-1))
    elseif last_char == 'M' or last_char == 'm' then
        timeout = tonumber(string.sub(timeout, 1, string.len(timeout)-1)) * 60
    elseif last_char == 'H' or last_char == 'h' then
        timeout = tonumber(string.sub(timeout, 1, string.len(timeout)-1)) * 60 * 60
    end
    timeout = tonumber(timeout)
    return timeout
end

function fire_timeout(timeout)
    timeout = fix_timeout(timeout)
    local updates = tonumber(conky_parse('${updates}'))
    local time_offset = (updates % timeout)
    if updates == 6 or time_offset == 1 then
        return true
    end
    return false
end

function draw_widget_background(ws, cfg, cr)
    if ws.left == nil or ws.top == nil or ws.width == nil or ws.height == nil then
        print "Missing position information for widget!"
        if ws.left == nil then
            ws.left = 100
        end
        if ws.top == nil then
            ws.top = 100
        end
        if ws.width == nil then
            ws.width = 300
        end
        if ws.height == nil then
            ws.height = 300
        end
    end
    draw.round_rect(cr, ws.left, ws.top,
                    ws.width, ws.height, ws.radius,
                    ws.background_color, ws.transparency)
    local xpos, ypos = ws.left + ws.title_x_offset + cfg.margins.left,
                       ws.top + ws.title_y_offset + cfg.margins.top
    cairo_select_font_face(cr, ws.title_font, ws.title_font_slant, ws.title_font_weight);
    cairo_set_font_size(cr, ws.title_font_size)
    cairo_set_source_rgba(cr, draw.rgb_to_r_g_b(ws.title_font_color, ws.title_transparency))
    cairo_move_to(cr, xpos, ypos)
    cairo_show_text(cr, ws.name)
    cairo_stroke(cr)
end

function prepare_widget(widget_name, widget_settings, widget_code, general_settings)
    -- print("Calling " .. widget_name .. ".prepare")
    local interval = widget_settings['interval']
    interval = fix_timeout(interval)
    if interval > 1 then
        local can_fire = fire_timeout(interval)
        if can_fire == false then
            return false
        end
        if interval > 60 then
            print("Preparing " .. widget_name .. ' (' .. widget_settings['interval'] .. ')')
        end
    end
    if cache.cache[widget_name] == nil then
        cache.cache[widget_name] = {}
    end

    if widget_code['prepare'] == nil then
        print("Widget " .. widget_name .. " has no prepare function!")
        widget_code['prepare'] = function(ws, gs, cache) return cache end
    else
        -- Protect this call
        cache.cache[widget_name] = widget_code.prepare(widget_settings,
                                                       general_settings,
                                                       cache.cache[widget_name])
    end
    return true
end

function draw_widget(widget_name, widget_settings, widget_code, general_settings, cr)
    -- print("Calling " .. widget_name .. ".draw")
    -- print(pretty.write(widget_settings))
    -- print(pretty.write(widget_code))
    draw_widget_background(widget_settings, general_settings, cr)
    if widget_code['draw'] == nil then
        print("Widget " .. widget_name .. " has no draw function!")
        widget_code['draw'] = function(cr) end
    else
        -- Protect this call
        widget_code.draw(cr, widget_settings, general_settings,
                         cache.cache[widget_name])
    end
end

function draw_all_widgets(cfg, loaded, cr)
    for widget_key in seq.list(cfg.config.widgets) do
        prepare_widget(widget_key, cfg.widgets[widget_key], loaded[widget_key],
                       cfg.default)
        draw_widget(widget_key, cfg.widgets[widget_key], loaded[widget_key],
                    cfg.default, cr)
    end
end

function driver(cr, cfg_file)
    if cfg_file == nil then
        cfg_file = './cfg/default.lua'
    end
    --print "in driver"
    -- TODO: pass filename as param  -- !!!!
    if cfg == nil then --  or (cfg and fire_timeout(cfg['config']['config_reload'])) then
        print("Loading config " .. cfg_file)
        cfg = conky_cfg.load_config(cfg_file)
        available = widgets.find_available_widgets(nil)
        loaded = widgets.load_widgets(cfg['config']['widgets'], avaiable)
        cfg = conky_cfg.merge_config(cfg, loaded)
        print("Running configuration: " .. pretty.write(cfg))
    end
    draw_all_widgets(cfg, loaded, cr)
end

function conky_main()
    if conky_window == nil then
        return
    end

    local updates = tonumber(conky_parse('${updates}'))

    if updates == 2 then
        print("Initializing conky aw-2. Waiting for Conky.")
    elseif updates == 5 then
        print("Conky ready. Starting aw-2 widgets.")
    end
    if updates <= 5 then
        return
    end

--    conky_cairo_window_hook()
    if cs == nil or
        cairo_xlib_surface_get_width(cs) ~= conky_window.width or
        cairo_xlib_surface_get_height(cs) ~= conky_window.height then
        if cs then
            cairo_surface_destroy(cs)
        end

        local cs = cairo_xlib_surface_create(conky_window.display,
                conky_window.drawable,
                conky_window.visual,
                conky_window.width,
                conky_window.height)
        local cr = cairo_create(cs)




        --print(pretty.write(y))

--        driver(cr) -- just here for testing. remove later !!!!




        local x = glue.fpcall(driver(cr))
        --print "ok"
--        print pretty.write(x)

        if cr then
            cairo_destroy(cr)
            cr = nil
        end
        if cs then
            cairo_surface_destroy(cs)
            cs = nil
        end
    end
end-- end main function


