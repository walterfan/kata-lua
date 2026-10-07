#include <stdio.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/*
lua_State *luaL_newstate (void);
void luaL_openlibs (lua_State *L);
int luaL_loadstring (lua_State *L, const char *s);
int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
*/
int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        fputs("failed to create Lua state\n", stderr);
        return 1;
    }

    luaL_openlibs(L);

    int error = luaL_loadstring(L, "print 'Hello World!'") ||
                lua_pcall(L, 0, 0, 0);
    if (error) {
        const char *message = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", message != NULL ? message : "Lua error");
        lua_pop(L, 1);
    }

    lua_close(L);
    return error ? 1 : 0;
}
