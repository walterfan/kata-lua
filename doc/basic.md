# Lua basics

## Important habits

- Declare variables and functions with `local` unless a host application
  requires a global.
- Remember that table array indexes start at `1`.
- Remember that only `false` and `nil` are false.
- Use `ipairs` for a contiguous sequence and `pairs` for general table keys.
- Return `nil, error_message` for expected failures; reserve `error` for cases
  the current caller cannot recover from.
- Keep modules free of side effects so they are easy to load and test.

## Practice order

1. Values, expressions, and control flow
2. Tables and iteration
3. Functions, closures, and multiple return values
4. Modules and `require`
5. Errors with `assert`, `error`, and `pcall`
6. Coroutines and embedding

Start with [the hello kata](../kata/basics/hello.lua).
