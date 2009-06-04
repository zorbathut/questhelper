#!/usr/bin/python

#Note: We have a custom version of libgmail to fix a bug involving binary attachments (which obviously we have.)

import warnings
warnings.simplefilter("ignore",DeprecationWarning)

import libgmail
import md5
import sys
import passwords
import os
import commands
import re
import time

os.system("rm rawdata_*")

filehashdict = {}

ct = 0
tregex = re.compile("rawdata_([0-9a-f]{32,32})(.*)\.bz2")
outp = commands.getoutput("s3cmd ls s3://questhelper_data/rawdata_")
print "S3 listing snagged"
for line in outp.split('\n'):
  if line == "Bucket 's3://questhelper_data':":
    continue
  serch = tregex.search(line)
  if not serch:
    print line
  toki = serch.group(1)
  ext = serch.group(2)
  #print toki
  filehashdict[toki] = ext
print "Filenames isolated: %d" % len(filehashdict)

ga = libgmail.GmailAccount(passwords.gmail_username, passwords.gmail_password)
ga.login()

destination="./LocalInput/"
label=passwords.gmail_label

argument = "!label:" + label + " has:attachment"
argument = "has:attachment"
inbox=ga.getMessagesByQuery(argument)
i=0

print `len(inbox)`+" messages"
while len(inbox) > 0:
  try:
    for thread in inbox:
      for message in thread:
        mark = True
        if thread.getLabels().count(label) != 0:
          mark = False
          
        clear = True
        os.system("date")
        print "message "+`i`+" id: "+message.id
        #print thread.getLabels()
        #print thread.getLabels().count("downloaded")
        
        if True: # we used to make sure it had the right label, or more accurately, didn't
          #print 'hoohah'
          print '\t'+`len(message.attachments)`+" attachments"
          for a in message.attachments:
            a.filename = a.filename.encode('ascii', 'ignore').replace('*', '_')
            print '\t\t filename:', a.filename
            dig=md5.new()
            cont=a.content
            if cont <> None:
              dig.update(cont)
              pre=dig.hexdigest()
              #dex=filename.find(".")
              tup=a.filename.partition(".")
              name=pre+tup[1]+tup[2]
              f=open(destination+name,"w")
              f.write(cont)
              f.close()
              #message.addLabel("downloaded")
              
              print "\t\t saved"
              
              s3name = "rawdata_" + name + ".bz2"
              if not pre in filehashdict:
                # okay, that's cool. Now we S3 it.
                assert(os.system("bzip2 -k --best -c \"%s\" > \"%s\"" % (destination + name, s3name)) == 0)
                assert(os.system("s3cmd put \"%s\" s3://questhelper_data/" % (s3name)) == 0)
                assert(os.system("rm rawdata_*") == 0)
                print "\t\t S3 saved"
                filehashdict[pre] = name.partition(".")[1] + name.partition(".")[2]  # we only look at the first page of emails, over and over. this way, on the second pass through that page, we'll get and delete instead of just re-storing over and over.
                clear = False
              else:
                s3oldname = "rawdata_" + pre + filehashdict[pre] + ".bz2"
                if s3oldname != s3name:
                  print "\t\t WARNING: Name mismatch! %s vs %s" % (s3name, s3oldname)
                s3cg = "s3cmd --force get \"s3://questhelper_data/%s\" \"%s\"" % (s3oldname, s3oldname)
                while os.system(s3cg) != 0:
                  print "\t\t s3cmd failed, sleeping for 15 seconds . . ."
                  time.sleep(30)
                assert(os.system("cat \"%s\" | bunzip2 > rawdata_temptest" % (s3oldname)) == 0)
                assert(os.system("diff -q rawdata_temptest \"%s\"" % (destination + name)) == 0)
                assert(os.system("rm rawdata_temptest \"%s\"" % (s3oldname)) == 0)
              assert(os.system("rm \"%s\"" % (destination + name)) == 0)
            else:
              print "foobared attachment"
              mark = False
              clear = False
        if clear:
          print "\t Trashing"
          ga.trashMessage(message)
        i=i+1
      if mark:
        print "\t Marking"
        thread.addLabel(label)
  except Exception, e:
    raise
    #print "whoops"
  inbox=ga.getMessagesByQuery(argument)
  #print len(inbox)
    
print `i`+" messages examined and saved"

os.system("rm rawdata_*")
