package = "vec"
version = "dev-1"
source = {
   url = "git+https://git@github.com/MrSyabro/cutils.git",
   branch = "master",
}
description = {
   homepage = "https://github.com/MrSyabro/cutils",
   license = "MIT/X11",
   maintainer = "MrSyabro",
}
dependencies = {
   "lua >= 5.2"
}
build = {
   type = "builtin",
   modules = {
      vec = "src/vec.c"
   },
}