-- hello.lua
-- Minimal FreeSWITCH call script

assert(session, "this script must run within a FreeSWITCH call session")

session:answer()

if session:ready() then
    session:streamFile("ivr/ivr-welcome_to_freeswitch.wav")
end

if session:ready() then
    session:hangup()
end
