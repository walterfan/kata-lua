#include <stdio.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

static int drawText(lua_State* luaState)
{
  float screenPosY = (float) lua_tonumber(luaState, -1);// get the value 160
  float screenPosX = (float) lua_tonumber(luaState, -2);// get the value 240
  const char* str = lua_tostring(luaState, -3);// get the value "Ready Go~"
  printf("Text '%s' draw at (%f, %f)\n", str, screenPosX, screenPosY);

  int textWidth= strlen(str);
  lua_pushnumber(luaState, textWidth);// return a value to Lua
  return 1;// number of values return to Lua
}

// run lucal script: local w = drawText('Ready Go~',  240, 160)
int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        fputs("failed to create Lua state\n", stderr);
        return 1;
    }

    luaL_openlibs(L);

    // register C function to Lua
    lua_register(L, "drawText", drawText);

    int error = luaL_loadstring(L, "print('text width: ' .. drawText('Ready Go~',  240, 160))") ||
                lua_pcall(L, 0, 0, 0);
    if (error) {
        const char *message = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", message != NULL ? message : "Lua error");
        lua_pop(L, 1);
    }

    lua_close(L);
    return error ? 1 : 0;
}
