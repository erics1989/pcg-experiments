
pp = require("inspect")

require("glue")
list = require("list")
pq = require("pq")
require("cc")
require("perlin")
require("fractal_noise_f")
require("generate_river_map")
require("generate_distance_map")
require("generate_discrete_river_map")
require("generate_biome_map")
require("generate_name_f")
require("generate_name")

prefecture_color = {
    { 181, 137, 0 },
    { 203, 75, 22 },
    { 220, 50, 47 },
    { 211, 54, 130 },
    { 108, 113, 196 },
    { 38, 139, 210 },
    { 42, 161, 152 },
    { 133, 153, 0 },
}

prefecture_name_corpus = {
    "corpus/china_clean.txt",
    "corpus/america_clean.txt",
    "corpus/brazil_clean.txt",
    "corpus/russia_clean.txt",
    "corpus/iran_clean.txt",
    "corpus/nigeria_clean.txt",
    "corpus/india_clean.txt",
    "corpus/germany_clean.txt",
}

biome_color = {
    { 8, 75, 48 },
    { 81, 122, 18 },
    { 255, 210, 149 },
    { 43, 138, 66 },
    { 111, 145, 33 },
    { 191, 130, 73 },
    { 137, 143, 104 },
    { 242, 243, 248 }
}

W = 640
H = 320
SCALE = 2
WATER_LEVEL = 0.55
RIVER_MAX = 100

function init()
    _option = {}
    _option.draw = draw_map
    _option.color = color_elevation
    _option_draw_branches = false

    generate_everything()
end

function generate_everything()
    _state = {}
    _state.points2d = {}
    _state.points = {}
    for x = 1, W do
        _state.points2d[x] = {}
        for y = 1, H do
            local point = { x = x, y = y }
            _state.points2d[x][y] = point
            table.insert(_state.points, point)
        end
    end

    generate_elevation_map()
    generate_temperature_map()
    generate_rain_map()
    generate_river_map()
    generate_discrete_river_map()
    generate_biome_map()

    generate_name_generators()
    generate_centers_and_prefectures()
    generate_prefecture_map()
    generate_branches()
    generate_branch_map()

    _state.pivot = 0
    print("done!")
end

function generate_name_generators()
    print("generating name generators")
    _state.generate_name_fs = {}
    for i, filename in ipairs(prefecture_name_corpus) do
        _state.generate_name_fs[i] = generate_name_f(filename)
    end
end

function generate_elevation_map()
    print("generating elevation map")
    local noise_f = fractal_noise_f(8, 4)
    local f = function (x, y)
        local n = noise_f(x, y)
        return (n + 1) / 2
    end
    _state.elevation_map = generate_map(f)
end

function generate_temperature_map()
    print("generating temperature map")
    local noise_f = fractal_noise_f(8, 4)
    local f = function (x, y)
        local a = (noise_f(x, y) + 1) / 2
        local b = 1 - math.max(_state.elevation_map[x][y], WATER_LEVEL)
        local dist = math.abs(y - H / 2) / (H / 2)
        local c = glue.curve(1 - dist)
        return 0.2 * a + 0.3 * b + 0.5 * c
    end
    _state.temperature_map = generate_map(f)
end

function generate_rain_map()
    print("generating rain map")
    local noise_f = fractal_noise_f(8, 4)
    local f = function (x, y)
        local z = noise_f(x, y)
        z = (z + 1) / 2
        z = glue.curve(z)
        return z
    end
    _state.rain_map = generate_map(f)
end

function generate_centers_and_prefectures()
    _state.centers = {}
    _state.branches = {}
    generate_branch_dist_map()
    generate_center_score_map()
    for i = 1, 8 do
        print(string.format("generating capitals (%d)", i))
        local point = list.max(_state.points, compare_center_score)
        local center = {}
        center.prefecture = #_state.centers + 1
        center.name = generate_name(center.prefecture)
        center.x = point.x
        center.y = point.y
        center.dist_map = generate_dist_map({ point }, step_cost)
        table.insert(_state.centers, center)
        table.insert(_state.branches, center)
        update_branch_dist_map(center)
        generate_center_score_map()
    end
