
local pq = {}

local function percolate_up(a, i)
    if 1 < i then
        local j = math.floor(i / 2)
        if a.compare(a[i], a[j]) then
            a[i], a[j] = a[j], a[i]
            percolate_up(a, j)
        end
    end
end

local function percolate_dn(a, i)
    local x = i
    local j = i * 2
    local k = i * 2 + 1
    if a[j] and a.compare(a[j], a[x]) then
        x = j
    end
    if a[k] and a.compare(a[k], a[x]) then
        x = k
    end
    if x ~= i then
        a[i], a[x] = a[x], a[i]
        percolate_dn(a, x)
    end
end

function pq.enqueue(a, v)
    local i = #a + 1
    a[i] = v
    percolate_up(a, i)
end

function pq.dequeue(a)
    local v = a[1]
    local i = #a
    if i <= 1 then
        a[1] = nil
    else
        a[1], a[i] = a[i], nil
        percolate_dn(a, 1)
    end
    return v
end

function pq.create(a, compare)
    a.compare = compare
    for i = math.floor(#a / 2), 1, -1 do
        percolate_dn(a, i)
    end
    return a
end

return pq

