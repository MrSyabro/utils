#include <lua.h>
#include <lauxlib.h>

static int levent_new (lua_State *L) {
	const char is_named = !lua_isnoneornil(L, 2);
	const char with_mode = !lua_isnoneornil(L, 3);

	lua_createtable(L, 0, 0); //new eventmgr
	if (is_named) {
		lua_pushvalue(L, 2);
		lua_setfield(L, -2, "name");
	}

	lua_createtable(L, 0, 0);
	lua_getfield(L, 1, "metatables");
	if (with_mode) lua_pushvalue(L, 3);
	else lua_pushboolean(L, 0);
	lua_rawget(L, -2); //weak mode
	lua_setmetatable(L, -3);
	lua_pop(L, 1);
	lua_setfield(L, 2, "callback_fns");

	lua_pushvalue(L, 1);
	lua_setmetatable(L, -2);

	return 1;
}

static int sendcont (lua_State *L, int status, lua_KContext top) {
	int args = top - 1;

	if (status != LUA_OK) {
		const char* err_mess = lua_tostring(L, -1);
		lua_warning(L, err_mess, 0);
		lua_pop(L, 1);
	}
	while(lua_next(L, -2) != 0) {
		char add_args = 0;
		if(lua_compare(L, -1, top + 1, LUA_OPEQ)) { // функция
			lua_pop(L, 1);
			lua_pushvalue(L, -1);
		} else { // метод
			lua_pushvalue(L, -2);
			add_args = 1;
		}
		for (int i = 0; i < args; i++) lua_pushvalue(L, 2 + i); //копируем аргументы
		int status = lua_pcallk(L, args + add_args, 1, 0, top, sendcont);
		if (status != LUA_OK) {
			const char* err_mess = lua_tostring(L, -1);
			lua_warning(L, err_mess, 0);
			lua_pop(L, 1);
		} else if (lua_toboolean(L, -1)) {
			lua_pop(L, 1);

			lua_pushvalue(L, -1);
			lua_pushnil(L);

			lua_settable(L, top + 2); // [cb_fn] = nil
		} else lua_pop(L, 1);
	}

	return 0;
}

/*
	Перебирает все функции в таблице и вызывает их с переданными аргументами.
*/
static int levent_send (lua_State *L) {
	int top = lua_gettop(L);
	int args = top - 1;

	lua_getfield(L, 1, "filter");
	lua_pushvalue(L, 1);
	for (int i = 0; i < args; i++) lua_pushvalue(L, 2 + i); //копируем аргументы
	lua_call(L, top, 1);
	if (lua_toboolean(L, -1) == 0)  return 0;
	lua_pop(L, 1);

	// TODO: error fn
	lua_getfield(L, 1, "placeholder");
	lua_getfield(L, 1, "callback_fns");
	lua_pushnil(L);
	sendcont(L, LUA_OK, top);

	return 0;
}

/*
	Возвращает true, если событие включено, иначе false.
*/
static int levent_filter (lua_State *L) {
	lua_getfield(L, 1, "enabled");
	return 1;
}

static int levent_addcallback (lua_State *L) {
	const char is_func = lua_isnoneornil(L, 3);
	lua_getfield(L, 1, "callback_fns");
	lua_pushvalue(L, 2);
	if (is_func) lua_getfield(L, 1, "placeholder");
	else lua_pushvalue(L, 3);
	lua_rawset(L, -3);
	lua_settop(L, 2);

	return 1;
}

static int levent_rmcallback (lua_State *L) {
	lua_getfield(L, 1, "callback_fns");
	lua_pushvalue(L, 2);
	lua_pushnil(L);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}

static int levent__call (lua_State *L) {
	int top = lua_gettop(L);
	lua_getfield(L, 1, "send");
	lua_insert(L, 1);
	lua_call(L, top, 0);

	return 0;
}

static int levent__add (lua_State *L) {
	int top = lua_gettop(L);
	lua_getfield(L, 1, "addCallback");
	lua_insert(L, 1);
	lua_call(L, top, 0);

	return 0;
}

static int levent__sub (lua_State *L) {
	int top = lua_gettop(L);
	lua_getfield(L, 1, "rmCallback");
	lua_insert(L, 1);
	lua_call(L, top, 0);

	return 0;
}

static const struct luaL_Reg event [] = {
	{"new", levent_new},
	{"send", levent_send},
	{"filter", levent_filter},
	{"addCallback", levent_addcallback},
	{"rmCallback", levent_rmcallback},
	{"__call", levent__call},
	{"__add", levent__add},
	{"__sub", levent__sub},
	//{"__tostring", levent__tostring},
	{NULL, NULL} /* sentinel */
};

#if defined(_WIN32) || defined(_WIN64)
__declspec(dllexport)
#endif
int luaopen_eventmgr(lua_State *L) {
	luaL_newmetatable(L, "eventmgr");

	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");

	lua_createtable(L, 1, 0);
	lua_setfield(L, -2, "placeholder");

	lua_pushstring(L, "Default");
	lua_setfield(L, -2, "name");

	lua_pushboolean(L, 1);
	lua_setfield(L, -2, "enabled");

	lua_createtable(L, 0, 2); //weakmode metatables
	// {
	lua_pushboolean(L, 0); //[false]
	lua_createtable(L, 0, 1);
	lua_pushstring(L, "v");
	lua_setfield(L, -2, "__mode"); // = {__mode = "v"}
	lua_rawset(L, -3);
	lua_pushboolean(L, 0); //[true]
	lua_createtable(L, 0, 1);
	lua_pushstring(L, "vk");
	lua_setfield(L, -2, "__mode"); // = {__mode = "vk"}
	lua_rawset(L, -3);
	// }
	lua_setfield(L, -2, "metatables");

	luaL_setfuncs(L, event, 0);

	return 1;
}

// Для подключения в другом Си коде
int luasetglobal_event (lua_State *L) {
	lua_settop(L, 0);
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	lua_getfield(L, -1, "eventmgr");
	if (lua_isnoneornil(L, -1)) {
		lua_pushcfunction(L, luaopen_eventmgr);
		lua_setfield(L, -3, "eventmgr");
	}
	lua_settop(L, 0);

	return 0;
}
