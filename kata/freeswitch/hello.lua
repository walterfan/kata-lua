-- FreeSWITCH supplies `session` when this script is invoked by a call.
assert(session, "this script must run in a FreeSWITCH call session")

session:answer()

if session:ready() then
    session:streamFile("ivr/ivr-welcome_to_freeswitch.wav")
end

if session:ready() then
    session:hangup()
end
