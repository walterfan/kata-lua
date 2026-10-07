# Lua 速查手册 (Cheat Sheet)

专注于 Lua 5.1 ~ 5.4 关键语法、标准库函数、C API 及常见模式。

---

## 1. 基础语法与核心类型

### 变量与作用域

```lua
local x = 10           -- 局部变量（强烈推荐）
global_y = 20          -- 全局变量（存入 _G，需谨慎）
local multiline = [[多行
文本内容]]
```

### 真假值（Truthiness）
- **只有 `nil` 和 `false` 为假**
- `0`、`""` (空字符串)、`{}` (空表) 全为真值！

---

## 2. 表（Table）操作

```lua
-- 1. 数组定义（下标从 1 开始）
local fruits = { "apple", "banana", "cherry" }
print(fruits[1])  -- apple
print(#fruits)    -- 3

-- 2. 散列表（Hash / Map）
local user = { name = "Walter", role = "admin" }
print(user.name)  -- 或 user["name"]

-- 3. 遍历方式
for i, v in ipairs(fruits) do
    -- 遍历连续数组，遇到 nil 立即停止
end

for k, v in pairs(user) do
    -- 遍历所有键值对，无固定顺序
end
```

---

## 3. 函数与闭包

```lua
-- 多返回值与标准错误模式
local function safe_divide(a, b)
    if b == 0 then
        return nil, "division by zero"
    end
    return a / b, nil
end

-- 可变参数
local function sum(...)
    local total = 0
    for _, v in ipairs({...}) do
        total = total + v
    end
    return total
end

-- 闭包与计数器
local function make_counter()
    local c = 0
    return function()
        c = c + 1
        return c
    end
end
```

---

## 4. 元表与面向对象 (Metatables)

```lua
local Class = {}
Class.__index = Class

function Class:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Class:greet()
    return "Hello, " .. (self.name or "guest")
end

local obj = Class:new({ name = "Alice" })
print(obj:greet()) -- 调用相当于 obj.greet(obj)
```

### 核心元方法（Metamethods）
- `__index`: 查找缺失键时的回退表或函数
- `__newindex`: 给缺失键赋值时的拦截
- `__tostring`: 自定义输出字符串
- `__call`: 允许像调用函数一样调用表
- `__add`, `__sub`, `__mul`, `__div`: 运算符重载
- `__eq`, `__lt`, `__le`: 比较符重载

---

## 5. 协程 (Coroutines)

```lua
local co = coroutine.create(function(val)
    local yield_reply = coroutine.yield(val * 2)
    return yield_reply + 10
end)

local ok, ret1 = coroutine.resume(co, 20)  -- true, 40
local ok, ret2 = coroutine.resume(co, 5)   -- true, 15
```

---

## 6. 字符串与模式匹配 (Pattern Matching)

| 符号 | 描述 | 符号 | 描述 |
|---|---|---|---|
| `.` | 任意字符 | `%a` | 字母 |
| `%d` | 数字 (0-9) | `%w` | 字母与数字 |
| `%s` | 空白字符 | `%p` | 标点符号 |
| `%b()`| 匹配成对括号 | `^`, `$` | 行首/行尾锚点 |

```lua
-- 捕获提取
local year, month, day = string.match("2026-10-06", "(%d+)-(%d+)-(%d+)")

-- 全局替换
local s = string.gsub("hello world", "(%a+)", "[%1]") -- [hello] [world]

-- 循环匹配
for word in string.gmatch("lua is great", "%a+") do
    print(word)
end
```

---

## 7. 错误处理

```lua
-- assert: 断言为真，否则抛出错误
assert(type(num) == "number", "num must be a number")

-- pcall: 保护模式调用，捕获运行时异常
local ok, res_or_err = pcall(function()
    return risky_function()
end)
if not ok then
    print("Caught error:", res_or_err)
end
```

---

## 8. C API 核心函数速查

```c
// 栈状态
int lua_gettop(lua_State *L);
void lua_pop(lua_State *L, int n);

// 数据压栈
void lua_pushinteger(lua_State *L, lua_Integer n);
void lua_pushstring(lua_State *L, const char *s);
void lua_pushboolean(lua_State *L, int b);

// 数据转换
lua_Integer lua_tointeger(lua_State *L, int idx);
const char *lua_tostring(lua_State *L, int idx);
int lua_toboolean(lua_State *L, int idx);

// 调用与加载
int lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);
int luaL_dostring(lua_State *L, const char *str);
```
