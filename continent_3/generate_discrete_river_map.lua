
local max = 64

local function start(point)
    return _state.elevation_map[point.x][point.y] < WATER_LEVEL
end

local function cost(a, b)
    local c
    if a.x == b.x or a.y == b.y then
        c = 1
    else
        c = 1.4
    end
    local river = _state.river_map[b.x][b.y]
    if river > 16 then
        return c
    elseif river > 8 then
        return 2 * c
    else
        return math.huge
    end
end

function generate_discrete_river_map()
    print("generating discrete river map")
    local points = list.filter(_state.points, start)
    _state.discrete_river_map = generate_dist_map(points, cost, max)
end

