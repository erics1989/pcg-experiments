
inspect = require("inspect")
require "perlin"
require "fractal"
require "erosion"
require "name"
inspect = require("inspect")

W = 1280 / 2
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
    
    _state.map = {}
    for x = 1, W do
        _state.map[x] = {}
        for y = 1, H do
            _state.map[x][y] = {}
        end
    end

    local n = fractal.noise(perlin.noise())
    _state.elevation = {}
    for x, c in ipairs(_state.map) do
        _state.elevation[x] = {}
        for y, _ in ipairs(c) do
            local v = (n(x / (SIZE / 4), y / (SIZE / 4)) + 1) / 2
            _state.elevation[x][y] = v
        end
    end

    generate_data()

    _state.print_map = true
    _state.print_data = false
    _state.data = _state.elevation

    _state.generate_name = name.init("japanese_cities")
end

function generate_data()
    local n = fractal.noise(perlin.noise())
    _state.moisture = {}
    for x, c in ipairs(_state.map) do
        _state.moisture[x] = {}
        for y, _ in ipairs(c) do
            local v1 = (n(x / (SIZE / 4), y / (SIZE / 4)) + 1) / 2
            local v = v1
            _state.moisture[x][y] = v
        end
    end

    local n = fractal.noise(perlin.noise())
    _state.temperature = {}
    for x, c in ipairs(_state.map) do
        _state.temperature[x] = {}
        for y, _ in ipairs(c) do
            local v1 = (n(x / (SIZE / 4), y / (SIZE / 4)) + 1) / 2
            local v2 = 1 - math.max(_state.elevation[x][y], 0.5)
            local v3 = fade(1 - (math.abs(y - (H / 2)) / (H / 2)))
            local v = v1 * 0.25 + v2 * 0.25 + v3 * .5
            _state.temperature[x][y] = v
        end
    end
end

function love.load()
    love.window.setMode(1280, 720)
    game.init()
end

function love.keypressed(k)
    if k == "q" then
        erosion.rain(_state.elevation, 10000)
        print("eroded")
    elseif k == "w" then
        generate_data()
    elseif k == "a" then
        _state.print_map = not _state.print_map
    elseif k == "s" then
        _state.print_data = not _state.print_data
    elseif k == "1" then
        _state.data = _state.elevation
    elseif k == "2" then
        _state.data = _state.moisture
    elseif k == "3" then
        _state.data = _state.temperature
    elseif k == "space" then
        print(_state.generate_name())
    end
end

function love.mousepressed(px, py, b)
    local x = math.floor(px / 2) + 1
    local y = math.floor(py / 2) + 1
end

function love.draw()
    for x = 1, W do
        for y = 1, H do
            if _state.print_map then
                print_map(x, y)
            end
            if _state.print_data then
                print_data(x, y)
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

function print_data(x, y)
    local z = _state.data[x][y]
    local c1, c2, c3, a = 255, 255, 255, z * 255
    love.graphics.setColor(c1, c2, c3, a)
    love.graphics.rectangle("fill", (x - 1) * 2, (y - 1) * 2, 2, 2)
end

