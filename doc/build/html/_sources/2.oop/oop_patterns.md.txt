# 2.2 Lua 面向对象惯用模式

## 经典单继承模式

```lua
local Class = {}
Class.__index = Class

function Class:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Class:extend()
    local sub_class = {}
    sub_class.__index = sub_class
    setmetatable(sub_class, self)
    return sub_class
end

-- 基类
local Animal = Class:new()
function Animal:speak()
    return "..."
end

-- 派生类
local Dog = Animal:extend()
function Dog:speak()
    return "Woof!"
end

local d = Dog:new()
print(d:speak()) -- Woof!
```

## 多重继承与方法查找

在复杂场景下，`__index` 可以是一个函数，用于在多个父类列表中依次查找方法：

```lua
local function search(key, parents)
    for i = 1, #parents do
        local val = parents[i][key]
        if val then return val end
    end
end

local function create_class(...)
    local c = {}
    local parents = {...}
    setmetatable(c, {
        __index = function(t, k)
            return search(k, parents)
        end
    })
    c.__index = c
    function c:new(o)
        o = o or {}
        setmetatable(o, c)
        return o
    end
    return c
end
```
