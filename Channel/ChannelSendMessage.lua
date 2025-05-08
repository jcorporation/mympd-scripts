-- {"name": "ChannelSendMessage", "file": "Channel/ChannelSendMessage.lua", "version": 4, "desc": "Sends a message to a MPD channel.", "order":1, "arguments":["channel", "message"]}

local rc, msg = mympd.check_arguments({channel = "notempty", message = "notempty"})
if rc == false then
    return mympd.jsonrpc_error(msg)
end

local result
rc, result = mympd.api("MYMPD_API_CHANNEL_MESSAGE_SEND", {
    channel = mympd_arguments.channel,
    message = mympd_arguments.message
})

if rc == 1 then
    return "Failure sending message: " .. result.data.msg
end
