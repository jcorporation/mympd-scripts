-- {"order":1,"arguments":["channel", "message"]}

local channel = mympd_arguments.channel
if not channel or channel == "" then
    channel = "myMPD"
end

local rc, result = mympd.api("MYMPD_API_CHANNEL_MESSAGE_SEND", {
    channel = channel,
    message = mympd_arguments.message
})

if rc == 1 then
    return "Failure sending message: " .. result.data.msg
end
