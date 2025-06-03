rockspec_format = "3.0"
package = "event"
version = "dev-1"
source = {
   url = "git+https://git@github.com/MrSyabro/utils.git",
   branch = "master",
}
description = {
   homepage = "https://github.com/MrSyabro/utils",
   license = "MIT/X11",
   maintainer = "MrSyabro",
}
dependencies = {
   "lua >= 5.2"
}
build = {
   type = "builtin",
   modules = {
      event = "src/event.c"
   },
}
test = {
   type = "command",
}