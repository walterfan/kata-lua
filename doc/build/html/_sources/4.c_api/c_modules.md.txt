# 4.3 编写 C 扩展模块供 Lua 调用

Lua 遵循特定导出约定动态加载 C 动态链接库：`luaopen_<modname>`。

```c
#include <lua.h>
#include <lauxlib.h>

static int l_square(lua_State *L) {
    double d = luaL_checknumber(L, 1);
    lua_pushnumber(L, d * d);
    return 1; // 返回值个数
}

static const struct luaL_Reg mymath_funcs[] = {
    {"square", l_square},
    {NULL, NULL}
};

int luaopen_mymath(lua_State *L) {
    luaL_newlib(L, mymath_funcs);
    return 1;
}
```

编译生成 `mymath.so` (Linux) 或 `mymath.dylib` (macOS) 后，即可在 Lua 中直接加载：

```lua
local mymath = require("mymath")
print(mymath.square(9)) -- 81
```
