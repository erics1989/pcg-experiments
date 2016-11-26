
glue = {}

function glue.dist_e(ax, ay, bx, by)
    return math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
end

function glue.lerp(a, b, t)
    return a + (b - a) * t
end

function glue.curve(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

