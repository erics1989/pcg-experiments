
require("perlin")
require("fractal")
require("erosion")

SIZE = 360 

game = {}

function game.init()
    local noise = fractal.noise(perlin.noise())
    _state = {}
    _state.terrain = {}
    for x = 1, SIZE do
        _state.terrain[x] = {}
        for y = 1, SIZE do
            _state.terrain[x][y] = noise(x / (SIZE / 4), y / (SIZE / 4))
        end
    end
end

function love.load()
    love.window.setMode(720, 720)
    game.init()
end

function love.draw()
    for x = 1, SIZE do
        for y = 1, SIZE do
            draw_space(x, y)
        end
    end
end

function draw_space(x, y)
    local h = _state.terrain[x][y]
    h = (h + 1) / 2
    local color
    if h > 0.5 then
        color = { 255 * h, 255 * h, 255 * h }
    else
        color =  { 38, 139, 210 }
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", (x - 1) * 2, (y - 1) * 2, 2, 2)
end
