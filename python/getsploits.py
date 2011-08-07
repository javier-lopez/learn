#!/usr/bin/env python

#Name: getsploits.py
#Version: 0.9.1
#Author: s3my0n

#########################################################################
# getsploits searches for specific exploits/shellcode/papers from       #
# exploit-db.com .                                                      #
#                                                                       #
# Copyright (C) 2011 s3my0n                                             #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# any later version.                                                    #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

import sys
import urllib2
import re
import threading
from optparse import OptionParser

class ExploitSearcher(threading.Thread):
    def __init__(self, search_url):
        threading.Thread.__init__(self)
        self.search_url = search_url
        self.results = {}
        self.error = False
        
        exp = ('<a  href="http://www.exploit-db\.com/exploits/\d+">\s*.+\s*</a>',
               'http://www.exploit-db.com/exploits/\d+')
        pap = ('<a  href="http://www.exploit-db\.com/papers/\d+">\s*.+\s*</a>',
               'http://www.exploit-db.com/papers/\d+')
        pdf = ('<a  href="http://www.exploit-db\.com/download_pdf/\d+">.+\s*</a>',
               'http://www.exploit-db.com/download_pdf/\d+')
        
        self.match_string = '%s|%s|%s' % (exp[0], pap[0], pdf[0])
        self.match_links = '%s|%s|%s' % (exp[1], pap[1], pdf[1])
        
    def getPage(self):
        try:
            self.current_page = urllib2.urlopen(self.search_url, '80').read()
        except BaseException:
            self.error = '\n[-] Error: could not connect to exploit-db.com'
    def getResultsFromPage(self, papers=False):
        
        try:
            found_results = re.findall(self.match_string, self.current_page)
        except AttributeError:
            exit(1)
            
        for i in found_results:

            name = ''.join(re.findall('>\s*.+\s*<', i))\
		    .strip('></a\n\r').replace('&lt;', '<')\
		    .replace('&gt;', '>').replace('&amp;', '&')\
		    .replace('&quot;', '"')

            link = ''.join(re.findall(self.match_links, i))
            self.results[name] = link
    
    def run(self):
        self.getPage()
        self.getResultsFromPage()
        
