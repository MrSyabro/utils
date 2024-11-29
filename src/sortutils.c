#include <lua.h>
#include <lauxlib.h>

static int lua_defcomp(lua_State *L) {
    int iseq = lua_compare(L, 1, 2, LUA_OPEQ);
    if (iseq) {
        lua_pushnil(L);
    } else {
        int iscomp = lua_compare(L, 1, 2, LUA_OPLT);
        lua_pushboolean(L, iscomp);
    }
    return 1;
}

static int lua_sortinser(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checkany(L, 2);
    lua_len(L, 1);
    lua_Integer n = lua_tointeger(L, -1);
    lua_pop(L, 1);
    if (!lua_isfunction(L, 3)) {
        lua_settop(L, 2);
        lua_pushcfunction(L, lua_defcomp);
    }

    for (int i = n; i >= 1; i--) {
        lua_geti(L, 1, i);

        // подготавливаем стек к вызову компоратора
        lua_pushvalue(L, 3);
        lua_pushvalue(L, -2);
        lua_pushvalue(L, 2);

        lua_call(L, 2, 1);

        if (lua_toboolean(L, -1)) {
            lua_pop(L, 3);
            lua_seti(L, 1, ++i);
            lua_pushinteger(L, i);
            return 1;
        } else {
            lua_pop(L, 1);
            lua_seti(L, 1, i+1);
            lua_pushnil(L);
            lua_seti(L, 1, i);
        }
    }

    lua_pop(L, 1);
    lua_seti(L, 1, 1);
    lua_pushinteger(L, 1);
    return 1;
}

static int lua_search(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE); //list
    luaL_checkany(L, 2); //value
    lua_len(L, 1);
    lua_Integer n = lua_tointeger(L, -1);
    lua_pop(L, 1);
    if (lua_isnoneornil(L, 3)) {
        lua_settop(L, 2);
        lua_pushcfunction(L, lua_defcomp);
    } //comp
    if (lua_isnoneornil(L, 4)) {
        lua_settop(L, 3);
        lua_pushinteger(L, n);
    } //i
    if (lua_isnoneornil(L, 5)) {
        lua_settop(L, 4);
        lua_pushinteger(L, 1);
    } //j
    lua_settop(L, 5);

    lua_Integer i = luaL_checkinteger(L, 4);
    lua_Integer j = luaL_checkinteger(L, 5);
    if ((i - j) < 0) return 0;
    lua_Integer mid = i + (lua_Integer)((j - i)/2);

    // подготавливаем стек к вызову компоратора
    lua_pushvalue(L, 3);
    lua_geti(L, 1, mid);
    lua_pushvalue(L, 2);

    lua_call(L, 2, 1);

    if (lua_isnoneornil(L, -1)) {
        lua_pushinteger(L, mid);
        lua_geti(L, 1, mid);
        return 2;
    } else {
        int iseq = lua_toboolean(L, -1);
        lua_settop(L, 3);
        if (iseq) {
            lua_pushinteger(L, i);
            lua_pushinteger(L, mid + 1);
        } else {
            lua_pushinteger(L, mid - 1);
            lua_pushinteger(L, j);
        }
        return lua_search(L);
    }

    return 0;
}

#if defined(_WIN32) || defined(_WIN64)
__declspec(dllexport)
#endif
int luaopen_sortutils(lua_State *L) {
    lua_getglobal(L, "table");

    lua_pushcfunction(L, lua_sortinser);
    lua_setfield(L, -2, "sortinsert");

    lua_pushcfunction(L, lua_search);
    lua_setfield(L, -2, "sortsearch");

    return 0;
}
