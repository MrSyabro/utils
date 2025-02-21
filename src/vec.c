#include <math.h>
#include <lua.h>
#include <lauxlib.h>

static int lvec_new (lua_State *L) {
    int top = lua_gettop(L);

    lua_createtable(L, top, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (int i = 1; i <= top; i++) {
        lua_pushvalue(L, i);
        lua_rawseti(L, -2, i);
    }

    return 1;
}

static int lvec_newzero (lua_State *L) {
    lua_Integer n = luaL_checkinteger(L, 1);

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (lua_Integer i = 1; i <= n; i++) {
        lua_pushnumber(L, 0);
        lua_rawseti(L, -2, i);
    }

    return 1;
}

static int lvec_newsingle (lua_State *L) {
    lua_Integer n = luaL_checkinteger(L, 1);

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (lua_Integer i = 1; i <= n; i++) {
        lua_pushnumber(L, 1);
        lua_rawseti(L, -2, i);
    }

    return 1;
}

static int lvec_newrange (lua_State *L) {
    lua_Number start = luaL_checknumber(L, 1);
    lua_Number finish = luaL_checknumber(L, 2);
    lua_Number step = 1;
    if (lua_isnumber(L, 3)) step = lua_tonumber(L, 3);

    lua_createtable(L, (finish - start) / step + 1, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    lua_Integer ptr = 1;
    for (lua_Number i = start; (step > 0) ? (i <= finish) : (i >= finish); i+=step) {
        lua_pushnumber(L, i);
        lua_rawseti(L, -2, ptr);
        ptr++;
    }

    return 1;
}

static int lvec_fromhex (lua_State *L) {
    size_t l = 0;
    const char *input = luaL_checklstring(L, 1, &l);
    unsigned char val = 0;

    if (*input == '#') {
        l--;
        input++;
    }

    lua_createtable(L, (int)l/2, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (size_t count = 1; count <= l; count++) {
        sscanf(input, "%2hhx", &val);
        input += 2;
        lua_pushnumber(L, val);
        lua_rawseti(L, -2, count);
    }

    return 1;
}

static int lvec_add (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            lua_Number result = lua_tonumber(L, -1) + secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumber(L, -1);

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) + secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    }
    lua_settop(L, 1);

    return 1;
}

static int lvec__add (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            lua_Number result = lua_tonumber(L, -1) + secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumber(L, -1);

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) + secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    }

    return 1;
}

static int lvec_sub (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;

    if (lua_isnumber(L, 2)) {
        secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, (lua_Integer)i);

            result = lua_tonumber(L, -1) - secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumber(L, -1);

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) - secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    }

    lua_settop(L, 1);
    return 1;
}

static int lvec__sub (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    if (lua_isnumber(L, 2)) {
        secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, (lua_Integer)i);

            result = lua_tonumber(L, -1) - secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumber(L, -1);

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) - secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    }

    return 1;
}

static int lvec_mul (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;
    int isnum;

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            lua_Number result = lua_tonumber(L, -1) * secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumberx(L, -1, &isnum);
            if (!isnum) secop = 1;

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) * secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    }

    lua_settop(L, 1);
    return 1;
}

static int lvec__mul (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;
    int isnum;

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            lua_Number result = lua_tonumber(L, -1) * secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumberx(L, -1, &isnum);
            if (!isnum) secop = 1;

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) * secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    }

    return 1;
}

static int lvec_div (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;
    int isnum;

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            result = lua_tonumber(L, -1) / secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumberx(L, -1, &isnum);
            if (!isnum) secop = 1;

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) / secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    }

    lua_settop(L,1);
    return 1;
}

static int lvec__div (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;
    int isnum;

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            result = lua_tonumber(L, -1) / secop;
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumberx(L, -1, &isnum);
            if (!isnum) secop = 1;

            lua_rawgeti(L, 1, i);
            result = lua_tonumber(L, -1) / secop;
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    }

    return 1;
}

static int lvec_unm (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);

    for (lua_Unsigned i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        lua_pushnumber(L, -lua_tonumber(L, -1));
        lua_rawseti(L, 1, i);
        lua_pop(L, 1);
    }

    return 1;
}

static int lvec__unm (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (lua_Unsigned i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        lua_pushnumber(L, -lua_tonumber(L, -1));
        lua_rawseti(L, -3, i);
        lua_pop(L, 1);
    }

    return 1;
}

