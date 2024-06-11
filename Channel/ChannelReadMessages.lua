-- {"name": "ChannelReadMessages", "file": "Channel/ChannelReadMessages.lua", "version": 1, "desc": "Reads all message from a MPD channel.", "order":0, "arguments":[]}

local rc, result =  mympd.api("MYMPD_API_CHANNEL_MESSAGES_READ", {})

if rc == 1 or result.totalEntities == 0 then
    return
end

local messages = ""
for _, msg in pairs(result.data) do
    messages = messages .. msg.channel .. ": " .. msg.message
end

return messages
