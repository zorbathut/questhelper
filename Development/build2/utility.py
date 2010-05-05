
import subprocess

def exe(line):
  return str(subprocess.Popen(line.split(" "), stdout=subprocess.PIPE).communicate()[0], "ascii")

def exe_bin(line):
  sp = subprocess.Popen(line.split(" "), stdout=subprocess.PIPE)
  dt = sp.communicate()[0]
  assert(sp.returncode == 0)
  return dt

def exe_rv(line):
  ldat = line.split(" ")
  if line.find("BASHHACK") != -1:
    ldat = ["bash", "-c", line.split(" ", 1)[1]]
  
  sp = subprocess.Popen(ldat, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  so, se = sp.communicate()
  so = str(so, "ascii")
  se = str(se, "ascii")
  rv = sp.returncode
  assert(rv != None)
  return so, se, rv
