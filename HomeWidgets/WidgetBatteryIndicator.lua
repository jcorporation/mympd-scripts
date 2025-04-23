-- {"name": "WidgetBatteryIndicator", "file": "HomeWidgets/WidgetBatteryIndicator.lua", "version": 3, "desc": "Displays the battery status from sys filesystem.", "order":0, "arguments":[]}
local headers ="Content-type: text/html\r\n"
local body = "<div class=\"text-center p-3\">Error</div>"

if not mympd.isnilorempty(mympd_arguments.battery) then
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
            body = "<div class=\"text-center py-3 fs-3\">" ..
                    "<span class=\"mi fs-1\">" .. icon .. "</span>" ..
                    "<span>" .. battery .. " %</span>" ..
                "</div>"
        end
    end
end

return mympd.http_reply("200", headers, body)
