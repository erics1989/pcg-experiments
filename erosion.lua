
erosion = {}

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function get_unit(x, y)
    local m = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
    if m == 0 then
        return 0, 0
    else
        return x / m, y / m
    end
end

function erosion.rain(h, n)
    for i = 1, n do
        local drop = erosion.drop(h)
        while drop.size > 0 do
            erosion.step(h, drop)
        end
    end
end

function erosion.drop(elevation, x, y)
    local x = x or love.math.random(640)
    local y = y or love.math.random(360)
    local drop = {
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        size = 1,
        dirt = 0
    }
    return drop
end

function erosion.step(h, drop)
    -- src
    local src_x = drop.x
    local src_y = drop.y

    -- src corners
    local src_ax = math.floor(src_x)
    local src_ay = math.floor(src_y)
    local src_bx = (src_ax + 1 - 1) % 640 + 1
    local src_by = (src_ay + 1 - 1) % 360 + 1

    -- src fade
    local src_fx = src_x - src_ax
    local src_fy = src_y - src_ay
    
    -- descent vec
    local dxa = h[src_ax][src_ay] - h[src_bx][src_ay]
    local dxb = h[src_ax][src_by] - h[src_bx][src_by]
    local dx = lerp(dxa, dxb, src_fy)
    local dya = h[src_ax][src_ay] - h[src_ax][src_by]
    local dyb = h[src_bx][src_ay] - h[src_bx][src_by]
    local dy = lerp(dya, dyb, src_fx)

    dx, dy = get_unit(dx, dy)
    dx = (dx + drop.dx) / 2
    dy = (dy + drop.dy) / 2
    
    -- dst
    local dst_x = (src_x + dx - 1) % 640 + 1
    local dst_y = (src_y + dy - 1) % 360 + 1

    -- dst corners
    local dst_ax = math.floor(dst_x)
    local dst_ay = math.floor(dst_y)
    local dst_bx = (dst_ax + 1 - 1) % 640 + 1
    local dst_by = (dst_ay + 1 - 1) % 360 + 1

    -- dst fade
    local dst_fx = dst_x - dst_ax
    local dst_fy = dst_y - dst_ay
    
    -- src h
    local src_ha = lerp(h[src_ax][src_ay], h[src_ax][src_by], src_fy)
    local src_hb = lerp(h[src_bx][src_ay], h[src_bx][src_by], src_fy)
    local src_h = lerp(src_ha, src_hb, src_fx)
    
    -- dst h
    local dst_ha = lerp(h[dst_ax][dst_ay], h[dst_ax][dst_by], dst_fy)
    local dst_hb = lerp(h[dst_bx][dst_ay], h[dst_bx][dst_by], dst_fy)
    local dst_h = lerp(dst_ha, dst_hb, dst_fx)

    -- dh
    local dh = dst_h - src_h
    if dh < 0 then
        -- dn
        local dirt = math.min(-dh, drop.size - drop.dirt)
        drop.dirt = drop.dirt + dirt
        h[src_ax][src_ay] =
            h[src_ax][src_ay] - dirt * (1 - src_fx) * (1 - src_fy)
        h[src_ax][src_by] =
            h[src_ax][src_by] - dirt * (1 - src_fx) * src_fy
        h[src_bx][src_ay] =
            h[src_bx][src_ay] - dirt * src_fx * (1 - src_fy)
        h[src_bx][src_by] =
            h[src_bx][src_by] - dirt * src_fx * src_fy
    else
        -- up
        local dirt = math.min(dh, drop.dirt)
        drop.dirt = drop.dirt - dirt
        h[src_ax][src_ay] =
            h[src_ax][src_ay] + dirt * (1 - src_fx) * (1 - src_fy)
        h[src_ax][src_by] =
            h[src_ax][src_by] + dirt * (1 - src_fx) * src_fy
        h[src_bx][src_ay] =
            h[src_bx][src_ay] + dirt * src_fx * (1 - src_fy)
        h[src_bx][src_by] =
            h[src_bx][src_by] + dirt * src_fx * src_fy
    end
    drop.x = dst_x
    drop.y = dst_y
    drop.dx = dx
    drop.dy = dy
    drop.size = drop.size - 0.01
end

