-- {"order":1,"arguments":[]}

local p_www_songtexte_com = {
    name = "Songtexte",
    artist_filter = function(artist)
        artist = artist:gsub(" ", "-")
        artist = artist:lower(artist)
        return artist
    end,
    title_filter = function(title)
        title = title:gsub(" ", "-")
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
        return result
    end,
    result_strip_html = true
}

-- Return the providers as lua table
-- You can use this table to sort or disable providers
return { 
    p_www_songtexte_com,
}
