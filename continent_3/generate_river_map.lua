
local speed = 100

local function step(raindrop)
    local h = _state.elevation_map
    local f = _state.river_map

    -- src
    local src_x = raindrop.x
    local src_y = raindrop.y

    -- src corners
    local src_ax = math.floor(src_x)
    local src_ay = math.floor(src_y)
    local src_bx = (src_ax + 1 - 1) % W + 1
    local src_by = (src_ay + 1 - 1) % H + 1

    -- src corner pos
    local src_cx = src_x - src_ax
    local src_cy = src_y - src_ay
    
    -- descent vec
    local dxa = h[src_ax][src_ay] - h[src_bx][src_ay]
    local dxb = h[src_ax][src_by] - h[src_bx][src_by]
    local dx = glue.lerp(dxa, dxb, src_cy) * speed
    local dya = h[src_ax][src_ay] - h[src_ax][src_by]
    local dyb = h[src_bx][src_ay] - h[src_bx][src_by]
    local dy = glue.lerp(dya, dyb, src_cx) * speed
    
    -- dst
    local dst_x = (src_x + dx - 1) % W + 1
    local dst_y = (src_y + dy - 1) % H + 1

    -- dst corners
    local dst_ax = math.floor(dst_x)
    local dst_ay = math.floor(dst_y)
    local dst_bx = (dst_ax + 1 - 1) % W + 1
    local dst_by = (dst_ay + 1 - 1) % H + 1

    -- dst corner pos
    local dst_cx = dst_x - dst_ax
    local dst_cy = dst_y - dst_ay
    
    -- src h
    local src_ha =
        glue.lerp(h[src_ax][src_ay], h[src_ax][src_by], src_cy)
    local src_hb =
        glue.lerp(h[src_bx][src_ay], h[src_bx][src_by], src_cy)
    local src_h =
        glue.lerp(src_ha, src_hb, src_cx)
    
    -- dst h
    local dst_ha =
        glue.lerp(h[dst_ax][dst_ay], h[dst_ax][dst_by], dst_cy)
    local dst_hb =
        glue.lerp(h[dst_bx][dst_ay], h[dst_bx][dst_by], dst_cy)
    local dst_h =
        glue.lerp(dst_ha, dst_hb, dst_cx)

    local dh = dst_h - src_h

    -- update river
    f[src_ax][src_ay] =
        f[src_ax][src_ay] + raindrop.size * (1 - src_cx) * (1 - src_cy)
    f[src_ax][src_by] =
        f[src_ax][src_by] + raindrop.size * (1 - src_cx) * src_cy
    f[src_bx][src_ay] =
        f[src_bx][src_ay] + raindrop.size * src_cx * (1 - src_cy)
    f[src_bx][src_by] =
        f[src_bx][src_by] + raindrop.size * src_cx * src_cy

    raindrop.x = dst_x
    raindrop.y = dst_y

    return dh < 0
end

local function raindrop(x, y)
    local size = _state.rain_map[x][y]
    local raindrop = { x = x, y = y, size = size }
    while step(raindrop) do
        -- pass
    end
end

local function rain()
    for x = 1, W do
        for y = 1, H do
            raindrop(x, y)
        end
    end
end

function generate_river_map()
    print("generating river map")
    local f = function (x, y)
        return 0
    end
    _state.river_map = generate_map(f)
    rain()
end

