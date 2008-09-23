#Note: We have a custom version of libgmail to fix a bug involving binary attachments (which obviously we have.)

import libgmail
import md5
import sys
import passwords

ga = libgmail.GmailAccount(passwords.gmail_username, passwords.gmail_password)
ga.login()

destination="./dbdump/"
label="zorba_downloaded"

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
                            print destination+name
                            f=open(destination+name,"w")
                            f.write(cont)
                            f.close()
                            #message.addLabel("downloaded")
                            print "saved"
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
            
            
    
