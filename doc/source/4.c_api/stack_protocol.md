# 4.1 Lua 虚拟栈协议

C 与 Lua 之间的数据交换完全通过抽象的**虚拟栈**完成。

## 正负索引规则

- **正数索引**：从栈底向上递增，栈底为 `1`。
- **负数索引**：从栈顶向下递减，栈顶为 `-1`。

```
     +--------------------+
 4   | "hello" (string)   | -1 (Top)
 3   | 42 (integer)       | -2
 2   | true (boolean)     | -3
 1   | { table }          | -4 (Bottom)
     +--------------------+
```

## 常用栈操作函数

- `lua_gettop(L)`: 返回栈中元素的数量（栈顶索引）。
- `lua_settop(L, index)`: 改变栈的大小，超出被丢弃，缺少补 nil。
- `lua_pushnil(L)`, `lua_pushnumber(L, n)`, `lua_pushstring(L, s)`: 压入数据。
- `lua_toboolean(L, idx)`, `lua_tointeger(L, idx)`, `lua_tostring(L, idx)`: 取出数据。
- `lua_pop(L, n)`: 弹出栈顶的 `n` 个元素。
