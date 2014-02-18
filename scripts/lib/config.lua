local config = {}

config.general_defaults = {
    transparency = 0.3,
    background_img = '',
    radius = 10,
    interval = '30m',

    -- Various font related things

    title_font = 'Sans',
    title_x_offset = 5,
    title_y_offset = 20,
    title_font_size = 16,
    title_font_color = 0xffffff,
    title_font_transparency = 0.6,
    title_font_slant = CAIRO_FONT_SLANT_NORMAL,
    title_font_weight = CAIRO_FONT_WEIGHT_BOLD,

    label_font = 'Sans',
    label_font_size = 10,
    label_font_color = 0xffffff,
    label_font_transparency = 0.6,
    label_font_slant = CAIRO_FONT_SLANT_NORMAL,
    label_font_weight = CAIRO_FONT_WEIGHT_BOLD,
    label_font_mono = 'Mono',
    label_font_mono_size = 10,
    label_font_mono_color = 0xffffff,
    label_font_mono_transparency = 0.6,
    label_font_mono_slant = CAIRO_FONT_SLANT_NORMAL,
    label_font_mono_weight = CAIRO_FONT_WEIGHT_BOLD,

    label_small_font = 'Sans',
    label_small_font_size = 8,
    label_small_font_color = 0xffffff,
    label_small_font_transparency = 0.6,
    label_small_font_slant = CAIRO_FONT_SLANT_NORMAL,
    label_small_font_weight = CAIRO_FONT_WEIGHT_BOLD,
    label_small_font_mono = 'Mono',
    label_small_font_mono_size = 8,
    label_small_font_mono_color = 0xffffff,
    label_small_font_mono_transparency = 0.6,
    label_small_font_mono_slant = CAIRO_FONT_SLANT_NORMAL,
    label_small_font_mono_weight = CAIRO_FONT_WEIGHT_BOLD,

    label_large_font = 'Sans',
    label_large_font_size = 12,
    label_large_font_color = 0xffffff,
    label_large_font_transparency = 0.6,
    label_large_font_slant = CAIRO_FONT_SLANT_NORMAL,
    label_large_font_weight = CAIRO_FONT_WEIGHT_BOLD,
    label_large_font_mono = 'Mono',
    label_large_font_mono_size = 12,
    label_large_font_mono_transparency = 0.6,
    label_large_font_mono_slant = CAIRO_FONT_SLANT_NORMAL,
    label_large_font_mono_weight = CAIRO_FONT_WEIGHT_BOLD,

    margins = {5, 5, 5, 5},
    background_color = 0xf67e16,
    warning_percent = 80,
    error_percent = 90,
    bar_background_color = 0x111111,
    bar_foreground_color = 0x00ff00,
    ok_color = 0x00ff00,
    warn_color = 0xffff00,
    error_color = 0xff0000,
    gap_size = 2,
    separator_line_color = 0xffffff,
}

function config.load_config(filename)
    if filename == nil then
        filename = './cfg/default'
    end

    local filename = stringx.replace(filename, '.lua', '')
    local cfg = require(filename)
    -- print(pretty.write(cfg))

    -- cfg = config.merge_config(cfg)
    return cfg
end

function config.merge_config(cfg, loaded_widgets)

    -- configurations need to be merged to create a full version of the
    -- settings. In order of precedence:
    --     1) Configuration for individual widgets in user config
    --     2) Configuration for defaults in user configurations
    --     3) Individual default widget values
    --     4) General default values

    for widget_key in seq.list(cfg.config.widgets) do
        print("Configuring settings for " .. widget_key)

        -- Create configuration sections for missing widgets
        if cfg.widgets[widget_key] == nil then
            print("    NO CONFIGURATION FOR " .. widget_key .. ". Creating...")
            cfg.widgets[widget_key] = {}
        end

        -- Apply user defaults
        for default_key, default_value in pairs(cfg.default) do
            if cfg.widgets[widget_key][default_key] == nil then
                cfg.widgets[widget_key][default_key] = default_value
            end
        end

        -- Apply widget defaults
        if loaded[widget_key] == nil then
            print("    WIDGET " .. widget_key .. " IS NOT LOADED !!!!")
        elseif loaded[widget_key]['defaults'] == nil then
            print("    WIDGET " .. widget_key .. " DOES NOT HAVE DEFINED DEFAULTS !!!!")
        else
            for default_key, default_value in pairs(loaded[widget_key]['defaults']) do
                if cfg.widgets[widget_key][default_key] == nil then
                    cfg.widgets[widget_key][default_key] = default_value
                end
            end
        end

        -- Apply general defaults
        for default_key, default_value in pairs(config.general_defaults) do
            if cfg.widgets[widget_key][default_key] == nil then
                cfg.widgets[widget_key][default_key] = default_value
            end
        end
    end

    return cfg
end

return config

