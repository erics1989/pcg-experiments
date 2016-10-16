
require "perlin"
require "fractal"
require "erosion"
inspect = require("inspect")

W = 1280 / 2
H = 720 / 2

SIZE = 360 

game = {}

local function lerp(a, b, t)
    return a + (b - a) * t
end

function game.init()
    local noise = fractal.noise(perlin.noise())
    _state = {}
    _state.elevation = {}
    for x = 1, W do
        _state.elevation[x] = {}
        for y = 1, H do
            _state.elevation[x][y] =
                noise(x / (SIZE / 4), y / (SIZE / 4))
        end
    end
    _state.drop = erosion.drop(_state.elevation)
end

function love.load()
    love.window.setMode(1280, 720)
    game.init()
end

function love.keypressed(k)
    if k == "q" then
        _state.drop = erosion.drop(_state.elevation)
    elseif k == "w" then
        erosion.step(_state.elevation, _state.drop)
        print("step")
    elseif k == "e" then
        erosion.rain(_state.elevation, 10000)
        print("eroded")
    end
end

function love.mousepressed(px, py, b)
    local x = math.floor(px / 2) + 1
    local y = math.floor(py / 2) + 1
end

function love.draw()
    for x = 1, W do
        for y = 1, H do
            draw_space(x, y)
        end
    end

    local cursor = _state.cursor
    if cursor then
        local pitch = _state.pitch[cursor.x][cursor.y]
        local px = cursor.x * 2
        local py = cursor.y * 2
        love.graphics.setColor(255, 0, 0)
        love.graphics.setLineWidth(2)
        love.graphics.line(
            px,
            py,
            px + (pitch.x * 100),
            py + (pitch.y * 100)
        )
    end
end

function draw_space(x, y)
    local h = _state.elevation[x][y]
    h = (h + 1) / 2
    local color
    if h > 0.5 then
        color = {
            lerp(238, 133, (h * 2) - 1),
            lerp(232, 153, (h * 2) - 1),
            lerp(213, 0, (h * 2) - 1),
        }
    else
        color = {
            lerp(7, 38, h * 2),
            lerp(54, 139, h * 2),
            lerp(66, 210, h * 2),
        }
    end
    if
        math.floor(_state.drop.x) == x and
        math.floor(_state.drop.y) == y
    then
        color = { 0, 255, 0 }
    end
    
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", (x - 1) * 2, (y - 1) * 2, 2, 2)
end

