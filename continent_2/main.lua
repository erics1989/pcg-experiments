
inspect = require("inspect")
require "perlin"
require "fractal"
require "name"

W = 720 / 2
H = 720 / 2

SIZE = 720 / 2

game = {}

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function game.init()
    _state = {}
    
    local f = function (n, x, y)
        return (n(x / (SIZE / 4), y / (SIZE / 4)) + 1) / 2
    end
    _state.elevation = generate_noise(f, W, H)

    generate_attr()

    _state.print_map = true
    _state.print_attr_map = false
    _state.attr = _state.elevation

    _state.generate_name = name.init("japanese_cities")
end

function generate_noise(bias, w, h)
    local n = fractal.noise(perlin.noise())
    local a = {}
    for x = 1, w do
        a[x] = {}
        for y = 1, h do
            a[x][y] = bias(n, x, y)
        end
    end
    return a
end

function generate_attr()
    local f = function (n, x, y)
        return (n(x / (SIZE / 4), y / (SIZE / 4)) + 1) / 2
    end
    _state.moisture = generate_noise(f, W, H)

    local f = function (n, x, y)
        local v1 = (n(x / (SIZE / 4), y / (SIZE / 4)) + 1) / 2
        local v2 = 1 - math.max(_state.elevation[x][y], 0.5)
        local v3 = fade(1 - (math.abs(y - (H / 2)) / (H / 2)))
        return v1 * 0.25 + v2 * 0.25 + v3 * .5
    end
    _state.temperature = generate_noise(f, W, H)
end

function love.load()
    love.window.setMode(1280, 720)
    game.init()
end

function love.keypressed(k)
    if k == "a" then
        _state.print_map = not _state.print_map
    elseif k == "s" then
        _state.print_attr_map = not _state.print_attr_map
    elseif k == "1" then
        _state.attr = _state.elevation
    elseif k == "2" then
        _state.attr = _state.moisture
    elseif k == "3" then
        _state.attr = _state.temperature
end

function love.draw()
    for x = 1, W do
        for y = 1, H do
            if _state.print_map then
                print_map(x, y)
            end
            if _state.print_attr_map then
                print_attr_map(x, y)
            end
        end
    end
end

function print_map(x, y)
    local h = _state.elevation[x][y]
    local t = _state.temperature[x][y]
    local m = _state.moisture[x][y]
    local c1, c2, c3
    if 0.80 < h then
        c1, c2, c3 = 255, 255, 255
    elseif 0.75 < h then
        if 0.275 < t then
            c1, c2, c3 = 240, 240, 240
        else
            c1, c2, c3 = 255, 255, 255
        end
    elseif 0.575 < h then
        if 0.70 < t then
            if 0.55 < m then
                c1, c2, c3 = 20, 180, 0
            elseif 0.55 < m then
                c1, c2, c3 = 120, 180, 0
            else
                c1, c2, c3 = 240, 200, 120
            end
        elseif 0.325 < t then
            if 0.40 < m then
                c1, c2, c3 = 80, 160, 80
            else
                c1, c2, c3 = 180, 200, 120
            end
        elseif 0.275 < t then
            c1, c2, c3 = 180, 200, 180
        else
            c1, c2, c3 = 255, 255, 255
        end
    elseif 0.55 < h then
        c1, c2, c3 = 240, 240, 200
    elseif 0.50 < h then
        if 0.30 < t then
            c1, c2, c3 = 100, 200, 200
        else
            c1, c2, c3 = 240, 240, 240
        end
    else
        c1, c2, c3 = 40, 80, 120
    end
    love.graphics.setColor(c1, c2, c3)
    love.graphics.rectangle("fill", (x - 1) * 2, (y - 1) * 2, 2, 2)
end

function print_attr_map(x, y)
    local z = _state.attr[x][y]
    local c1, c2, c3, a = 255, 255, 255, z * 255
    love.graphics.setColor(c1, c2, c3, a)
    love.graphics.rectangle("fill", (x - 1) * 2, (y - 1) * 2, 2, 2)
end

