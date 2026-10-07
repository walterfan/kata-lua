# 1.4 Lua 常见编程陷阱速查

## 1. 假值判定：0 和空字符串均为真

在 Lua 中，**只有 `false` 和 `nil` 视为假值**。`0`、`""`（空字符串）、空表 `{}` 均为真：

```lua
local count = 0
if count then
    print("0 is truthy in Lua!") -- 会被执行
end
```

## 2. 三元运算符模式中的 nil 陷阱

Lua 常用 `cond and a or b` 模拟三元表达式，但若 `a` 本身为 `false` 或 `nil`，将错误返回 `b`：

```lua
local enabled = false
local val = enabled and false or true -- 错误！因为 false 为假，导致结果为 true
```

## 3. 字符串不可变性与频繁拼接

Lua 字符串是不可变且内化的（String Interning）。循环中使用 `..` 拼接大量字符串会产生大量临时字符串与垃圾回收开销：

```lua
-- 低效方案 (O(N^2))
local s = ""
for i = 1, 10000 do
    s = s .. i
end

-- 高效方案 (O(N))
local buf = {}
for i = 1, 10000 do
    buf[#buf + 1] = tostring(i)
end
local s = table.concat(buf)
```
