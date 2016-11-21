
pp = require("inspect")

require("glue")
require("cc")

prefecture_colors = {
    { 181, 137, 0 },
    { 203, 75, 22 },
    { 220, 50, 47 },
    { 211, 54, 130 },
    { 108, 113, 196 },
    { 38, 139, 210 },
    { 42, 161, 152 },
    { 133, 153, 0 }
}

W = 720 / 2
H = 720 / 2

function init()
    _state = {}
    _state.centers = {}

    generate_prefecture_map()

    _option = {}
    _option.draw_prefecture_map = true
    _option.draw_centers = true
    print("init")
end

function generate_map(f)
    local a = {}
    for x = 1, W do
        a[x] = {}
        for y = 1, H do
            a[x][y] = f(x, y)
        end
    end
    return a
end

function generate_prefecture_map()
    local f = function (x, y)
        local point = { x = x, y = y }
        local compare = function (a, b)
            return glue.dist_e(point, a) - glue.dist_e(point, b)
        end
        return glue.list.min(_state.centers, compare)
    end
    _state.prefecture_map = generate_map(f)
    
    local f = function (x, y)
        local point = { x = x, y = y }
        local compare = function (a, b)
            return glue.dist_e(point, a) - glue.dist_e(point, b)
        end
        local centers = glue.list.sort(_state.centers, compare)
        if centers[2] then
            local dist1 = glue.dist_e(point, centers[1])
            local dist2 = glue.dist_e(point, centers[2])
            if math.abs(dist2 - dist1) <= 1 then
                return true
            end
        end
        return false
    end
    _state.prefecture_border_map = generate_map(f)
    
    print("generate_prefecture_map")
end

function generate_center()
    local x = love.math.random(W)
    local y = love.math.random(H)
    local center = {
        x = x,
        y = y,
        no = #_state.centers + 1
    }
    table.insert(_state.centers, center)
    generate_prefecture_map()
    print("generate_center")
end

--

function love.load()
    love.window.setMode(720, 720)
    init()
end

function love.keypressed(k)
    if k == "q" then
        generate_center()
    end
end

function love.mousepressed(px, py, k)
    if k == 1 then
        local x = math.floor(px / 2) + 1
        local y = math.floor(py / 2) + 1
        local data = {}
        data.x = x
        data.y = y
        data.prefecture_map = _state.prefecture_map[x][y]
        print(pp(data))
    elseif k == 2 then
        print(pp(_state.centers))
    end
end

function love.draw()
    if _option.draw_prefecture_map then
        for x = 1, W do
            for y = 1, H do
                local prefecture = _state.prefecture_map[x][y]
                local prefecture_border =
                    _state.prefecture_border_map[x][y]
                if prefecture and prefecture_border == false then
                    local no = prefecture.no
                    local color = prefecture_colors[((no - 1) % 8) + 1]
                    draw_point(color, x, y)
                end
            end
        end
    end

    if _option.draw_prefecture_border_map then
        for x = 1, W do
            for y = 1, H do
                local prefecture = _state.prefecture_map[x][y]
                if prefecture then
                    local no = prefecture.no
                    local color = prefecture_colors[((no - 1) % 8) + 1]
                    draw_point(color, x, y)
                end
            end
        end
    end

    if _option.draw_centers then
        for _, center in ipairs(_state.centers) do
            draw_point(cc.white, center.x, center.y)
        end
    end
end

function draw_point(color, x, y)
    local px = (x - 1) * 2
    local py = (y - 1) * 2
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", px, py, 2, 2)
end

