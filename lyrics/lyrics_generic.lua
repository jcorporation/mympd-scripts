-- {"order":1,"arguments":["uri"]}
-- Template to create a lyrics fetch script.
-- You must implement the as TODO marked section yourself.
local song_uri = mympd_arguments.uri

-- Get the song details
local rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = song_uri})
if rc ~= 0 then
    return mympd.http_jsonrpc_error("MYMPD_API_LYRICS_GET", "Song not found")
end

-- Fetch the lyrics
local lyrics_found = 0
local lyrics_text
-- TODO: construct the uri to fetch the lyrics from
local lyrics_uri = ""
local code, header, body
rc, code, header, body = mympd.http_client("GET", lyrics_uri, "", "")
if rc == 0 and #body > 0 then
    -- TODO: extract lyrics text from response
    if lyrics_text then
        lyrics_found = 1
    end
end

if lyrics_found == 0 then
    return mympd.http_jsonrpc_error("MYMPD_API_LYRICS_GET", "No lyrics found")
end

-- Create lyrics data entry and response
local entry = {
    synced = false,
    lang = "",
    desc = "",
    text = lyrics_text
}
local result = {
    data = { entry },
    totalEntities = 1,
    returnedEntities = 1
}

-- Cache the fetched lyrics and send the response
mympd.lyricscache_write(json.encode(entry), song_uri)
return mympd.http_jsonrpc_response(result)
