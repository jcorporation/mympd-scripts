-- {"name": "Playlistart", "file": "Playlistart/Playlistart.lua", "version": 1, "desc": "Creates playlistart on demand.", "order": 0, "arguments": ["name", "type"]}

local rc, msg = mympd.check_arguments({name = "notempty", ["type"] = "notempty"})
if rc == false then
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Get first song
local result
rc, result = mympd.api("MYMPD_API_PLAYLIST_CONTENT_LIST", {
    plist = mympd_arguments.name,
    offset = 0,
    limit = 1,
    expression = "",
    fields = {}
})
if rc ~= 0 then
    mympd.log(3, "Playlist not found")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

if result.data[1] == nil then
    mympd.log(3, "Playlist is empty")
    if mympd_arguments.type == "smartpls" then
        return mympd.http_redirect("/assets/coverimage-smartpls")
    else
        return mympd.http_redirect("/assets/coverimage-playlist")
    end
end

return mympd.http_redirect("/albumart?offset=0&uri=" .. mympd.urlencode(result.data[1].uri))
