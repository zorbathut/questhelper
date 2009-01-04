
def command(name, deps, line):
  AlwaysBuild(Alias(name, deps, line))

command("build", ["01", "02"], None)

command("01", [], "./build_01_copy")
command("02", [], "./build_02_decompress")