static int lvec_pow (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            result = pow(lua_tonumber(L, -1), secop);
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumber(L, -1);

            lua_rawgeti(L, 1, i);
            result = pow(lua_tonumber(L, -1), secop);
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, 1, i);
        }
    }

    lua_settop(L, 1);
    return 1;
}

static int lvec__pow (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);
    lua_Number secop, result;

    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    if (lua_isnumber(L, 2)) {
        lua_Number secop = lua_tonumber(L, 2);
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);

            result = pow(lua_tonumber(L, -1), secop);
            lua_pop(L, 1);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);

            secop = lua_tonumber(L, -1);

            lua_rawgeti(L, 1, i);
            result = pow(lua_tonumber(L, -1), secop);
            lua_pop(L, 2);

            lua_pushnumber(L, result);
            lua_rawseti(L, -2, i);
        }
    }

    lua_settop(L, 3);
    return 1;
}

static int lvec_eq (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Unsigned n = lua_rawlen(L, 1);

    if (lua_isnumber(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 1, i);
            if (lua_compare(L, -1, -2, LUA_OPEQ) == 0) {
                lua_pushboolean(L, 0);
                return 1;
            }
            lua_pop(L, 1);
        }
    } else if (lua_istable(L, 2)) {
        for (lua_Unsigned i = 1; i <= n; i++) {
            lua_rawgeti(L, 2, i);
            lua_rawgeti(L, 1, i);
            if (lua_compare(L, -1, -2, LUA_OPEQ) == 0) {
                lua_pushboolean(L, 0);
                return 1;
            }
            lua_pop(L, 2);
        }
    }

    lua_pushboolean(L, 1);
    return 1;
}

static int lvec_lensqr (lua_State *L) {
    double result = 0;
    double tmp;
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer n = lua_rawlen(L, 1);

    for (lua_Integer i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        tmp = (double)lua_tonumber(L, -1);
        result += tmp*tmp;
        lua_pop(L, 1);
    }

    lua_pushnumber(L, result);

    return 1;
}

static int lvec_len (lua_State *L) {
    lvec_lensqr(L);
    double result = lua_tonumber(L, -1);
    lua_settop(L, 1);
    lua_pushnumber(L, sqrt(result));
    return 1;
}

static int lvec_dot (lua_State *L) {
    lua_Number out = 0;
    lua_Number secop;
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);

    lua_Unsigned n = lua_rawlen(L, 1);
    for (lua_Unsigned i = 1; i <= n; i++) {
        lua_rawgeti(L, 2, i);
        secop = lua_tonumber(L, -1);
        lua_rawgeti(L, 1, i);
        out += lua_tonumber(L, -1) * secop;
        lua_pop(L, 2);
    }

    lua_pushnumber(L, out);
    return 1;
}

static int lvec_sum (lua_State *L) {
    lua_Number out = 0;
    luaL_checktype(L, 1, LUA_TTABLE);

    lua_Unsigned n = lua_rawlen(L, 1);
    for (lua_Unsigned i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        out += lua_tonumber(L, -1);
        lua_pop(L, 1);
    }

    lua_pushnumber(L, out);
    return 1;
}

static int lvec_normalize (lua_State *L) {
    lvec_len(L);
    double len = lua_tonumber(L, -1);
    lvec_div(L);
    lua_pushnumber(L, len);
    return 2;
}

static int lvec__normalize (lua_State *L) {
    lvec_len(L);
    lvec__div(L);
    lua_pushvalue(L, -2);
    return 2;
}

static int lvec_lerp (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);
    lua_Number secop, subres;
    lua_Number _param = luaL_checknumber(L, 3);
    lua_Number param = ((_param >= 1) ? 1 : ((_param <= 0) ? 0 : _param));
    lua_Unsigned n = lua_rawlen(L, 2);

    lua_pop(L, 1);

    for (lua_Unsigned i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        secop = lua_tonumber(L, -1);
        lua_rawgeti(L, 2, i);

        subres = lua_tonumber(L, -1) - secop;
        lua_pop(L, 2);
        lua_pushnumber(L, secop + subres * param);
        lua_rawseti(L, 1, i);
    }

    lua_settop(L, 1);
    return 1;
}

