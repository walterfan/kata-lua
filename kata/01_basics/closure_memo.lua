-- closure_memo.lua
-- Demonstrates closures, upvalues, and a generic memoization wrapper

local function create_counter(initial_value)
    local count = initial_value or 0
    return function(step)
        count = count + (step or 1)
        return count
    end
end

local function memoize(fn)
    local cache = {}
    return function(arg)
        if cache[arg] == nil then
            cache[arg] = fn(arg)
        end
        return cache[arg]
    end
end

-- Test counter
local counter_a = create_counter(10)
assert(counter_a() == 11)
assert(counter_a(5) == 16)

local counter_b = create_counter(0)
assert(counter_b() == 1)
assert(counter_a() == 17) -- Counter A remains independent

-- Test memoize with expensive fibonacci
local calc_count = 0
local function slow_fib(n)
    calc_count = calc_count + 1
    if n <= 1 then return n end
    -- recursive call without memo for demo
    local a, b = 0, 1
    for _ = 2, n do
        a, b = b, a + b
    end
    return b
end

local fast_fib = memoize(slow_fib)
assert(fast_fib(10) == 55)
assert(calc_count == 1)

-- Second call should use cache
assert(fast_fib(10) == 55)
assert(calc_count == 1, "Cached call should not recompute")

assert(fast_fib(11) == 89)
assert(calc_count == 2)

print("01_basics: closure_memo passed successfully!")
