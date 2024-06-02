-- {"order":1,"arguments":["tag", "value"]}
local providers = require "scripts/TagartProviders"

local tag = mympd_arguments.tag
local value = mympd_arguments.value
mympd.log(7, "Fetching tagart for " .. tag .. "=" .. value)
local out = mympd.tmp_file()
local rc = 1
for _, provider in pairs(providers) do
    if provider.tags[tag] then
        rc = provider.get(tag, value, out)
        if rc == 0 then
            mympd.log(6, "Tagart found on " .. provider.name)
            break
        end
    end
end

if rc == 1 then
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Cache the fetched tagart and send it to the client
local file = mympd.thumbscache_write(out, value)
if file then
    return mympd.http_serve_file(file)
end

return mympd.http_redirect("/assets/coverimage-notavailable")