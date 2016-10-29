
perlin = {}

local function rand()
    return love.math.random()
end

local function vector()
    local theta = rand() * 2 * math.pi
    local x = math.cos(theta)
    local y = math.sin(theta)
    return { x = x, y = y }
end

local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

function perlin.noise()
    local gradients = {}
    for x = 1, 256 do
        gradients[x] = {}
        for y = 1, 256 do
            gradients[x][y] = vector()
        end
    end
    local dot = function (cx, cy, x, y)
        local dx = x - cx
        local dy = y - cy
        local g = gradients[(cx - 1) % 256 + 1][(cy - 1) % 256 + 1]
        return (dx * g.x + dy * g.y)
    end
    local calculate = function (x, y)
        x = (x - 1) % 256 + 1
        y = (y - 1) % 256 + 1
        local ax = math.floor(x)
        local ay = math.floor(y)
        local bx = ax + 1
        local by = ay + 1
        local naa = dot(ax, ay, x, y)
        local nab = dot(ax, by, x, y)
        local nba = dot(bx, ay, x, y)
        local nbb = dot(bx, by, x, y)
        local fadex = fade(x - ax)
        local fadey = fade(y - ay)
        local na = lerp(naa, nab, fadey)
        local nb = lerp(nba, nbb, fadey)
        local n = lerp(na, nb, fadex)
        return n
    end
    return calculate
end

