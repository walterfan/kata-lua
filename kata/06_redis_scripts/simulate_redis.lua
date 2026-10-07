-- simulate_redis.lua
-- Simulates Redis runtime to test Lua scripts locally without live Redis instance

local mock_db = {}

_G.redis = {
    call = function(cmd, ...)
        local args = {...}
        cmd = string.upper(cmd)

        if cmd == "GET" then
            local k = args[1]
            return mock_db[k]
        elseif cmd == "DEL" then
            local k = args[1]
            if mock_db[k] ~= nil then
                mock_db[k] = nil
                return 1
            end
            return 0
        elseif cmd == "HMGET" then
            local k = args[1]
            local hash = mock_db[k] or {}
            local res = {}
            for i = 2, #args do
                res[#res + 1] = hash[args[i]]
            end
            return res
        elseif cmd == "HMSET" then
            local k = args[1]
            mock_db[k] = mock_db[k] or {}
            for i = 2, #args, 2 do
                mock_db[k][args[i]] = tostring(args[i+1])
            end
            return "OK"
        end
        error("Unsupported command: " .. cmd)
    end
}

-- 1. Test Distributed Lock Release
mock_db["lock:res_100"] = "uuid-client-1"

_G.KEYS = { "lock:res_100" }
_G.ARGV = { "uuid-client-wrong" }
local lock_code = loadfile("kata/06_redis_scripts/distributed_lock.lua")
local res1 = lock_code()
assert(res1 == 0, "Wrong lock owner must return 0")
assert(mock_db["lock:res_100"] == "uuid-client-1", "Lock must remain held")

_G.ARGV = { "uuid-client-1" }
local res2 = lock_code()
assert(res2 == 1, "Correct lock owner must release and return 1")
assert(mock_db["lock:res_100"] == nil, "Lock key must be deleted")

-- 2. Test Token Bucket Rate Limiter
_G.KEYS = { "rate:api_user" }
local tb_code = loadfile("kata/06_redis_scripts/token_bucket.lua")

-- Capacity: 10, refill: 0.01 tokens/ms (10 tokens/sec), requested: 8, now: 1000
_G.ARGV = { "10", "0.01", "8", "1000" }
local pass1 = tb_code()
assert(pass1 == 1, "First 8 tokens should be allowed")

-- Request 4 tokens immediately without waiting (only 2 left)
_G.ARGV = { "10", "0.01", "4", "1000" }
local pass2 = tb_code()
assert(pass2 == 0, "Requesting 4 tokens when 2 remain must be denied")

-- Advance clock by 500ms (refills 5 tokens -> 2 + 5 = 7 tokens available)
_G.ARGV = { "10", "0.01", "4", "1500" }
local pass3 = tb_code()
assert(pass3 == 1, "Requesting 4 tokens after 500ms refill must pass")

print("06_redis_scripts: simulated Redis tests completed successfully!")
