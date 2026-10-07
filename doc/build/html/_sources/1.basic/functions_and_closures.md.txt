# 1.3 函数、多返回值与闭包机制

## 1. 第一类值（First-Class Value）

Lua 函数是第一类值，这意味着函数可以像数字和字符串一样存储在变量中、作为参数传递或作为返回值返回。

## 2. 多返回值与截断陷阱

Lua 函数天然支持多返回值：

```lua
local function divide(a, b)
    if b == 0 then
        return nil, "division by zero"
    end
    return a / b, nil
end

local res, err = divide(10, 2)
```

### 截断规则

当多返回值函数调用不是表达式列表的**最后一项**时，其返回值会被强行截断为仅保留第一个：

```lua
local function foo()
    return "a", "b", "c"
end

local function test(x, y, z)
    print(x, y, z)
end

test(foo(), "tail")  -- 输出: a  tail  nil  (foo 返回值被截断为1个)
test("head", foo())  -- 输出: head  a  b     (位于末尾时完整展开)
```

## 3. 闭包与 Upvalue

闭包由函数原型及其捕获的外部局部变量（Upvalue）共同组成：

```lua
local function make_counter(start)
    local count = start or 0
    return function()
        count = count + 1
        return count
    end
end

local c1 = make_counter(10)
print(c1()) -- 11
print(c1()) -- 12
```

Upvalue 在外部函数返回后依然存活，分配在堆上并被闭包引用，只有当所有闭包均释放后才由垃圾回收器回收。
