
import os

env = DefaultEnvironment()
for param in os.environ.keys():
	env['ENV'][param] = os.environ[param]

def command(name, deps, line):
  AlwaysBuild(Alias(name, deps, line))

lib = SharedLibrary(target = "compile_core", source = ["compile_core.cpp"], CPPPATH="/usr/include/lua5.1", LIBS=["luabind", "png"], CXXFLAGS="-g", LINKFLAGS="-g")
command("compile", lib, "luajit -O2 compile.lua master 20 localhostx5")
command("compile_local", lib, "luajit -O2 compile.lua")
