-- {"name": "WidgetRaspberryStatus", "file": "HomeWidgets/WidgetRaspberryStatus.lua", "version": 1, "desc": "Shows Raspberry Pi status information.", "order":0, "arguments":[]}

local rows = {}

function addRow(key, value)
    table.insert(rows, "<tr><th>" ..
        mympd.htmlencode(key) .. "</th><td>" ..
        mympd.htmlencode(value) .. "</td></tr>")
end

local temp = mympd.os_capture("vcgencmd measure_temp")
temp = string.sub(temp, 6)
addRow("Temp", temp)

local voltage = mympd.os_capture("vcgencmd measure_volts core")
voltage = string.sub(voltage, 6)
addRow("Core voltage", voltage)

local clock = mympd.os_capture("vcgencmd measure_clock arm")
clock = string.sub(clock, 15)
clock = math.floor(tonumber(clock) / 1000000)
addRow("Core clock", clock .. "Mhz")

local throttled = mympd.os_capture("vcgencmd get_throttled")
throttled = string.sub(throttled, 11)
if throttled ~= "0x0" then
    throttled = tonumber(throttled)
    if throttled & 0x80000 == 0x80000 then
        addRow("Warning", "Soft temperature limit has occurred")
    end
    if throttled & 0x40000 == 0x40000 then
        addRow("Warning", "Throttling has occurred")
    end
    if throttled & 0x20000 == 0x20000 then
        addRow("Warning", "Arm frequency capping has occurred")
    end
    if throttled & 0x10000 == 0x10000 then
        addRow("Warning", "Under-voltage has occurred")
    end
    if throttled & 0x8 == 0x8 then
        addRow("Warning", "Soft temperature limit active")
    end
    if throttled & 0x4 == 0x4 then
        addRow("Warning", "Currently throttled")
    end
    if throttled & 0x2 == 0x2 then
        addRow("Warning", "Arm frequency capped")
    end
    if throttled & 0x1 == 0x1 then
        addRow("Warning", "Under-voltage detected")
    end
end

local headers = "Content-type: text/html\r\n"
local body = "<table class=\"table\">" ..
    table.concat(rows) ..
    "</table>"

return mympd.http_reply("200", headers, body)
