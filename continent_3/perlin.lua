
local function rng()
    return love.math.random()
end

--

perlin = {}

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function curve(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function vector_rng()
    local a = 2 * math.pi * rng()
    return { x = math.cos(a), y = math.sin(a) }
end

function perlin.noise_f(w, h)
    local vectors = {}
    for x = 1, w do
        vectors[x] = {}
        for y = 1, h do
            vectors[x][y] = vector_rng()
        end
    end
    local dot = function (cx, cy, x, y)
        local dx = x - cx
        local dy = y - cy
        local v = vectors[(cx - 1) % w + 1][(cy - 1) % h + 1]
        return dx * v.x + dy * v.y
    end
    local noise_f = function (x, y)
        x = (x - 1) % w + 1
        y = (y - 1) % h + 1
        local ax = math.floor(x)
        local ay = math.floor(y)
        local bx = ax + 1
        local by = ay + 1
        local naa = dot(ax, ay, x, y)
        local nab = dot(ax, by, x, y)
        local nba = dot(bx, ay, x, y)
        local nbb = dot(bx, by, x, y)
        local curvex = curve(x - ax)
        local curvey = curve(y - ay)
        local na = glue.lerp(naa, nab, curvey)
        local nb = glue.lerp(nba, nbb, curvey)
        local n = glue.lerp(na, nb, curvex)
        return n
    end
    return noise_f
end

