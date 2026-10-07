# 8.2 Lua C API 函数速查

## 1. 状态机管理

```c
lua_State *L = luaL_newstate();
luaL_openlibs(L);
lua_close(L);
```

## 2. 栈查询与操作

```c
int lua_gettop(lua_State *L);
void lua_settop(lua_State *L, int index);
void lua_pushvalue(lua_State *L, int index);
void lua_remove(lua_State *L, int index);
void lua_insert(lua_State *L, int index);
void lua_replace(lua_State *L, int index);
```

## 3. 类型获取与转换

```c
int lua_type(lua_State *L, int index);
int lua_isnumber(lua_State *L, int index);
int lua_isstring(lua_State *L, int index);

lua_Number lua_tonumber(lua_State *L, int index);
lua_Integer lua_tointeger(lua_State *L, int index);
int lua_toboolean(lua_State *L, int index);
const char *lua_tostring(lua_State *L, int index);
```

## 4. 函数调用与错误处理

```c
int lua_pcall(lua_State *L, int nargs, int nresults, int msgh);
int luaL_dostring(lua_State *L, const char *str);
int luaL_dofile(lua_State *L, const char *filename);
```
