local settings = {}

settings.config = {
    width = 1200,         -- Full size of the conky
    height = 980,
    background_img = '',  -- Overal background image
    widgets = {'sys', 'email', 'events', 'clock', 'top'},    -- What widgets to load
    config_reload = '15m',
    margins = {top=10, left=10, right=10, bottom=10},
}

settings.default = {
    transparency = 0.7,
    background_img = '',
    radius = 12,
    title_font = 'Glass TTY VT220',
    title_transparency = 0.6,
    title_x_offset = 0,
    title_y_offset = 16,
    title_font_size = 20,
    -- title_font_color = 0x7cde7c,
    title_font_color = 0x7cff7c,
    label_font = 'Mono',
    label_font_size = 12,
    label_font_color = 0x5cd65c,
    label_font_mono = 'Mono',
    label_font_mono_size = 10,
    label_transparency = 0.6,
    margins = {top=5, left=5, right=5, bottom=5},
    background_color = 0x051005,
    warning_percent = 80,
    error_percent = 90,
    -- bar_background_color = 0x111111,
    -- bar_foreground_color = 0x00ff00,
    -- ok_color = 0x00ff00,
    -- warn_color = 0xffff00,
    -- error_color = 0xff0000,
    gap_size = 3,
    separator_line_color = 0xffffff,
}


settings.widgets = {
    sys = {
        name = "System",
        width = 200,
        height = 215,
        left = 900,
        top = 10,
        background_color = 0x051005,
        label_large_font = 'WenQuanYi Micro Hei Mono',
        label_large_font_size = 14,
        label_large_font_color = 0x5cd65c,
        lavel_small_font = 'WenQuanYi Micro Hei Mono',
        label_small_font_size = 8,
        label_small_font_color = 0x5cd65c,
    },
    top = {
        name = "Top Memory",
        width = 200,
        height = 215,
        left = 900,
        top = 235,
        background_color = 0x051005,
        label_font = 'WenQuanYi Micro Hei Mono',
        label_font_size = 8,
        pct_x_pos = 100,
        pid_x_pos = 150,
    },
    clock = {
        name = "",
        title_y_offset = 16,
        width = 200,
        height = 165,
        left = 900,
        top = 460,
        background_color = 0x051005,
    },
    email = {
        name = "Email",
        width = 200,
        height = 100,
        left = 900,
        top = 635,
        background_color = 0x051005,
    },
    events = {
        name = "Events",
        width = 200,
        height = 100,
        left = 690,
        top = 10,
        background_color = 0x051005,
    },
}


return settings

