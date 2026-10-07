# 2.1 Metatables 与核心元方法

元表允许定制普通 Table 的各种基础行为。

## 关键元方法对照表

| 元方法 | 触发时机 | 典型用途 |
|---|---|---|
| `__index` | 读取表中不存在的键 | 原型委托、属性继承、默认值 |
| `__newindex` | 向表中不存在的键赋值 | 拦截赋值、只读保护、数据校验 |
| `__tostring` | `tostring(t)` 或 `print(t)` | 自定义对象的字符串打印 |
| `__call` | 将 Table 作为函数调用 `t(...)` | 函数对象、构造器封装 |
| `__add`, `__sub`, `__mul` | 算术运算符重载 | 向量、复数等数学类型支持 |
| `__eq`, `__lt`, `__le` | 比较运算符重载 | 自定义排序与相等性比较 |

## 拦截机制示例

```lua
local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    local self = setmetatable({}, Vector)
    self.x = x
    self.y = y
    return self
end

function Vector.__add(a, b)
    return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector:__tostring()
    return string.format("Vector(%.1f, %.1f)", self.x, self.y)
end

local v1 = Vector.new(1, 2)
local v2 = Vector.new(3, 4)
print(v1 + v2) -- 输出 Vector(4.0, 6.0)
```
