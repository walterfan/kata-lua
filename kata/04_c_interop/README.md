# 04 C Interop Kata

Exercises demonstrating C and Lua interoperability:
1. C embedding Lua interpreter and invoking scripts.
2. C registering native functions to Lua state.

## Demos

- `call_lua_demo.c`: Minimal host application creating a Lua state and executing Lua code.
- `lua_state_demo.c`: Host application exposing a custom C function (`drawText`) to Lua and inspecting return values.

## Build and Run

From project root:

```bash
make c-demo
./build/call_lua_demo

make lua-state-demo
./build/lua_state_demo
```
