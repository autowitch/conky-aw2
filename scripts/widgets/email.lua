local email = {}

email.defaults = {
    name = 'Email',
    interval = '15m',
}

function email.prepare(ws, gs, cache)
    print("Email check!")
end

function email.draw(cr, ws, gs, cache)

    local updates = tonumber(conky_parse('${updates}'))
    if updates > 5 then
    end
end

return email


