-- {"name": "Folderart", "file": "Folderart/Folderart.lua", "version": 1, "desc": "Creates folderart on demand.", "order": 0, "arguments": ["path"]}

local rc, msg = mympd.check_arguments({path = "notempty"})
if rc == false then
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Get first song
local result
rc, result = mympd.api("MYMPD_API_DATABASE_FILESYSTEM_LIST", {
    offset = 0,
    limit = 1,
    path = mympd_arguments.path,
    type = "dir",
    searchstr = "",
    fields = {}
})
if rc ~= 0 then
    mympd.log(3, "Folder not found")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

if result.data[1] == nil then
    mympd.log(3, "Folder is empty")
    return mympd.http_redirect("/assets/coverimage-folder")
end

return mympd.http_redirect("/albumart?offset=0&uri=" .. mympd.urlencode(result.data[1].uri))
