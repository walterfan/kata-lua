extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

lua_State* L = luaL_newstate(); 
luaL_openlibs(L); 

int error = luaL_loadstring(L, "print 'Hello World!'")
|| lua_pcall(L, 0, 0, 0);
if (error) {
fprintf(stderr, "%s", lua_tostring(L, -1));
lua_pop(L, 1);
}

lua_close(L);