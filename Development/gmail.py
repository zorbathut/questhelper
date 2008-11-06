#!/usr/bin/python

#Note: We have a custom version of libgmail to fix a bug involving binary attachments (which obviously we have.)

import libgmail
import md5
import sys
import passwords
import os
import commands
import re

os.system("rm rawdata_*")

filehashdict = {}

ct = 0
outp = commands.getoutput("s3cmd ls s3://questhelper_data/rawdata_")
print "S3 listing snagged"
for line in outp.split('\n'):
  if line == "Bucket 'questhelper_data':":
    continue
  #print line
  toki = re.search("rawdata_([0-9a-f]*)", line).group(1)
  #print toki
  filehashdict[toki] = True
print "Filenames isolated"

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
                clear = True
                print "message "+`i`+" id: "+message.id
                #print thread.getLabels()
                #print thread.getLabels().count("downloaded")
                if thread.getLabels().count(label) == 0 or True:
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
                              assert(os.system("s3cmd put \"%s\" s3://questhelper_data" % (s3name)) == 0)
                              assert(os.system("rm rawdata_*") == 0)
                              print "\t\t S3 saved"
                              clear = False
                            else:
                              assert(os.system("s3cmd get \"s3://questhelper_data/%s\" \"%s\"" % (s3name, s3name)) == 0)
                              assert(os.system("cat \"%s\" | bunzip2 > rawdata_temptest" % (s3name)) == 0)
                              assert(os.system("diff -q rawdata_temptest \"%s\"" % (destination + name)) == 0)
                              assert(os.system("rm rawdata_temptest \"%s\"" % (s3name)) == 0)
                        else:
                            print "foobared attachment"
                            mark = False
                            clear = False
            i=i+1
            if clear:
                print "Would have deleted message"
            elif mark:
                thread.addLabel(label)
    except Exception, e:
      raise
        #print "whoops"
    inbox=ga.getMessagesByQuery(argument)
    #print len(inbox)
        
print `i`+" messages examined and saved"

os.system("rm rawdata_*")
