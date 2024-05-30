-- {"order":1,"arguments":["uri"]}
-- Import lyrics provider configuration
local providers = require "scripts/lyrics_providers"
local rc, code, header, body, song, lyrics_text, desc

local function strip_html(str)
    str = str:gsub("<!%[CDATA%[.-%]%]>", "")
    str = str:gsub("<script._</script>", "")
    str = str:gsub("<!%-%-.-%-%->", "")
    str = str:gsub("<[^>]+>", "")
    str = str:gsub("%*/", "")
    str = str:gsub("\n\n\n+", "\n")
    str = str:gsub("&#(%d+);", function(s)
            return string.char(s)
        end)
    return str
end

local function replace_vars_pattern(str, artist, title)
    -- escape magic chars for pattern matching
    artist = artist:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%%" .. "%1")
    title = title:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%%" .. "%1")
    str = str:gsub("{artist}", artist)
    str = str:gsub("{title}", title)
    return str
end

local function replace_vars_uri(str, artist, title)
    str = str:gsub("{artist}", function(s)
            return mympd.urlencode(artist)
        end)
    str = str:gsub("{title}", function(s)
            return mympd.urlencode(title)
        end)
    return str
end

local function get_lyrics_uri(provider, artist, title)
    local identity_uri = replace_vars_uri(provider.identity_uri, artist, title)
    rc, code, header, body = mympd.http_client("GET", identity_uri, "", "")
    if rc == 0 and #body > 0 then
        local identity_pattern = replace_vars_pattern(provider.identity_pattern, artist, title)
        local lyrics_path = body:match(identity_pattern)
        if lyrics_path then
            return provider.lyrics_uri .. lyrics_path
        end
    end
    return nil
end

-- Get the song details
rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = mympd_arguments.uri})
if rc ~= 0 then
    return mympd.http_jsonrpc_error("MYMPD_API_LYRICS_GET", "Song not found")
end

-- Fetch the lyrics
for _, provider in pairs(providers) do
    mympd.log(6, "Try to fetch lyrics from " .. provider.name)
    local artist = provider.artist_filter(song.Artist[1])
    local title = provider.title_filter(song.Title)
    local lyrics_uri
    if provider.identity_uri then
        lyrics_uri = get_lyrics_uri(provider, artist, title)
    else
        lyrics_uri = replace_vars_uri(provider.lyrics_uri, artist, title)
    end
    if lyrics_uri then
        rc, code, header, body = mympd.http_client("GET", lyrics_uri, "", "")
        if rc == 0 then
            local lyrics_pattern = replace_vars_pattern(provider.lyrics_pattern, artist, title)
            lyrics_text = body:match(lyrics_pattern)
        end
    end
    if lyrics_text then
        lyrics_text = provider.result_filter(lyrics_text)
        if lyrics_text then
            if provider.result_strip_html then
                lyrics_text = strip_html(lyrics_text)
            end
            desc = provider.name
            break
        end
    end
end

if not lyrics_text then
    return mympd.http_jsonrpc_response({
        method = "MYMPD_API_LYRICS_GET",
        message = "No lyrics found",
        totalEntities = 1,
        returnedEntities = 1
    })
end

-- Create lyrics data entry and response
local entry = {
    synced = false,
    lang = "",
    desc = desc,
    text = lyrics_text
}
local result = {
    method = "MYMPD_API_LYRICS_GET",
    data = { entry },
    totalEntities = 1,
    returnedEntities = 1
}

-- Cache the fetched lyrics and send the response
mympd.lyricscache_write(json.encode(entry), mympd_arguments.uri)
return mympd.http_jsonrpc_response(result)
