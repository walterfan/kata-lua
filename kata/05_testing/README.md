# 05 Testing Kata

Demonstrates unit testing patterns in Lua without external dependencies (and compatible with Busted conventions).

## Files

- `test_runner.lua`: A lightweight, zero-dependency mini-test framework with `describe`, `it`, and `assert` helpers.
- `ivr_service.lua`: Business logic service isolated from FreeSWITCH global dependencies.
- `test_ivr_service.lua`: Unit tests asserting state transitions and input validation using mock session.

## Run

```bash
lua test_ivr_service.lua
```
