# 3.2 协作式微调度器实操

通过协程和简单的队列，可以在不依赖 OS 线程的情况下构建高效的协作式调度器：

```lua
local TaskQueue = {}

function TaskQueue.new()
    return { tasks = {}, head = 1, tail = 1 }
end

function TaskQueue:push(task)
    self.tasks[self.tail] = task
    self.tail = self.tail + 1
end

function TaskQueue:pop()
    if self.head >= self.tail then return nil end
    local task = self.tasks[self.head]
    self.tasks[self.head] = nil
    self.head = self.head + 1
    return task
end

local Scheduler = {}

function Scheduler.new()
    return { q = TaskQueue.new() }
end

function Scheduler:spawn(fn, ...)
    local args = {...}
    local co = coroutine.create(fn)
    self.q:push({ co = co, args = args })
end

function Scheduler:run()
    while true do
        local item = self.q:pop()
        if not item then break end
        local ok, err = coroutine.resume(item.co, table.unpack(item.args))
        if not ok then
            print("Task error:", err)
        elseif coroutine.status(item.co) ~= "dead" then
            self.q:push({ co = item.co, args = {} })
        end
    end
end
```