end

function generate_prefecture_map()
    print("generating prefecture map")
    local f = function (x, y)
        local compare = function (a, b)
            return a.dist_map[x][y] < b.dist_map[x][y]
        end
        local center = list.min(_state.centers, compare)
        return center.prefecture
    end
    _state.prefecture_map = generate_map(f)
end

function generate_branches()
    generate_branch_score_map()
    for i = 1, 16 do
        print(string.format("generating cities (%d)", i))
        local point = list.max(_state.points, compare_branch_score)
        local prefecture = _state.prefecture_map[point.x][point.y]
        local branch = {}
        branch.name = generate_name(prefecture)
        branch.x = point.x
        branch.y = point.y
        branch.dist_map = generate_dist_map({ point }, step_cost)
        table.insert(_state.branches, branch)
        update_branch_dist_map(branch)
        generate_branch_score_map()
    end
end

function generate_branch_map()
    print("generating branch map")
    local f = function (x, y)
        return false
    end
    _state.branch_map = generate_map(f)
    for _, branch in ipairs(_state.branches) do
        _state.branch_map[branch.x][branch.y] = branch
    end
end

function get_point(x, y)
    x = (x - 1) % W + 1
    y = (y - 1) % H + 1
    return _state.points2d[x][y]
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

function step_cost(a, b)
    local x = (a.x == b.x or a.y == b.y) and 1 or 1.4
    if  _state.elevation_map[a.x][a.y] >
        _state.elevation_map[b.x][b.y]
    then
        x = x * 2
    end
    if _state.elevation_map[b.x][b.y] <= WATER_LEVEL then
        x = x * 16
    end
    return x
end

function center_score(x, y)
    if  x < 32 or W - 32 < x or y < 32 or H - 32 < y then
        return 0
    end
    if _state.elevation_map[x][y] < WATER_LEVEL then
        return 0
    end
    if _state.branch_dist_map[x][y] < 128 then
        return 0
    end
    local score = 0
    score = score + _state.river_map[x][y]
    return score
end

function generate_center_score_map()
    _state.center_score_map = generate_map(center_score)
end

function compare_center_score(a, b)
    return
        _state.center_score_map[a.x][a.y] <
        _state.center_score_map[b.x][b.y]
end

function branch_score(x, y)
    if  x < 32 or W - 32 < x or y < 32 or H - 32 < y then
        return 0
    end
    if _state.elevation_map[x][y] < WATER_LEVEL then
        return 0
    end
    if _state.branch_dist_map[x][y] < 64 then
        return 0
    end
    local score = 0
    score = score + _state.river_map[x][y]
    return score
end

function generate_branch_score_map()
    _state.branch_score_map = generate_map(branch_score)
end

function compare_branch_score(a, b)
    return
        _state.branch_score_map[a.x][a.y] <
        _state.branch_score_map[b.x][b.y]
end

function generate_branch_dist_map()
    local f = function (x, y)
        local dist_f = function (branch)
            return branch.dist_map[x][y]
        end
        local dists = list.map(_state.branches, dist_f)
        return list.min(dists) or math.huge
    end
    _state.branch_dist_map = generate_map(f)
end

function update_branch_dist_map(src)
    update_dist_map(_state.branch_dist_map, { src }, step_cost)
end

--

function love.load()
    love.window.setMode(1280, 720)
    local font = love.graphics.newFont("Inconsolata.otf", 24)
    love.graphics.setFont(font)
    init()
end

