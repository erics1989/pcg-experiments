
local function adjacent(a)
    local points = {}
    points[1] = get_point(a.x - 1, a.y - 1)
    points[2] = get_point(a.x - 1, a.y)
    points[3] = get_point(a.x - 1, a.y + 1)
    points[4] = get_point(a.x, a.y - 1)
    points[5] = get_point(a.x, a.y + 1)
    points[6] = get_point(a.x + 1, a.y - 1)
    points[7] = get_point(a.x + 1, a.y)
    points[8] = get_point(a.x + 1, a.y + 1)
    return points
end

function generate_dist_map(srcs, cost, max)
    max = max or math.huge
    local open = {}
    local dist = {}
    for x = 1, W do
        open[x] = {}
        dist[x] = {}
        for y = 1, H do
            open[x][y] = true
            dist[x][y] = math.huge
        end
    end
    local compare = function (a, b)
        return dist[a.x][a.y] < dist[b.x][b.y]
    end
    local curr = pq.create({}, compare)
    for _, a in ipairs(srcs) do
        dist[a.x][a.y] = 0
        pq.enqueue(curr, a)
    end
    while curr[1] do
        local a = pq.dequeue(curr)
        open[a.x][a.y] = false
        for _, b in ipairs(adjacent(a)) do
            if open[b.x][b.y] then
                local z = dist[a.x][a.y] + cost(a, b)
                if z < dist[b.x][b.y] and z <= max then
                    dist[b.x][b.y] = z
                    pq.enqueue(curr, b)
                end
            end
        end
    end
    return dist
end

function update_dist_map(dist, srcs, cost, max)
    max = max or math.huge
    local open = {}
    for x = 1, W do
        open[x] = {}
        for y = 1, H do
            open[x][y] = true
        end
    end
    local compare = function (a, b)
        return dist[a.x][a.y] < dist[b.x][b.y]
    end
    local curr = pq.create({}, compare)
    for _, a in ipairs(srcs) do
        dist[a.x][a.y] = 0
        pq.enqueue(curr, a)
    end
    while curr[1] do
        local a = pq.dequeue(curr)
        open[a.x][a.y] = false
        for _, b in ipairs(adjacent(a)) do
            if open[b.x][b.y] then
                local z = dist[a.x][a.y] + cost(a, b)
                if z < dist[b.x][b.y] and z <= max then
                    dist[b.x][b.y] = z
                    pq.enqueue(curr, b)
                end
            end
        end
    end
    return dist
end

