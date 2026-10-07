# 3.1 协程机制与状态流转

## 非对称协程设计

非对称协程意味着有两个不同的函数负责控制流程的转移：
- `coroutine.resume`: 激活或恢复协程运行
- `coroutine.yield`: 挂起协程并交出控制权给其唤醒者

```
[调用者] ── resume(co, args...) ──> [协程 co]
   ▲                                    │
   │                                    ▼
   └────── yield(results...) ───────────┘
```

## 四种状态

1. **suspended**: 新创建或被 `yield` 挂起
2. **running**: 正在执行中的协程自身
3. **normal**: 恢复了其他协程，处于等待被调用协程返回的状态
4. **dead**: 执行完毕或抛出未捕获错误

```lua
local co = coroutine.create(function(x)
    print("co arg:", x)
    local y = coroutine.yield(x * 10)
    print("co resumed with:", y)
    return y * 2
end)

print(coroutine.status(co)) -- suspended
local ok, val1 = coroutine.resume(co, 5)
print("first return:", ok, val1) -- true, 50

local ok, val2 = coroutine.resume(co, 7)
print("second return:", ok, val2) -- true, 14
print(coroutine.status(co)) -- dead
```
