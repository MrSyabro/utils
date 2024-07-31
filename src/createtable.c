#include <lua.h>
#include <lauxlib.h>

static int l_createtable (lua_State *L) {
    lua_Integer narr = luaL_checkinteger(L, 1);
    lua_Integer nrec = luaL_checkinteger(L, 2);

    lua_createtable(L, (int)narr, (int)nrec);

    return 1;
}

int luaopen_createtable(lua_State *L) {

    lua_pushcfunction(L, l_createtable);

    return 1;
}

int luasetglobal_createtable (lua_State *L) {
    luaopen_createtable(L);
    lua_setglobal(L, "createtable");
    return 0;
}