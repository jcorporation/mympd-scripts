-- {"name": "BatteryIndicator", "file": "HomeWidgets/BatteryIndicator.lua", "version": 1, "desc": "Displays the battery status from sys filesystem.", "order":0, "arguments":[]}
local headers ="Content-type: text/html\r\n"
local body = "<div class=\"text-center p-3\">Error</div>"

local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read "*a"
    file:close()
    return content
end

if mympd_arguments.battery ~= nil then
    local battery = read_file("/sys/class/power_supply/" .. mympd_arguments.battery .. "/capacity")
    if battery ~= nil then
        battery = tonumber(battery)
        if battery ~= nil then
            local icon = "battery_full"
            for i = 6, 0, -1 do
                if battery < math.floor((i * 16.7) + 0.5) then
                    icon = "battery_" .. i .. "_bar"
                end
            end
            body = "<div class=\"text-center p-3 fs-3\">" ..
                    "<span class=\"mi fs-1\">" .. icon .. "</span>" .. 
                    "<span>" .. battery .. " %</span>" ..
                "</div>"
        end
    end
end

return mympd.http_reply("200", headers, body)

