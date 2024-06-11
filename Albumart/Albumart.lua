-- {"name": "Albumart", "file": "Albumart/Albumart.lua", "version": 1, "desc": "Fetches albumart on demand.", "order": 0, "arguments": ["uri"]}
local providers = require "scripts/AlbumartProviders"

-- Get the song details
local rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = mympd_arguments.uri})
if rc ~= 0 then
    mympd.log(3, "Song not found")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

local out = mympd.tmp_file()

rc = 1
for _,provider in pairs(providers) do
    rc = provider.get(song, out)
    if rc == 0 then
        mympd.log(6, "Albumart found on " .. provider.name)
        break
    end
end

if rc == 1 then
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Cache the fetched albumart and send it to the client
local filename
rc, filename = mympd.cache_cover_write(out, mympd_arguments.uri)
if rc == 0 then
    return mympd.http_serve_file(filename)
end

return mympd.http_redirect("/assets/coverimage-notavailable")