function love.keypressed(k)
    if k == "1" then
        _option.color = color_elevation
    elseif k == "2" then
        _option.color = color_temperature
    elseif k == "3" then
        _option.color = color_rain
    elseif k == "4" then
        _option.color = color_river
    elseif k == "5" then
        _option.color = color_satellite
    elseif k == "6" then
        _option.color = color_political
    elseif k == "q" then
        _option.draw = draw_map
    elseif k == "w" then
        _option.draw = draw_globe
    elseif k == "e" then
        _option.draw_branches = not _option.draw_branches
    end
end

function love.update(t)
    _state.pivot = _state.pivot + 16 * t
end

function love.mousepressed(px, py, k)
    if k == 1 then
        local x = math.floor(px / 2) + 1
        local y = math.floor(py / 2) + 1
        if 1 <= x and x <= W and 1 <= y and y <= H then
            local data = {}
            data.x = x
            data.y = y
            data.score = center_score(x, y)
            -- data.prefecture_map = _state.prefecture_map[x][y]
            print(pp(data))
        end
    end
end

function love.draw()
    _option.draw()
end

function draw_map()
    for x = 1, W do
        for y = 1, H do
            local color = _option.color(x, y)
            if color then
                local px = (x - 1) * SCALE
                local py = (y - 1) * SCALE + 40
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", px, py, SCALE, SCALE)
            end
        end
    end
    if _option.draw_branches then
        love.graphics.setColor(255, 255, 255)
        for _, branch in ipairs(_state.branches) do
            local px = (branch.x - 1) * SCALE
            local py = (branch.y - 1) * SCALE + 40
            love.graphics.rectangle("fill", px, py, SCALE, SCALE)
            love.graphics.print(branch.name, px + 4, py + 4)
        end
    end
end

function draw_globe()
    for x = 1, W/2 do
        for y = 1, H do
            local dx = math.floor((x + _state.pivot - 1) % W + 1)
            local color = _option.color(dx, y)
            if color then
                local phi = resize(1, W, 0, 2 * math.pi, x)
                local theta = resize(1, H, 0, math.pi, H - y + 1)
                local cx, cy, cz = spherical_to_cartesian(theta, phi)
                cx = -cx
                local px = cx * H + W
                local py = cy * H + H + 40
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", px, py, 4, 4)
            end
        end
    end
    if _option.draw_branches then
        for x = 1, W/2 do
            for y = 1, H do
                local dx = math.floor((x + _state.pivot - 1) % W + 1)
                local branch = _state.branch_map[dx][y]
                if branch then
                    local phi = resize(1, W, 0, 2 * math.pi, x)
                    local theta = resize(1, H, 0, math.pi, H - y + 1)
                    local cx, cy, cz = spherical_to_cartesian(theta, phi)
                    cx = -cx
                    local px = cx * H + W
                    local py = cy * H + H + 40
                    love.graphics.setColor(255, 255, 255)
                    love.graphics.rectangle("fill", px, py, 4, 4)
                    love.graphics.print(branch.name, px + 4, py + 4)
                end
            end
        end

    end
end

function color_elevation(x, y)
    local color = {}
    local a = _state.elevation_map[x][y]
    color[1] = glue.lerp(9, 207, a)
    color[2] = glue.lerp(41, 179, a)
    color[3] = glue.lerp(99, 148, a)
    return color
end

function color_temperature(x, y)
    local color = {}
    local a = _state.temperature_map[x][y]
    color[1] = glue.lerp(0, 255, a)
    color[2] = 0
    color[3] = glue.lerp(255, 0, a)
    return color
end

function color_rain(x, y)
    local color = {}
    local a = _state.rain_map[x][y]
    color[1] = glue.lerp(62, 103, a)
    color[2] = glue.lerp(46, 240, a)
    color[3] = glue.lerp(0, 89, a)
    return color
end

local river_color = { 100, 122, 55 }

function color_river(x, y)
    local color = {}
    local a = _state.elevation_map[x][y]
    if a > WATER_LEVEL then
        color[1] = 79
        color[2] = 33
        color[3] = 48

        local a = _state.river_map[x][y] / 16
        river_color[4] = glue.lerp(0, 255, a)
        color[1] = glue.lerp(170, 100, a)
        color[2] = glue.lerp(58, 122, a)
        color[3] = glue.lerp(87, 255, a)
        return color
    end
