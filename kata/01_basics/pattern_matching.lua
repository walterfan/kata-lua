-- pattern_matching.lua
-- Demonstrates Lua pattern matching without regular expression engine

local function parse_url(url)
    -- Capture scheme, host, and path
    local scheme, host, path = string.match(url, "^(%a+)://([^/]+)(.-)$")
    if not scheme then
        return nil, "invalid url"
    end
    if path == "" then path = "/" end
    return {
        scheme = scheme,
        host = host,
        path = path
    }
end

local function parse_key_value_pairs(query_string)
    local result = {}
    for k, v in string.gmatch(query_string, "([^&=]+)=([^&=]+)") do
        result[k] = v
    end
    return result
end

-- Test URL parsing
local info = assert(parse_url("https://api.github.com/users/walterfan"))
assert(info.scheme == "https")
assert(info.host == "api.github.com")
assert(info.path == "/users/walterfan")

-- Test key-value extraction
local query = "lang=lua&level=expert&topic=freeswitch"
local params = parse_key_value_pairs(query)
assert(params.lang == "lua")
assert(params.level == "expert")
assert(params.topic == "freeswitch")

print("01_basics: pattern_matching passed successfully!")
