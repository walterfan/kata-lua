-- test_ivr_service.lua
-- Unit tests using test_runner and mock adapter

local T = require("kata.05_testing.test_runner")
local IVRService = require("kata.05_testing.ivr_service")

local function create_mock_session(opts)
    opts = opts or {}
    local answered = false
    local hungup_cause = nil
    local played_files = {}

    return {
        is_ready = function(self) return opts.ready ~= false end,
        answer = function(self) answered = true end,
        hangup = function(self, cause) hungup_cause = cause end,
        play_file = function(self, f) played_files[#played_files + 1] = f end,
        get_variable = function(self, k) return (opts.vars or {})[k] end,

        -- Inspectors
        is_answered = function(self) return answered end,
        get_hungup_cause = function(self) return hungup_cause end,
        get_played_files = function(self) return played_files end,
    }
end

T.describe("IVRService Unit Tests", function()
    T.it("should reject when session is not ready", function()
        local mock = create_mock_session({ ready = false })
        local service = IVRService.new(mock)
        local ok, err = service:handle_incoming_call()
        assert(ok == false)
        assert(err == "session not ready")
        assert(mock.is_answered() == false)
    end)

    T.it("should reject blocked caller with CALL_REJECTED", function()
        local mock = create_mock_session({ vars = { caller_id_number = "blocked_user" } })
        local service = IVRService.new(mock)
        local ok, err = service:handle_incoming_call()
        assert(ok == false)
        assert(err == "blocked caller")
        assert(mock.is_answered() == true)
        assert(mock.get_hungup_cause() == "CALL_REJECTED")
    end)

    T.it("should play welcome prompt for legitimate caller", function()
        local mock = create_mock_session({ vars = { caller_id_number = "+14085551234" } })
        local service = IVRService.new(mock)
        local ok, caller = service:handle_incoming_call()
        assert(ok == true)
        assert(caller == "+14085551234")
        assert(mock.is_answered() == true)
        local played = mock.get_played_files()
        assert(#played == 1 and played[1] == "welcome.wav")
    end)
end)

T.summary()
