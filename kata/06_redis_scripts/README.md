# 06 Redis Scripts Kata

Production-ready atomic Lua scripts commonly run in Redis via `EVAL` / `EVALSHA`.

## Files

- `token_bucket.lua`: Token bucket rate limiting script.
- `distributed_lock.lua`: Safe release of distributed lock verifying ownership.
- `simulate_redis.lua`: Complete local simulation verifying both scripts against a mock Redis engine.

## Run

```bash
lua simulate_redis.lua
```
