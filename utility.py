
import subprocess
import S3

def exe(line):
  return str(subprocess.Popen(line.split(" "), stdout=subprocess.PIPE).communicate()[0], "ascii")
