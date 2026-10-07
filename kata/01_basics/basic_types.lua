-- basic_types.lua
-- Demonstrates Lua basic types, 1-based indexing, and truthiness rules

local function demonstrate_truthiness()
    -- Only false and nil are falsy in Lua!
    local zero = 0
    local empty_str = ""
    local empty_table = {}

    assert(zero, "0 must be truthy in Lua")
    assert(empty_str, "empty string must be truthy in Lua")
    assert(empty_table, "empty table must be truthy in Lua")
    assert(not nil, "nil is falsy")
    assert(not false, "false is falsy")
end

local function demonstrate_tables()
    -- 1-based indexing
    local fruits = {"apple", "banana", "cherry"}
    assert(#fruits == 3, "length must be 3")
    assert(fruits[1] == "apple", "first element is at index 1")
    assert(fruits[0] == nil, "index 0 is nil by default")

    -- Associative mapping
    fruits["tropical"] = "mango"
    assert(fruits.tropical == "mango")

    -- Sequence iteration with ipairs
    local collected = {}
    for i, v in ipairs(fruits) do
        collected[#collected + 1] = string.format("%d:%s", i, v)
    end
    assert(table.concat(collected, ",") == "1:apple,2:banana,3:cherry")
end

demonstrate_truthiness()
demonstrate_tables()
print("01_basics: basic_types passed successfully!")
