# 1.2 Table 内部机制与边界陷阱

Table 是 Lua 中唯一的复合数据结构，具备数组（Array）与哈希（Hash）双重语义。

## 1. 数组部分与 1-Based 索引

Lua 的数组默认从下标 `1` 开始：

```lua
local fruits = {"apple", "banana", "cherry"}
print(fruits[1]) -- 输出 "apple"
print(fruits[0]) -- 输出 nil（除非显式赋值）
```

## 2. 长度操作符 `#` 与 nil-hole 陷阱

长度操作符 `#` 仅在连续序列（Sequence）上有明确保障。如果数组中间存在 `nil`（即洞，hole），`#t` 的结果是未定义的（可能命中任意一个满足 `t[i] ~= nil and t[i+1] == nil` 的边界）。

```lua
local list = {1, 2, nil, 4}
print(#list) -- 结果可能为 4 或 2，不可依赖！
```

### 规避方案

- 如果需要存储可能含 `nil` 的列表，可显式维护 `n` 字段：
  ```lua
  local packed = table.pack(1, 2, nil, 4)
  print(packed.n) -- 严格为 4
  ```

## 3. 遍历机制：`ipairs` vs `pairs`

- `ipairs`: 严格遍历下标从 1 开始的递增整数序列，一旦遇到 `nil` 立即终止。
- `pairs`: 遍历 Table 的所有键（包括非整数键和所有离散键），无序。

```lua
local user = { name = "Alice", [1] = "first", [2] = "second", age = 30 }

for i, v in ipairs(user) do
    print("ipairs:", i, v) -- 仅输出 1, 2
end

for k, v in pairs(user) do
    print("pairs:", k, v) -- 输出 name, 1, 2, age
end
```
