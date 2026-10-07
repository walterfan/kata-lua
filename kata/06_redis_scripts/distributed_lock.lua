-- distributed_lock.lua
-- Atomic release of distributed lock
-- KEYS[1]: lock key
-- ARGV[1]: lock value (unique request id / token)

if redis.call("GET", KEYS[1]) == ARGV[1] then
    return redis.call("DEL", KEYS[1])
else
    return 0
end
