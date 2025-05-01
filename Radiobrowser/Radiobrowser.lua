-- {"name": "Radiobrowser", "file": "Radiobrowser/Radiobrowser.lua", "version": 5, "desc": "Radiobrowser interface.", "order":0, "arguments": ["Name", "Country", "Tag"]}

local function radiobrowser_search(name, country, tag)
    local uri = string.format("https://all.api.radio-browser.info/json/stations/search?hidebroken=true&offset=0&limit=100&name=%s&country=%s&tag=%s",
        mympd.urlencode(name), mympd.urlencode(country), mympd.urlencode(tag))
    local rc, code, headers, body
    for i = 1, 5, 1 do
        rc, code, headers, body = mympd.http_client("GET", uri, "", "")
        if rc == 0 then
            break
        end
        mympd.log(4, "Retry " .. i .. " for searching radiobrowser")
    end

    local radios = json.decode(body)
    if radios == nil then
        return "Failure decoding response from radiobrowser."
    end
    local values = {}
    local displayValues = {}
    for _, radio in pairs(radios) do
        table.insert(values, radio.stationuuid)
        table.insert(displayValues, {
            title = radio.name,
            text = radio.country .. " / " .. radio.language,
            small = radio.codec .. " / " .. radio.bitrate
        })
    end
    local data = {
        { name = "Action", type = "select", defaultValue = "AddToFavorites", value = { "AddToFavorites", "AppendToQueue" }, displayValue = { "Add to favorites", "Append to queue" } },
        { name = "Radios", type = "list", displayValue = displayValues, value = values, defaultValue = "" }
    }
    return mympd.dialog("Add to webradio favorites", data, "Radiobrowser")
end

local function radiobrowser_import(stationuuid)
    local uri = string.format("https://all.api.radio-browser.info/json/stations/byuuid?uuids=%s",
        mympd.urlencode(stationuuid))
    local rc, code, headers, body
    for i = 1, 5, 1 do
        rc, code, headers, body = mympd.http_client("GET", uri, "", "")
        if rc == 0 then
            break
        end
        mympd.log(4, "Retry " .. i .. " for seaching radiobrowser")
    end
    if rc == 1 then
        return "Failure fetching radio details from radiobrowser."
    end
    local radio = json.decode(body)
    if radio == nil then
        return "Failure decoding response from radiobrowser."
    end
    local result
    if mympd_arguments.Action == "AddToFavorites" then
        local data = {
            name = radio[1].name,
            oldName = "",
            streamUri = radio[1].url_resolved,
            image = radio[1].favicon,
            genres = { radio[1].tags },
            homepage = radio[1].homepage,
            country = radio[1].country,
            region = "",
            languages = { radio[1].language },
            description = "",
            codec = radio[1].codec,
            bitrate = radio[1].bitrate
        }
        rc, result = mympd.api("MYMPD_API_WEBRADIO_FAVORITE_SAVE", data)
    end
    if mympd_arguments.Action == "AppendToQueue" then
        local data = {
            uris = { radio[1].url_resolved },
            play = false
        }
        rc, result = mympd.api("MYMPD_API_QUEUE_APPEND_URIS", data)
    end
    if rc == 1 then
        mympd.notify_client(2, result.message)
    end
    return rc
end

if mympd_arguments.Action ~= nil then
    local added = 0
    for stationuuid in string.gmatch(mympd_arguments.Radios, "[^;;]+") do
        local rc = radiobrowser_import(stationuuid)
        if rc == 0 then
            added = added + 1
        end
    end
    if added > 0 then
        return "Webradios added."
    end
    return "Failure adding webradios."
end

local rc, msg = mympd.check_arguments({Name = "required", Country = "required", Tag = "required"})
if rc == false then
    return msg
end

return radiobrowser_search(mympd_arguments.Name, mympd_arguments.Country, mympd_arguments.Tag)
