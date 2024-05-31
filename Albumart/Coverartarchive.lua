-- {"order":1,"arguments":["uri"]}

-- Get the song details
local rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = mympd_arguments.uri})
if rc ~= 0 then
    mympd.log(3, "Song not found")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

if not song.MUSICBRAINZ_ALBUMID then
    mympd.log(7, "No MUSICBRAINZ_ALBUMID tag found")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

local out = mympd.tmp_file()
rc = mympd.http_download("https://coverartarchive.org/release/" .. song.MUSICBRAINZ_ALBUMID .. "/front", out)
if rc == 1 then
    mympd.log(6, "No albumart found on coverartarchive.")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Cache the fetched albumart and send it to the client
local file = mympd.covercache_write(out, mympd_arguments.uri)
if file then
    return mympd.http_serve_file(file)
end

return mympd.http_redirect("/assets/coverimage-notavailable")
