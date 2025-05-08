-- {"name": "Albumart", "file": "Albumart/Albumart.lua", "version": 6, "desc": "Fetches albumart on demand.", "order": 0, "arguments": ["uri"]}
local providers = require "scripts/AlbumartProviders"

local rc, msg = mympd.check_arguments({uri = "notempty"})
if rc == false then
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Get the song details
local song
rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = mympd_arguments.uri})
if rc ~= 0 then
    mympd.log(3, "Song not found")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

local out = mympd.tmp_file()
if out == nil then
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

rc = 1
for _,provider in pairs(providers) do
    rc = provider.get(song, out)
    if rc == 0 then
        mympd.log(6, "Albumart found on " .. provider.name)
        break
    end
end

if rc == 1 then
    mympd.remove_file(out)
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Cache the fetched albumart and send it to the client
local filename
rc, filename = mympd.cache_cover_write(out, mympd_arguments.uri, nil)
if rc == 0 then
    return mympd.http_serve_file(filename)
end

return mympd.http_redirect("/assets/coverimage-notavailable")
