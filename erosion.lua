
erosion = {}

local function step(terrain, rain)

end

function erosion.rain(terrain)
    local w = #terrain
    local h = #terrain[1]
    local rain = {}
    for x = 1, w do
        rain[x] = {}
        for y = 1, h do
            rain[x][y] = 1
        end
    end

end

