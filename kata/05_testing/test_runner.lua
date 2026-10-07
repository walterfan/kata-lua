-- test_runner.lua
-- Minimalist BDD-style test runner compatible with pure Lua

local M = {}

local current_suite = ""
local passed_count = 0
local failed_count = 0

function M.describe(description, fn)
    current_suite = description
    print(string.format("\n[SUITE] %s", description))
    fn()
end

function M.it(description, fn)
    local ok, err = pcall(fn)
    if ok then
        passed_count = passed_count + 1
        print(string.format("  ✔ %s", description))
    else
        failed_count = failed_count + 1
        print(string.format("  ✘ %s", description))
        print(string.format("    Error: %s", tostring(err)))
    end
end

function M.summary()
    print("\n------------------------------------")
    print(string.format("Test Summary: %d passed, %d failed", passed_count, failed_count))
    print("------------------------------------")
    if failed_count > 0 then
        os.exit(1)
    end
end

return M
