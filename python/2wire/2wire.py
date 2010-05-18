#!/usr/bin/env python
#Sencillo script para cambiar las ip's de los modem 2Wire
#Escrito por Ivan Juarez Nunez. www.redmater.com 2009

#If you find any trouble while setting up this script, check content.find().

import urllib
import getopt
import sys

def usage():
    print "Usage: 2wire [OPTION] [PASSWORD]\
           \n\n\t-h, --help:\tShow this message\
           \n\t-p, --password:\tUse this password\
           \n\t-s, --show:\tShow up the supported models"

def showModems():
    print "\n* 2Wire 1070 Home Portal\
           \n* 2Wire 1071HG Gateway\
           \n* 2Wire 2071 Gateway\
           \n* 2Wire 2701HG-T Gateway\
           \n* 2Wire 2700HG Gateway\n"

def resetModem(passwd):
    f = urllib.urlopen('http://home/xslt?PAGE=A02_POST&amp;THISPAGE=&amp;NEXTPAGE=J21_ISP_RESET&amp;CMSKICK=&amp;PAGE=J21_ISP_RESET'+passwd)
    content = f.read()
    if (content.find('Please enter the system password')!=-1):
        if not password:
            print "Error: Password already set up.\tUse -p option\n"
            usage()
        else:
            print "Error: Incorrect password.\t Try with another one\n"
            sys.exit()
    else:
        print "\nResetting router...[DONE]"

password = ""

try:
    opts,args = getopt.getopt(sys.argv[1:], "hsp:", ["help","show","password="])
except getopt.GetoptError, err:
    print str(err)
    usage()
    sys.exit()

for o, a in opts:
    if o in ("-h","--help"):
        usage()
        sys.exit()
    elif o in ("-s","--show"):
        showModems()
        sys.exit()
    elif o in ("-p","--password"):
        password = a
    else:
        assert False, "Invalid option"

if (password!=''): password = '&amp;PASSWORD='+password

resetModem(password)
