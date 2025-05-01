-- {"name": "WidgetBatteryIndicator", "file": "HomeWidgets/WidgetBatteryIndicator.lua", "version": 5, "desc": "Displays the battery status from sys filesystem.", "order":0, "arguments":[]}
local headers ="Content-type: text/html\r\n"

local code = 500
local body = "<div class=\"text-center p-3\">Error reading capacity</div>"

local rc, msg = mympd.check_arguments({battery = "notempty"})
if rc == false then
    body = "<div class=\"text-center p-3\">" .. msg .. "</div>"
    return mympd.http_reply(code, headers, body)
end

local battery = mympd.read_file("/sys/class/power_supply/" .. mympd_arguments.battery .. "/capacity")
if battery ~= nil then
    battery = tonumber(battery)
    if battery ~= nil then
        local icon = "battery_full"
        for i = 6, 0, -1 do
            if battery < math.floor((i * 16.7) + 0.5) then
                icon = "battery_" .. i .. "_bar"
            end
        end
        code = 200
        body = "<div class=\"text-center py-3 fs-3\">" ..
                "<span class=\"mi fs-1\">" .. icon .. "</span>" ..
                "<span>" .. battery .. " %</span>" ..
            "</div>"
    end
end

return mympd.http_reply(code, headers, body)