static int lvec__lerp (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);
    lua_Number secop, subres;
    lua_Number _param = luaL_checknumber(L, 3);
    lua_Number param = ((_param >= 1) ? 1 : ((_param <= 0) ? 0 : _param));
    lua_Unsigned n = lua_rawlen(L, 2);

    lua_pop(L, 1);
    lua_createtable(L, (int)n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (lua_Unsigned i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        secop = lua_tonumber(L, -1);
        lua_rawgeti(L, 2, i);

        subres = lua_tonumber(L, -1) - secop;
        lua_pop(L, 2);
        lua_pushnumber(L, secop + subres * param);
        lua_rawseti(L, -2, i);
    }

    return 1;
}

static int lvec_copy (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer n = (lua_Integer)lua_rawlen(L, 1);
    lua_Integer _n = n;
    if (lua_isinteger(L, 2)) {
        _n = lua_tointeger(L, 2);
    }
    n = (n < _n) ? n : _n;

    lua_createtable(L, (int)_n, 0);
    luaL_getmetatable(L, "vec");
    lua_setmetatable(L, -2);

    for (lua_Integer i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        lua_rawseti(L, -2, i);
    }

    return 1;
}

static int lvec_tostring (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer n = (lua_Integer)lua_rawlen(L, 1);

    luaL_Buffer out;
    luaL_buffinit(L, &out);

    luaL_addchar(&out, '[');
    for (lua_Integer i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        luaL_addvalue(&out);
        if (i < n) {
            luaL_addchar(&out, ',');
            luaL_addchar(&out, ' ');
        }
    }
    luaL_addchar(&out, ']');
    luaL_pushresult(&out);

    return 1;
}

static unsigned char hexclamp(lua_Number num) {
    if (num > 255) return 255U;
    if (num < 0) return 0U;
    return (unsigned char)num;
}

static char* fmt = "%02X";
static int lvec_tohex (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer n = (lua_Integer)lua_rawlen(L, 1);

    unsigned char num;
    char numstr[3];
    luaL_Buffer out;
    luaL_buffinit(L, &out);

    luaL_addchar(&out, '#');
    for (lua_Integer i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        num = hexclamp(lua_tonumber(L, -1));
        sprintf(numstr, fmt, num);
        luaL_addstring(&out, numstr);
    }
    luaL_pushresult(&out);

    return 1;
}

static int lvec_serialize (lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    lua_Integer n = (lua_Integer)lua_rawlen(L, 1);

    luaL_Buffer out;
    luaL_buffinit(L, &out);

    luaL_addchar(&out, '{');
    for (lua_Integer i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i);
        luaL_addvalue(&out);
        luaL_addchar(&out, ',');
    }
    luaL_addchar(&out, '}');
    luaL_pushresult(&out);

    return 1;
}

static const struct luaL_Reg vec [] = {
    {"new", lvec_new},
    {"newzero", lvec_newzero},
    {"newsingle", lvec_newsingle},
    {"range", lvec_newrange},
    {"fromhex", lvec_fromhex},
    {"add", lvec_add}, {"__add", lvec__add},
    {"sub", lvec_sub}, {"__sub", lvec__sub},
    {"mul", lvec_mul}, {"__mul", lvec__mul},
    {"div", lvec_div}, {"__div", lvec__div},
    {"unm", lvec_unm}, {"__unm", lvec__unm},
    {"pow", lvec_pow}, {"__pow", lvec__pow},
    {"eq", lvec_eq},
    {"tostring", lvec_tostring}, {"__tostring", lvec_tostring},
    {"__serialize", lvec_serialize},
    {"tohex", lvec_tohex},
    {"lensqr", lvec_lensqr},
    {"len", lvec_len},
    {"lerp", lvec_lerp}, {"__lerp", lvec__lerp},
    {"dot", lvec_dot},
    {"sum", lvec_sum},
    {"normalize", lvec_normalize}, {"__normalize", lvec__normalize},
    {"copy", lvec_copy},
    {NULL, NULL} /* sentinel */
};

#if defined(_WIN32) || defined(_WIN64)
__declspec(dllexport)
#endif
int luaopen_vec(lua_State *L) {
    luaL_newmetatable(L, "vec");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_setfuncs(L, vec, 0);

    return 1;
}

// Для подключения в другом Си коде
int luasetglobal_vec (lua_State *L) {
    lua_settop(L, 0);
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_getfield(L, -1, "vec");
    if (lua_isnoneornil(L, -1)) {
        lua_pushcfunction(L, luaopen_vec);
        lua_setfield(L, -3, "vec");
    }
    lua_settop(L, 0);

    return 0;
}