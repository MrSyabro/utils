package = "syabro_utils"
version = "dev-1"
source = {
   url = "git+https://github.com/MrSyabro/utils.git"
}
description = {
   homepage = "https://github.com/MrSyabro/utils",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.2",
}
build = {
   type = "builtin",
   modules = {
   	serialize = "src/serialize.lua",
   	deserialize = "src/deserialize.lua",
   	vec = "src/vec.lua",
   	transform = "src/transform.lua",
   	obj = "src/obj.lua",
   	eventmgr = "src/eventmgr.lua",
   }
}
