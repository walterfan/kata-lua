#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        fputs("failed to create Lua state\n", stderr);
        return 1;
    }

    luaL_openlibs(L);

    const char *script =
        "function greet(name)\n"
        "    return 'Hello from Lua, ' .. (name or 'stranger') .. '!'\n"
        "end\n";

    if (luaL_dostring(L, script) != LUA_OK) {
        fprintf(stderr, "failed to compile script: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
        lua_close(L);
        return 1;
    }

    lua_getglobal(L, "greet");
    lua_pushstring(L, "Walter");

    if (lua_pcall(L, 1, 1, 0) != LUA_OK) {
        fprintf(stderr, "failed to execute greet: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
        lua_close(L);
        return 1;
    }

    const char *result = lua_tostring(L, -1);
    printf("Result from Lua: %s\n", result);
    lua_pop(L, 1);

    lua_close(L);
    return 0;
}
