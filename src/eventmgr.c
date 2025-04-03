#include <math.h>
#include <lua.h>
#include <lauxlib.h>

static int levent_new (lua_State *L) {
    lua_createtable(L, 0, 0);
    luaL_getmetatable(L, "event");
    lua_setmetatable(L, -2);

    

    return 1;
}

static int send_handler (lua_State *L) {
    
    
    return 0;
}

static int levent_send (lua_State *L) {
    luaL_checktype(L, 1, LUA_TUSERDATA);
    int top = lua_gettop(L);
    top--;

    // TODO send

    return 1;
}

static const struct luaL_Reg event [] = {
    {"new", lvec_new},
    {"send", levent_send},
    {NULL, NULL} /* sentinel */
};

#if defined(_WIN32) || defined(_WIN64)
__declspec(dllexport)
#endif
int luaopen_event(lua_State *L) {
    luaL_newmetatable(L, "event");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_setfuncs(L, event, 0);

    return 1;
}

// Для подключения в другом Си коде
int luasetglobal_event (lua_State *L) {
    lua_settop(L, 0);
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_getfield(L, -1, "event");
    if (lua_isnoneornil(L, -1)) {
        lua_pushcfunction(L, luaopen_vec);
        lua_setfield(L, -3, "event");
    }
    lua_settop(L, 0);

    return 0;
}