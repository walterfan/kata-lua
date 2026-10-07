-- generator_pipeline.lua
-- Demonstrates producer-filter-consumer pipeline with coroutine.wrap

local function producer(items)
    return coroutine.wrap(function()
        for _, item in ipairs(items) do
            coroutine.yield(item)
        end
    end)
end

local function filter_even(source)
    return coroutine.wrap(function()
        for item in source do
            if item % 2 == 0 then
                coroutine.yield(item)
            end
        end
    end)
end

local function map_square(source)
    return coroutine.wrap(function()
        for item in source do
            coroutine.yield(item * item)
        end
    end)
end

local raw_data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
local p = producer(raw_data)
local f = filter_even(p)
local s = map_square(f)

local collected = {}
for val in s do
    collected[#collected + 1] = val
end

assert(#collected == 5)
assert(collected[1] == 4)   -- 2^2
assert(collected[2] == 16)  -- 4^2
assert(collected[3] == 36)  -- 6^2
assert(collected[4] == 64)  -- 8^2
assert(collected[5] == 100) -- 10^2

print("03_coroutines: generator_pipeline passed successfully!")
