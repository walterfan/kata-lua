-- ivr_menu.lua
-- Robust IVR menu implementation for FreeSWITCH mod_lua

assert(session, "this script must run within a FreeSWITCH call session")

local function safe_get_variable(var_name, default_val)
    local val = session:getVariable(var_name)
    if not val or val == "" then
        return default_val
    end
    return val
end

local function run_ivr()
    session:answer()
    session:sleep(500)

    if not session:ready() then
        return
    end

    local caller_id = safe_get_variable("caller_id_number", "anonymous")
    freeswitch.consoleLog("INFO", string.format("[IVR] Incoming call from %s\n", caller_id))

    -- Collect single DTMF digit (1-9) with 5000ms timeout
    -- session:playAndGetDigits(min_digits, max_digits, max_attempts, timeout, terminators, prompt_audio, bad_audio, digits_regex)
    local digit = session:playAndGetDigits(
        1, 1, 3, 5000, "#",
        "ivr/ivr-please_enter_pin_or_extension.wav",
        "ivr/ivr-that_was_an_invalid_entry.wav",
        "\\d+"
    )

    if digit == "1" then
        session:streamFile("ivr/ivr-connecting.wav")
        session:execute("transfer", "1000 XML default")
    elseif digit == "2" then
        session:streamFile("ivr/ivr-connecting.wav")
        session:execute("transfer", "2000 XML default")
    else
        session:streamFile("ivr/ivr-call_cannot_be_completed_as_dialed.wav")
        session:hangup("NORMAL_CLEARING")
    end
end

run_ivr()
