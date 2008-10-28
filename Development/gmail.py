#!/usr/bin/python

#Note: We have a custom version of libgmail to fix a bug involving binary attachments (which obviously we have.)

import libgmail
import md5
import sys
import passwords
import os

ga = libgmail.GmailAccount(passwords.gmail_username, passwords.gmail_password)
ga.login()

destination="./LocalInput/"
label=passwords.gmail_label

inbox=ga.getMessagesByQuery("!label:"+label+" has:attachment")
i=0
#print 'hoohah'
print `len(inbox)`+" messages"
while len(inbox) > 0:
    try:
        for thread in inbox:
            for message in thread:
                mark = True
                print "message "+`i`+" id: "+message.id
                #print thread.getLabels()
                #print thread.getLabels().count("downloaded")
                if thread.getLabels().count(label) == 0:
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
                            
                            # okay, that's cool. Now we S3 it.
                            s3name = "rawdata_" + name + ".bz2"
                            assert(os.system("bzip2 -k --best -c \"%s\" > \"%s\"" % (destination + name, s3name)) == 0)
                            assert(os.system("s3cmd put \"%s\" s3://questhelper_data" % (s3name)) == 0)
                            assert(os.system("rm rawdata_*") == 0)
                            print "\t\t S3 saved"
                        else:
                            print "foobared attachment"
                            mark = False
            i=i+1
            if mark:
                thread.addLabel(label)
    except Exception, e:
      raise
        #print "whoops"
    inbox=ga.getMessagesByQuery("!label:"+label+" has:attachment")
    #print len(inbox)
        
print `i`+" messages examined and saved"
            
            
    
