-- {"name": "WidgetRaspberryStatusGPIOd", "file": "HomeWidgets/WidgetRaspberryStatusGPIOd.lua", "version": 1, "desc": "Shows Raspberry Pi status information.", "order":0, "arguments":["mygpiod_uri"]}

local headers = "Content-type: text/html\r\n"
local rows = {}

local function addRow(key, value)
    table.insert(rows, "<tr><th>" ..
        mympd.htmlencode(key) .. "</th><td>" ..
        mympd.htmlencode(value) .. "</td></tr>")
end

if not mympd.isnilorempty(mympd_arguments.mygpiod_uri) then
    mympd.mygpiod_uri = mympd_arguments.mygpiod_uri
end

local values = mympd.vcio_get()
if values == nil then
    local body = "<div class=\"alert alert-danger m-3\">Can not read from myGPIOd</div>"
    return mympd.http_reply("200", headers, body)
end
addRow("Temp", values.temp)
addRow("Core voltage", values.volts)
local clock = math.floor(tonumber(values.clock) / 1000000)
addRow("Core clock", clock .. "Mhz")

if values.throttled ~= "0x0" then
    local throttled = tonumber(values.throttled)
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

local body = "<table class=\"table\">" ..
    table.concat(rows) ..
    "</table>"

return mympd.http_reply("200", headers, body)
