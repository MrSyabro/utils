#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>

static int levent_new(lua_State *L)
{
        const char is_named = !lua_isnoneornil(L, 2);
        const char with_mode = !lua_isnoneornil(L, 3);

        lua_createtable(L, 0, 0); // new eventmgr
        if (is_named)
        {
                lua_pushvalue(L, 2);
                lua_setfield(L, -2, "name");
        }

        lua_createtable(L, 0, 0);
        lua_getfield(L, 1, "metatables");
        if (with_mode)
                lua_pushvalue(L, 3);
        else
                lua_pushboolean(L, 0);
        lua_rawget(L, -2); // weak mode
        lua_setmetatable(L, -3);
        lua_pop(L, 1);
        lua_setfield(L, -2, "callback_fns");

        lua_pushvalue(L, 1);
        lua_setmetatable(L, -2);

        return 1;
}

static int sendcont(lua_State *L, int status, lua_KContext top)
{
        int args = top - 1;
        int tb_index = top + 1;
        int ph_index = top + 2;
        int cbs_list = top + 3;

        if (status != LUA_OK && status != LUA_YIELD)
        {
                lua_getglobal(L, "warn");
                lua_insert(L, lua_gettop(L) - 1);
                lua_call(L, 1, 0);
        }
        else if (lua_isboolean(L, -1) && lua_toboolean(L, -1))
        {
                lua_pop(L, 1);

                lua_pushvalue(L, -1);
                lua_pushnil(L);

                lua_rawset(L, cbs_list); // [cb_fn] = nil
        }
        else lua_pop(L, 1);
        while (lua_next(L, cbs_list) != 0)
        {
                char add_args = 0;
                if (lua_compare(L, -1, ph_index, LUA_OPEQ))
                { // функция
                        lua_pop(L, 1);
                        lua_pushvalue(L, -1);
                }
                else
                { // метод
                        lua_pushvalue(L, -2);
                        add_args = 1;
                }
                for (int i = 0; i < args; i++)
                        lua_pushvalue(L, 2 + i); // копируем аргументы
                int status = lua_pcallk(L, args + add_args, 1, tb_index, top, sendcont);
                if (status != LUA_OK && status != LUA_YIELD)
                {
                        lua_getglobal(L, "warn");
                        lua_insert(L, lua_gettop(L) - 1);
                        lua_call(L, 1, 0);
                }
                else if (lua_isboolean(L, -1) && lua_toboolean(L, -1))
                {
                        lua_pop(L, 1);

                        lua_pushvalue(L, -1);
                        lua_pushnil(L);

                        lua_rawset(L, cbs_list); // [cb_fn] = nil
                }
                else
                        lua_pop(L, 1);
        }

        return 0;
}

static int filtercont(lua_State *L, int state, lua_KContext top)
{
        if (lua_toboolean(L, -1) == 0)
                return 0;
        lua_pop(L, 1);

        lua_getfield(L, 1, "traceback");
        lua_getfield(L, 1, "placeholder");
        lua_getfield(L, 1, "callback_fns");
        lua_pushnil(L);
        lua_pushnil(L);
        sendcont(L, LUA_OK, top);
}

/*
        Перебирает все функции в таблице и вызывает их с переданными аргументами.
*/
static int levent_send(lua_State *L)
{
        int top = lua_gettop(L);
        int args = top - 1;

        lua_getfield(L, 1, "filter");
        lua_pushvalue(L, 1);
        for (int i = 0; i < args; i++)
                lua_pushvalue(L, 2 + i); // копируем аргументы
        lua_callk(L, top, 1, top, filtercont);
        filtercont(L, 0, top);

        return 0;
}

/*
        Возвращает true, если событие включено, иначе false.
*/
static int levent_filter(lua_State *L)
{
        lua_getfield(L, 1, "enabled");
        return 1;
}

