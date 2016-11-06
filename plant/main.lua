
SIZE = { w = 1280, h = 720 }

GRAMMAR = {
    F = "F[LF]F[RF][F]"
}

parser = {
    F = function ()
        local dx = math.cos(_state.turtle.dir) * 8
        local dy = math.sin(_state.turtle.dir) * 8
        love.graphics.line(
            _state.turtle.x,
            _state.turtle.y,
            _state.turtle.x + dx,
            _state.turtle.y + dy
        )
        _state.turtle.x = _state.turtle.x + dx
        _state.turtle.y = _state.turtle.y + dy
    end,
    L = function ()
        _state.turtle.dir = _state.turtle.dir + math.pi * 1/8
    end,
    R = function ()
        _state.turtle.dir = _state.turtle.dir - math.pi * 1/8
    end,
    ["["] = function ()
        local save = {
            x = _state.turtle.x,
            y = _state.turtle.y,
            dir = _state.turtle.dir
        }
        table.insert(_state.stack, save)
    end,
    ["]"] = function ()
        local save = table.remove(_state.stack)
        _state.turtle.x = save.x
        _state.turtle.y = save.y
        _state.turtle.dir = save.dir
    end
}

function parser.parse(str)
    for i = 1, #str do
        local c = str:sub(i, i)
        parser[c]()
    end
end

function love.load()
    love.window.setMode(SIZE.w, SIZE.h)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    _state = {}
    _state.str = "[F]"
    _state.stack = {}
    _state.turtle = { x = 1280 * 1/2, y = 720, dir = math.pi * 3/2 }
end

function love.keypressed(k)
    if k == "space" then
        _state.str = expand(GRAMMAR, _state.str)
    end
end

function expand(grammar, str)
    local tokens = {}
    for i = 1, #str do
        local c = str:sub(i, i)
        table.insert(tokens, (grammar[c] or c))
    end
    local str2 = table.concat(tokens, "")
    print(str2)
    return str2
end

function love.draw()
    parser.parse(_state.str, cursor)
end
