# 4.2 C 程序嵌入 Lua

在 C/C++ 宿主中执行 Lua 脚本的典型骨架：

```c
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(void) {
    // 1. 创建 Lua 状态机
    lua_State *L = luaL_newstate();
    if (!L) {
        fprintf(stderr, "cannot create lua state\n");
        return 1;
    }

    // 2. 加载基础标准库
    luaL_openlibs(L);

    // 3. 执行 Lua 代码片段或文件
    if (luaL_dostring(L, "function add(a, b) return a + b end") != LUA_OK) {
        fprintf(stderr, "error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
        lua_close(L);
        return 1;
    }

    // 4. 调用 Lua 函数
    lua_getglobal(L, "add");
    lua_pushinteger(L, 10);
    lua_pushinteger(L, 32);

    if (lua_pcall(L, 2, 1, 0) != LUA_OK) {
        fprintf(stderr, "call failed: %s\n", lua_tostring(L, -1));
    } else {
        printf("Result: %lld\n", lua_tointeger(L, -1));
        lua_pop(L, 1);
    }

    // 5. 释放资源
    lua_close(L);
    return 0;
}
```