class SearcherController(object):
    def __init__(self, searchopts, genopts):
        def setfromdic(opt, dic):
            # Return number of a platform/type
            if (opt in dic.values()) or (opt == ''):
                return opt
            elif dic.has_key(opt):
                return dic[opt]
            else:
                return None
                
        allplatforms = {'sco':            '34', 'bsdi/x86':      '6',
                        'openbsd':        '27', 'lin/amd64':     '17',
                        'plan9':          '32', 'bsd/x86':       '5',
                        'openbsd/x86':    '28', 'hardware':      '12',
                        'bsd':            '3',  'unix':          '41',
                        'lin/x86-64':     '22', 'netbsd/x86':    '25',
                        'linux':          '16', 'solaris':       '36',
                        'ultrix':         '40', 'arm':           '46',
                        'php':            '31', 'solaris/sparc': '37',
                        'osX':            '30', 'os-x/ppc':      '29',
                        'cfm':            '47', 'generator':     '11',
                        'freebsd/x86':    '9',  'bsd/ppc':       '4',
                        'minix':          '23', 'unixware':      '42',
                        'freebsd/x86-64': '10', 'cgi':           '7',
                        'hp-ux':          '13', 'multiple':      '24',
                        'win64':          '44', 'tru64':         '39',
                        'jsp':            '15', 'novell':        '26',
                        'linux/mips':     '18', 'solaris/x86':   '38',
                        'aix':            '1',  'windows':       '45',
                        'linux/ppc':      '19', 'irix':          '14',
                        'QNX':            '33', 'lin/x86':       '21',
                        'win32':          '43', 'linux/sparc':   '20',
                        'freebsd':        '8',  'asp':           '2',
                        'any':            '0',  'sco/x86':       '35'}

        alltypes = {'any':       '0',
                    'local':     '2',
                    'papers':    '5',
                    'remote':    '3',
                    'shellcode': '4',
                    'webapps':   '6'}

        # Search options
        self.description = searchopts['DESC'].replace(' ', '+')
        self.author = searchopts['AUTH']
        self.port = searchopts['PORT']
        self.osvdb = searchopts['OSVDB']
        self.cve = searchopts['CVE']

        # Setting up platform
        self.platform = setfromdic(searchopts['PLAT'], allplatforms)
        if self.platform == None:
            print '\n[-] Error: invalid platform [%s]' % (searchopts['PLAT'])
            exit(1)

        # Setting up type
        self.type = setfromdic(searchopts['TYPE'], alltypes)
        if self.type == None:
            print '\n[-] Error: invalid type [%s]' % (searchopts['TYPE'])
            exit(1)

        # General options
        self.quiet = genopts['QUIET']
        self.output = genopts['OUTPUT']
        
        self.page = 1 # First page
        self.pages = 1 # How many pages
        self.results = {}

        self.createURL()

    def createURL(self):
        self.search_url = 'http://exploit-db.com/search/?action=search'
        self.search_url += '&filter_page=%d' % (self.page)
        self.search_url += '&filter_description=%s' % (self.description)
        self.search_url += '&filter_author=%s' % (self.author)
        self.search_url += '&filter_platform=%s' % (self.platform)
        self.search_url += '&filter_type=%s' % (self.type)
        self.search_url += '&filter_port=%s' % (self.port)
        self.search_url += '&filter_osvdb=%s' % (self.osvdb)
        self.search_url += '&filter_cve=%s' % (self.cve)

    def userOutput(self, what):
        outputs = {'How_many_pages':'\n[*] Found %d pages of results.' % (self.pages),
                   'No_results':'\n[*] "%s" was not found in the database.' % (self.description),
                   'First_connection':'\n[*] Connecting ...',
                   'Find_results':'\n[*] Searching found pages ...',
                   'Saving_links':'\n[*] Saving found results to %s'%(self.output)}
        return outputs[what]
    
    def findPageNumbers(self):
        if self.quiet != True:
            print self.userOutput('First_connection')

        exploits = '<a\s+href="http://www.exploit-db\.com/exploits/\d+">\s*.+\s*</a>'
        papers = '<a\s+href="http://www.exploit-db\.com/papers/\d+">\s*.+\s*</a>'
        pdf = '<a\s+href="http://www.exploit-db\.com/download_pdf/\d+">\s*.+\s*</a>'
        
        match_highest = '<a href="http://www.exploit-db\.com/search/\?action=search&filter_page=\d+'
        
        try:
            openpage = urllib2.urlopen(self.search_url, '80').read()
        except KeyboardInterrupt:
            print '\n[*] Aborted: exiting'
            exit(1)
        except BaseException:
            print '\n[-] Error: could not connect to exploit-db.com'
            exit(1)
        else:
            find_link = ''.join(re.findall(match_highest, openpage))
            highest = ''.join(re.findall('\d+', find_link))
            if highest == '':
                one_page_test = re.findall('%s|%s|%s'%(exploits, papers, pdf), openpage)
                if one_page_test == []:
                    print self.userOutput('No_results')
                    exit(0)
            else:
                self.pages = int(highest[0]) # Number of pages
                    
        if self.quiet != True:
            print self.userOutput('How_many_pages')

    def printResults(self, results):
        for i in results:
            print '\n[+] %s' % (i)
            print '    %s' % (results[i])

    def saveLinks(self):
        if self.quiet != True:
            print self.userOutput('Saving_links')
        try:
            fopen = open(self.output, 'a')
            for i in self.results:
                fopen.write('\n%s\n%s\n'%(i, self.results[i]))
        except KeyboardInterrupt:
            print '\n[*] Aborted: exiting'
            exit(1)
        except IOError:
            print '\n[-] Error: cannot write to %s' % (self.output)
            exit(1)
        else:
            fopen.close()
            
