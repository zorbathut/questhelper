
def command(name, deps, line):
  AlwaysBuild(Alias(name, deps, line))

prog = Program("compile.cpp", CPPFLAGS="-O2", LIBS="boost_filesystem")
command("run", prog, "./compile")
