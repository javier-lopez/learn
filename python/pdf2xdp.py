#!usr/bin/python
#filename:pdf2xdp.py
#me:Cryin'
#date:2011
#make a PDF file to xdp

import sys,optparse,os,base64
def main():
    usage = "usage: %prog [options] fromfile tofile"
    parser = optparse.OptionParser(usage)
    parser.add_option('-v', '--version', action='store_true', default=False, help='display proc version')
    (options, args) = parser.parse_args()

    if len(args) == 0:
        parser.print_help()
        print "  Tool to make a pdf file to xdp! pdf2xdp version v 0.0.1"
        print "  Source code by Cryin"
        print "  http://hi.baidu.com/justear"
        sys.exit(1)
    if len(args) != 2:
        parser.error("need to specify both a fromfile and tofile")

    fromfile, tofile = args
    file = open(fromfile,"rb")
    data=file.read()
    file.close()
    dedata=base64.encodestring(data)
    #print dedata
    xdpheader='''<?xml version="1.0"?><?xfa ?><xdp:xdp xmlns:xdp="http://ns.adobe.com/xdp/"><pdf xmlns="http://ns.adobe.com/xdp/pdf/"><document><chunk>'''
    #print xdpheader
    xdpfooter='</chunk></document></pdf></xdp:xdp>'
    #print xdpfooter
    file=open(tofile,"w")
    file.write(xdpheader)
    file.write(dedata)
    file.write(xdpfooter)
    file.close()

    print "Make the PDF file to xdp Done..."

if __name__ == '__main__':
    main()
