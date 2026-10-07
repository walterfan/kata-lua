-- micro_scheduler.lua
-- Demonstrates a cooperative event scheduler using coroutine primitives

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new()
    return setmetatable({ tasks = {} }, Scheduler)
end

function Scheduler:spawn(fn, ...)
    local args = {...}
    local co = coroutine.create(fn)
    local task = {
        co = co,
        args = args,
        is_first = true
    }
    table.insert(self.tasks, task)
end

function Scheduler:step()
    if #self.tasks == 0 then return false end
    local current = table.remove(self.tasks, 1)

    local ok, res
    if current.is_first then
        current.is_first = false
        ok, res = coroutine.resume(current.co, table.unpack(current.args))
    else
        ok, res = coroutine.resume(current.co)
    end

    if not ok then
        error("Task execution error: " .. tostring(res))
    end

    if coroutine.status(current.co) ~= "dead" then
        -- Put back at end of queue
        table.insert(self.tasks, current)
    end
    return true
end

function Scheduler:run()
    while self:step() do end
end

-- Test scheduler
local sched = Scheduler.new()
local logs = {}

sched:spawn(function(name, count)
    for i = 1, count do
        logs[#logs + 1] = string.format("%s-%d", name, i)
        coroutine.yield()
    end
end, "TaskA", 3)

sched:spawn(function(name, count)
    for i = 1, count do
        logs[#logs + 1] = string.format("%s-%d", name, i)
        coroutine.yield()
    end
end, "TaskB", 3)

sched:run()

local result = table.concat(logs, ",")
assert(result == "TaskA-1,TaskB-1,TaskA-2,TaskB-2,TaskA-3,TaskB-3", "Interleaved execution failed: " .. result)

print("03_coroutines: micro_scheduler passed successfully!")
