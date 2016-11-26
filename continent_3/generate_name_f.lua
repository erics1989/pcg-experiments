
local function db_add(db, prev, curr)
    if db[prev] == nil then
        db[prev] = { options = {}, denom = 0 }
    end
    if db[prev].options[curr] then
        db[prev].options[curr] = db[prev].options[curr] + 1
    else
        db[prev].options[curr] = 1
    end
    db[prev].denom = db[prev].denom + 1
end

local function db_get(db, prev)
    local r = love.math.random(db[prev].denom)
    for option, x in pairs(db[prev].options) do
        if r <= x then
            return option
        else
            r = r - x
        end
    end
end

function generate_name_f(file)
    local db = {}
    for line in love.filesystem.lines(file) do
        local prev = "^"
        for i = 1, #line do
            local curr = string.sub(line, i, i)
            if curr == " " then
                break
            end
            db_add(db, prev, curr)
            prev = curr
        end
        db_add(db, prev, "$")
    end
    local generate = function ()
        local characters = {}
        local prev = "^"
        while true do
            local curr = db_get(db, prev)
            if curr == "$" then
                break
            else
                table.insert(characters, curr)
                prev = curr
            end
        end
        return table.concat(characters)
    end
    return generate
end