class ArgCreator(object):
    def __init__(self):
        parser = OptionParser(add_help_option=False)
        parser.add_option('--author', dest='author', default='')
        parser.add_option('--platform', dest='platform', default='0')
        parser.add_option('--type', dest='type', default='0')
        parser.add_option('--port', dest='port', default='')
        parser.add_option('--osvdb', dest='osvdb', default='')
        parser.add_option('--cve', dest='cve', default='')
        parser.add_option('-o', dest='output', default='')
        parser.add_option('-q', action='store_true', dest='quiet', default=False)
        parser.add_option('-h', '--help', action='store_true', dest='help', default=False)
        (self.options, args) = parser.parse_args()

        self.checkArgs() # Parsing arguments

    def helpscreen(self):
        return '''
  getsploits v0.9
  s3my0n RuSH4ck3R[at]gmail[dot]com
  InterN0T.net

  Usage: getsploits.py [OPTIONS] [SEARCH_OPTIONS] description
  
  Example: getsploits.py -o linux_shellcode.txt --type shellcode --platform linux ""
           getsploits.py -o freebsd_x86-64_local.txt --platform 10 --type 2 ""
           getsploits.py --author maxe vbulletin

  [Options]:
  -o: Write results to a file
  -q: Quiet mode
  -h: Show this help screen

  [Search Options]:
  --author:
  --platform
  --type
  --port
  --osvdb
  --cve

  [Platforms]:
    0: any (default)    12: hardware       24: multiple      36: solaris
    1: aix              13: hp-ux          25: netbsd/x86    37: solaris/sparc
    2: asp              14: irix           26: novell        38: solaris/x86
    3: bsd              15: jsp            27: openbsd       39: tru64
    4: bsd/ppc          16: linux          28: openbsd/x86   40: ultrix
    5: bsd/x86          17: linux/amd64	   29: os-x/ppc      41: unix
    6: bsdi/x86         18: linux/mips     30: osx           42: unixware
    7: cgi              19: linux/ppc	   31: php           43: win32
    8: freebsd          20: linux/sparc    32: plan9         44: win64
    9: freebsd/x86      21: linux/x86      33: qnx           45: windows
   10: freebsd/x86-64   22: linux/x86-64   34: sco           46: arm
   11: generator        23: minix          35: sco/x86       47: cfm
    			    
  [Types]:
    0: any (default)
    2: local
    5: papers
    3: remote
    4: shellcode
    6: webapps'''

    def checkArgs(self):
        def finddesc():
            args = sys.argv[:]
            search_options = ('--author', '--platform', '--type', '--port', '--osvdb', '--cve')
            lone_options = ('-h', '-q')
            arg_options = ('-o',)
            for i in args:
                if args.index(i) == 0:
                    continue
                previous_i = args[args.index(i)-1]
                if (i in search_options) or (i in lone_options) or (i in arg_options):
                    continue
                else:
                    if previous_i in search_options:
                        continue
                    if previous_i in arg_options:
                        continue
                    elif previous_i in lone_options:
                        return i
                    else:
                        return i
            else:
                return None
                
        if (self.options.help == True) or (len(sys.argv) < 2):
            print self.helpscreen()
            exit(0)
        self.description = finddesc() # Description string
        if self.description == None:
            print '[-] Error: please enter exploit description or enter "" instead of description.'
            exit(1)
            
    def search_options(self):
        return {'DESC':self.description,
                'AUTH':self.options.author,
                'PLAT':self.options.platform,
                'TYPE':self.options.type,
                'PORT':self.options.port,
                'OSVDB':self.options.osvdb,
                'CVE':self.options.cve}
    def general_options(self):
        return {'OUTPUT':self.options.output,
                'QUIET':self.options.quiet}

def main():
    ac = ArgCreator()
    search_options = ac.search_options()
    general_options = ac.general_options()

    sc = SearcherController(search_options, general_options)
    sc.findPageNumbers() # Find out how many pages there are

    # Searching
    threads = []
    for i in xrange(1, sc.pages+1):
        sc.page = i # Changing page number
        sc.createURL() # Update search url with current page number
        t = ExploitSearcher(sc.search_url)
        threads.append(t)
    nthreads = len(threads)
    if sc.quiet != True:
        print sc.userOutput('Find_results')
    
    # Running threads
    try:
        for i in xrange(nthreads):
            threads[i].start()
        for i in xrange(nthreads):
            threads[i].join()
            # Getting thread's results
            error = threads[i].error
            if error:
                print error
                exit(1)
            else:
                new_results = threads[i].results
                sc.results.update(new_results)
                if sc.quiet != True:
                    sc.printResults(new_results)
    except KeyboardInterrupt:
        print '[*] Aborted: exiting'
        exit(1)
    else:
        # Saving links
        if sc.output != '':
            sc.saveLinks()
    
if __name__=='__main__':
    main()
