-- {"name": "Background", "file": "Background/Background.lua", "version": 1, "desc": "Fetches a background image on demand.", "order": 0, "arguments": ["uri","hash"]}
local providers = require "scripts/BackgroundProviders"

-- Get the song details
local rc, song = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG", {})
if rc ~= 0 then
    mympd.log(3, "No current song")
    return mympd.http_redirect("/assets/coverimage-transparent")
end

local out = mympd.tmp_file()
if out == nil then
    mympd.log(3, "Failure creating tmp file.")
    return mympd.http_redirect("/assets/coverimage-transparent")
end

rc = 1
for _,provider in pairs(providers) do
    rc = provider.get(song, out)
    if rc == 0 then
        mympd.log(6, "Background found on " .. provider.name)
        break
    end
end

if rc == 1 then
    os.remove(out);
    return mympd.http_redirect("/assets/coverimage-transparent")
end

return mympd.http_serve_file_rm(out)
