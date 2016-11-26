
function generate_name(prefecture)
    local f = _state.generate_name_fs[prefecture]
    while true do
        local name = f()
        local n = #name
        if 4 <= n and n <= 16 then
            return name
        end
    end
end
