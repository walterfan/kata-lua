#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int l_draw_text(lua_State *L) {
    // Lua call: drawText(str, x, y)
    const char *str = luaL_checkstring(L, 1);
    double x = luaL_checknumber(L, 2);
    double y = luaL_checknumber(L, 3);

    printf("[C Host] Drawing '%s' at (%.1f, %.1f)\n", str, x, y);

    size_t len = strlen(str);
    lua_pushinteger(L, (lua_Integer)len);
    return 1; // 1 return value
}

int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        fputs("failed to create Lua state\n", stderr);
        return 1;
    }

    luaL_openlibs(L);

    // Register C function into Lua global table
    lua_register(L, "drawText", l_draw_text);

    const char *script =
        "local width = drawText('Ready Go~', 240.0, 160.0)\n"
        "print('Returned width to Lua: ' .. width)\n"
        "assert(width == 9, 'width check failed')\n";

    if (luaL_dostring(L, script) != LUA_OK) {
        fprintf(stderr, "execution error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
        lua_close(L);
        return 1;
    }

    lua_close(L);
    printf("04_c_interop: lua_state_demo completed successfully!\n");
    return 0;
}
