-- ivr_service.lua
-- Telephony business logic isolated from FreeSWITCH session global

local IVRService = {}
IVRService.__index = IVRService

function IVRService.new(session_adapter)
    local self = setmetatable({}, IVRService)
    self.session = session_adapter
    return self
end

function IVRService:handle_incoming_call()
    if not self.session:is_ready() then
        return false, "session not ready"
    end

    self.session:answer()
    local caller_id = self.session:get_variable("caller_id_number") or "anonymous"

    -- Authenticate or route
    if caller_id == "blocked_user" then
        self.session:hangup("CALL_REJECTED")
        return false, "blocked caller"
    end

    self.session:play_file("welcome.wav")
    return true, caller_id
end

return IVRService
