
local list = {}

-- copy
function list.copy(a)
    local b = {}
    for i, v in ipairs(a) do
        b[i] = v
    end
    return b
end

-- non-destructive sort
function list.sort(a, compare)
    local b = list.copy(a)
    local f = function (a, b)
        return compare(a, b) < 0
    end
    table.sort(b, f)
    return b
end

-- map
function list.map(a, f)
    local b = {}
    for i, v in ipairs(a) do
        b[i] = f(v)
    end
    return b
end

-- filter
function list.filter(a, f)
    local b = {}
    for i, v in ipairs(a) do
        if f(v) then
            table.insert(b, v)
        end
    end
    return b
end

local function compare_default(a, b)
    return a < b
end

-- max
function list.max(a, compare)
    compare = compare or compare_default
    local x = a[1]
    for _, y in ipairs(a) do
        if compare(x, y) then
            x = y
        end
    end
    return x
end

-- min
function list.min(a, compare)
    compare = compare or compare_default
    local x = a[1]
    for _, y in ipairs(a) do
        if not compare(x, y) then
            x = y
        end
    end
    return x
end

-- union
function list.union(a, b)
    local c = list.copy(a)
    local n = #a
    for i, v in ipairs(b) do
        c[n + i] = v
    end
    return b
end

return list

