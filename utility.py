
import subprocess
import S3

def exe(line):
  return str(subprocess.Popen(line.split(" "), stdout=subprocess.PIPE).communicate()[0], "ascii")

def getAll(conn, bucket, prefix):
  reply = conn.list_bucket(bucket, options={"prefix":prefix})
  rv = reply.entries
  while reply.is_truncated:
    marker = rv[-1].key
    print("Retrieving filelist, %d files . . ." % len(rv))
    assert(len(marker))
    assert(len(reply.entries))
    reply = conn.list_bucket(bucket, options={"prefix":prefix, "marker":marker})
    assert(len(reply.entries))
    rv = rv + reply.entries
  print("Filelist retrieved, %d files" % len(rv))
  return rv
