
glue = {}

function glue.dist_e(a, b)
    return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
end

glue.list = {}

-- list, copy
function glue.list.copy(a)
    local b = {}
    for i, v in ipairs(a) do
        b[i] = v
    end
    return b
end

-- list, non-destructive sort
function glue.list.sort(a, compare)
    local b = glue.list.copy(a)
    local f = function (a, b)
        return compare(a, b) < 0
    end
    table.sort(b, f)
    return b
end

-- list, max
function glue.list.max(a, compare)
    local x = a[1]
    for _, y in ipairs(a) do
        if compare(x, y) < 0 then
            x = y
        end
    end
    return x
end

-- list, min
function glue.list.min(a, compare)
    local x = a[1]
    for _, y in ipairs(a) do
        if compare(x, y) > 0 then
            x = y
        end
    end
    return x
end

