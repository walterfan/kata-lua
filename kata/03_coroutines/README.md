# 03 Coroutines Kata

Exercises demonstrating Lua coroutines and cooperative multitasking.

## Files

- `generator_pipeline.lua`: Producer-consumer data processing pipeline using `coroutine.wrap` and `coroutine.yield`.
- `micro_scheduler.lua`: A lightweight non-blocking cooperative event loop / task scheduler.

## Run

```bash
lua generator_pipeline.lua
lua micro_scheduler.lua
```