static int levent_addcallback(lua_State *L)
{
        const char is_func = lua_isnoneornil(L, 3);
        lua_getfield(L, 1, "callback_fns");
        lua_pushvalue(L, 2);
        if (is_func)
                lua_getfield(L, 1, "placeholder");
        else
                lua_pushvalue(L, 3);
        lua_rawset(L, -3);
        lua_settop(L, 2);

        return 1;
}

static int levent_rmcallback(lua_State *L)
{
        lua_getfield(L, 1, "callback_fns");
        lua_pushvalue(L, 2);
        lua_pushnil(L);
        lua_rawset(L, -3);
        lua_pop(L, 1);

        return 1;
}

static int __callcont(lua_State *L, int status, lua_KContext top)
{
        return 0;
}

static int levent__call(lua_State *L)
{
        int top = lua_gettop(L);
        lua_getfield(L, 1, "send");
        lua_insert(L, 1);
        lua_callk(L, top, 0, 0, __callcont);

        return 0;
}

static int levent__add(lua_State *L)
{
        int top = lua_gettop(L);
        lua_getfield(L, 1, "add_callback");
        lua_insert(L, 1);
        lua_call(L, top, 0);

        return 0;
}

static int levent__sub(lua_State *L)
{
        int top = lua_gettop(L);
        lua_getfield(L, 1, "rm_callback");
        lua_insert(L, 1);
        lua_call(L, top, 0);

        return 0;
}

static int levent__tostring(lua_State *L)
{
        lua_getfield(L, 1, "__name");
        lua_pushstring(L, " `");
        lua_getfield(L, 1, "name");
        lua_pushstring(L, "`");
        lua_concat(L, 4);
        return 1;
}

static const struct luaL_Reg event[] = {
    {"new", levent_new},
    {"send", levent_send},
    {"filter", levent_filter},
    {"add_callback", levent_addcallback},
    {"rm_callback", levent_rmcallback},
    {"__call", levent__call},
    {"__add", levent__add},
    {"__sub", levent__sub},
    {"__tostring", levent__tostring},
    {NULL, NULL} /* sentinel */
};

#if defined(_WIN32) || defined(_WIN64)
__declspec(dllexport)
#endif
int luaopen_event(lua_State *L)
{
        luaL_newmetatable(L, "Event");

        lua_pushvalue(L, -1);
        lua_setfield(L, -2, "__index");

        lua_createtable(L, 1, 0);
        lua_setfield(L, -2, "placeholder");

        lua_pushstring(L, "Default");
        lua_setfield(L, -2, "name");

        lua_pushboolean(L, 1);
        lua_setfield(L, -2, "enabled");

        lua_getglobal(L, "debug");
        lua_getfield(L, -1, "traceback");
        lua_setfield(L, -3, "traceback");
        lua_pop(L, 1);

        lua_createtable(L, 0, 2); // weakmode metatables
        // {
        lua_pushboolean(L, 0); //[false]
        lua_createtable(L, 0, 1);
        lua_pushstring(L, "v");
        lua_setfield(L, -2, "__mode"); // = {__mode = "v"}
        lua_rawset(L, -3);

        lua_pushboolean(L, 1); //[true]
        lua_createtable(L, 0, 1);
        lua_pushstring(L, "kv");
        lua_setfield(L, -2, "__mode"); // = {__mode = "vk"}
        lua_rawset(L, -3);
        // }
        lua_setfield(L, -2, "metatables");

        luaL_setfuncs(L, event, 0);

        return 1;
}

// Для подключения в другом Си коде
int luasetglobal_event(lua_State *L)
{
        lua_settop(L, 0);
        lua_getglobal(L, "package");
        lua_getfield(L, -1, "preload");
        lua_getfield(L, -1, "event");
        if (lua_isnoneornil(L, -1))
        {
                lua_pushcfunction(L, luaopen_event);
                lua_setfield(L, -3, "event");
        }
        lua_settop(L, 0);

        return 0;
}
