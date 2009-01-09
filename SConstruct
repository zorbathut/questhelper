
def command(name, deps, line):
  AlwaysBuild(Alias(name, deps, line))

lib = SharedLibrary(target = "compile_core", source = ["compile_core.cpp"], CPPPATH="/usr/include/lua5.1", LIBS="luabind")
command("run", lib, "lua compile.lua")

