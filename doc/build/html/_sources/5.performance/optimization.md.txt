# 5.1 Lua 核心性能优化法则

## 1. 局部变量缓存（Local Caching）

Lua 中访问局部变量仅需一条基于寄存器的指令，而访问全局变量或模块字段需要查表 `_G` 或 `math` 表：

```lua
-- 低效：每次循环都查找 math 表
for i = 1, 1000000 do
    local s = math.sin(i)
end

-- 高效：局部变量缓存
local sin = math.sin
for i = 1, 1000000 do
    local s = sin(i)
end
```

## 2. Table 重复分配与扩容开销

Lua Table 动态扩容时会重新分配内存并将所有元素重新散列（Rehash），开销显著。
- 在已知大小的情况下，在 LuaJIT 中可使用 `table.new(narr, nhash)` 预分配。
- 复用临时 Table，减少 GC 压力。

## 3. LuaJIT 优化（NYI 注意事项）

LuaJIT 的 JIT 编译器不能编译所有代码（NYI = Not Yet Implemented）。当遇到 NYI 操作时，JIT 追踪会放弃（Trace Abort）并回退到解释执行：
- 避免在内层热点循环中使用 `pairs()`（LuaJIT 2.1 针对 table 做了优化，但仍需谨慎）。
- 避免在热点中频繁捕获异常 `pcall`/`xpcall`。
- 优先使用 LuaJIT FFI 操作 C 内存和结构体，避开传统虚拟栈带来的封箱/拆箱开销。
