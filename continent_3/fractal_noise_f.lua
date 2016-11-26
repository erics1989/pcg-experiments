
function fractal_noise_f(w, h)
    local fs = {}
    local fx = w
    local fy = h
    for i = 1, 8 do
        fs[i] = perlin.noise_f(fx, fy)
        fx = fx * 2
        fy = fy * 2
    end
    local noise_f = function (x, y)
        local n = 0
        local fx = w
        local fy = h
        local a = 1
        for i = 1, 8 do
            local f = fs[i]
            n = n + f(x / W * fx, y / H * fy) * a
            fx = fx * 2
            fy = fy * 2
            a = a * 0.5
        end
        n = math.max(-1, math.min(n, 1))
        return n
    end
    return noise_f
end