end

function color_satellite(x, y)
    local color
    local a = _state.elevation_map[x][y]
    local b = _state.temperature_map[x][y]
    if a > WATER_LEVEL then
        local i = _state.biome_map[x][y]
        color = biome_color[i]
        if _state.discrete_river_map[x][y] ~= math.huge then
            if b > 0.25 then
                color = { 79, 123, 235 }
            else
                color = { 204, 203, 188 }
            end
        end
    elseif a > WATER_LEVEL - 0.05 then
        if b > 0.25 then
            color = { 79, 123, 235 }
        else
            color = { 204, 203, 188 }
        end
    else
        color = { 20, 59, 129 }
    end
    local z = 1 + 0.5 * ((a * 2) - 1)
    color = {
        color[1] * z,
        color[2] * z,
        color[3] * z,
    }
    return color
end

function color_political(x, y)
    local color
    local a = _state.elevation_map[x][y]
    local b = _state.temperature_map[x][y]
    if a > WATER_LEVEL then
        local prefecture = _state.prefecture_map[x][y]
        color = prefecture_color[prefecture]
        
        if _state.discrete_river_map[x][y] ~= math.huge then
            if b > 0.25 then
                color = { 79, 123, 235 }
            else
                color = { 204, 203, 188 }
            end
        end

        local c1 = _state.prefecture_map[x][y]
        if c1 then
            local p2 = get_point(x + 1, y)
            local c2 = _state.prefecture_map[p2.x][p2.y]
            local p3 = get_point(x, y + 1)
            local c3 = _state.prefecture_map[p3.x][p3.y]
            if c1 ~= c2 or c1 ~= c3 then
                color = { 255, 255, 255 }
            end
        end

    elseif a > WATER_LEVEL - 0.05 then
        if b > 0.25 then
            color = { 79, 123, 235 }
        else
            color = { 204, 203, 188 }
        end
    else
        color = { 20, 59, 129 }
    end
    local z = 1 + 0.5 * ((a * 2) - 1)
    color = {
        color[1] * z,
        color[2] * z,
        color[3] * z,
    }
    return color
end

function draw_point(color, x, y)
    local px = (x - 1) * SCALE
    local py = (y - 1) * SCALE
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", px, py, SCALE, SCALE)
end

function draw_text(text, color, x, y)
    local px = (x - 1) * SCALE
    local py = (y - 1) * SCALE
    love.graphics.setColor(color)
    love.graphics.print(text, px + 4, py + 4)
end


function resize(a1, a2, b1, b2, x)
    a3 = a2 - a1
    b3 = b2 - b1
    x = x - a1
    x = x / a3
    x = x * b3
    x = x + b1
    return x
end

function stereographic_projection(ax, ay, az)
    local bx = ax / (1 - az)
    local by = ay / (1 - az)
    return bx, by
end

function polar_coordinates(phi, theta)
    local a = math.sin(phi) / (1 - math.cos(phi))
    local b = theta
    return a, b
end

function polar_to_cartesian(r, theta)
    local x = r * math.cos(theta)
    local y = r * math.sin(theta)
    return x, y
end

function spherical_to_cartesian(theta, phi)
    local x = math.sin(theta) * math.cos(phi)
    local z = math.sin(theta) * math.sin(phi)
    local y = math.cos(theta)
    return x, y, z
end


function point3d(ax, ay)
    local bz = ay

    local bx, by
    if ax < 1 then
        bx = ax / (1 - ay)
        by = 1 - bx ^ 2 - bz ^ 2
    else
        bx = (2 - ax) / (1 - ay)
        by = 1 - bx ^ 2 - bz ^ 2
        by = -by
    end
    return bx, by, bz
end

