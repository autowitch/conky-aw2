local widgets = {}


function widgets.load_widgets(widget_names, available, path)
    if path == nil then
        path = './scripts/widgets'
    end
    loaded_widgets= {}
    for x in seq.list(widget_names) do
        -- if not x in available then -- !!!
        --     print "X"
        -- end
        print("Loading widget: " .. x)
        loaded_widgets[x] = require(path .. '/' .. x)
    end
    return loaded_widgets
end

function widgets.find_available_widgets(path)
    if path == nil then
        path = './scripts/widgets'
    end

    local widget_name_list = dir.getfiles(path, '*.lua')
    widget_name_list = seq.map(
            function(x)
                x = stringx.replace(x, path, '')
                x = stringx.replace(x, '/', '', 1)
                return stringx.replace(x, '.lua', '')
            end,
            widget_name_list
    ):copy()
    print("Available widgets: " .. pretty.write(widget_name_list))
    return widget_name_list
end

function widgets.get_default_config(widget_name)
end

return widgets


