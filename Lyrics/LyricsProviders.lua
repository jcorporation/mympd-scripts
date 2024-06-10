-- {"name": "LyricsProviders", "file": "Lyrics/LyricsProviders.lua", "version": 3, "desc": "Lyrics providers for the Lyrics script.", "order":0, "arguments":[]}

local p_www_songtexte_com = {
    name = "Songtexte",
    artist_filter = function(artist)
        artist = artist:gsub("%s", "-")
        artist = artist:lower(artist)
        return artist
    end,
    album_filter = function(album)
        return album
    end,
    title_filter = function(title)
        title = title:gsub("%s", "-")
        title = title:lower(title)
        return title
    end,
    identity_uri = "https://www.songtexte.com/search?q={title}+{artist}&c=all",
    identity_pattern = "(songtext/.-/.-%-.-%.html)",
    lyrics_uri = "https://www.songtexte.com/",
    lyrics_pattern = "<div id=\"lyrics\">(.-)<p id=\"artistCopyright\"",
    result_filter = function(result)
        if result:find("Kein Songtext vorhanden.") then
            result = nil
        end
        return result, false
    end,
    result_strip_html = true
}

local p_lrclib = {
    name = "LRCLIB",
    artist_filter = function(artist)
        return artist
    end,
    album_filter = function(album)
        return album
    end,
    title_filter = function(title)
        return title
    end,
    identity_uri = nil,
    identity_pattern = nil,
    lyrics_uri = "https://lrclib.net/api/get?track_name={title}&artist_name={artist}&album_name={album}&duration={duration}",
    lyrics_pattern = nil,
    result_filter = function(result)
        local data = json.decode(result)
        if data.syncedLyrics then
            return data.syncedLyrics, true
        end
        if data.plainLyrics then
            return data.plainLyrics, false
        end
        return nil, false
    end,
    result_strip_html = false
}

-- Return the providers as lua table
-- You can use this table to sort or disable providers
return {
    p_lrclib,
    p_www_songtexte_com,
}
