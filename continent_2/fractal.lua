
fractal = {}

function fractal.noise(noise, freq, lacu, pers, octa)
    freq = freq or 1
    lacu = lacu or 2
    pers = pers or 0.5
    octa = octa or 16
    local calculate = function (x, y)
        local n = 0
        local f = freq
        local a = 1
        for i = 1, octa do
            n = n + noise(x * f, y * f) * a
            f = f * lacu
            a = a * pers
        end
        return math.max(-1, math.min(n, 1))
    end
    return calculate
end

