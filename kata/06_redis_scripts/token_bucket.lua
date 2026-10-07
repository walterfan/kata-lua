-- token_bucket.lua
-- Token bucket rate limiter executed in Redis
-- KEYS[1]: rate limit key
-- ARGV[1]: capacity (max tokens)
-- ARGV[2]: refill rate (tokens per millisecond)
-- ARGV[3]: requested tokens
-- ARGV[4]: current timestamp in milliseconds

local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local refill_rate = tonumber(ARGV[2])
local requested = tonumber(ARGV[3])
local now = tonumber(ARGV[4])

-- Retrieve current tokens and last update timestamp
local data = redis.call("HMGET", key, "tokens", "last_updated")
local tokens = tonumber(data[1])
local last_updated = tonumber(data[2])

if not tokens then
    tokens = capacity
    last_updated = now
else
    local elapsed = math.max(0, now - last_updated)
    tokens = math.min(capacity, tokens + elapsed * refill_rate)
    last_updated = now
end

if tokens >= requested then
    tokens = tokens - requested
    redis.call("HMSET", key, "tokens", tokens, "last_updated", last_updated)
    return 1 -- Allowed
else
    redis.call("HMSET", key, "tokens", tokens, "last_updated", last_updated)
    return 0 -- Denied
end
