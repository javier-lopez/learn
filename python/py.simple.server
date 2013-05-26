#!/usr/bin/env python2

# Copyright (C) 2009,2010,2011,2012  Xyne
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# (version 2) as published by the Free Software Foundation.
#
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

import BaseHTTPServer
import cgi, os.path, re, sys, errno, socket, ssl

from SocketServer import ThreadingMixIn
from hashlib import md5
from mimetypes import guess_type
from optparse import OptionParser, OptionGroup
from random import randint
from time import time, strftime
from optparse import OptionParser, OptionGroup
from urllib import quote, unquote
from time import gmtime, strftime

NAME = 'Custom'
VERSION = '1.0'

################################################################################
# ThreadedHTTPServer
################################################################################

class ThreadedHTTPServer(ThreadingMixIn, BaseHTTPServer.HTTPServer):

  ##### Logging #####
  def log_date_time_string(self):
    return strftime('%Y-%m-%d %H:%M:%S')

  def log_message(self, fmtstr, *args):
#     host, port = self.client_address
    timestamp = self.log_date_time_string()
    sys.stderr.write("[%s] " % (timestamp, ) + fmtstr % args + "\n")

  # Convenience method for running the server.
  def run_server(self):
    try:
      while self.keep_serving:
        self.handle_request()

      self.shutdown()
      message = "exiting... "

    except KeyboardInterrupt:
      self.socket.close()
      message = '<Ctrl-C> pressed, exiting...'

    except socket.error as e:
      message = "error: " + str(e.strerror)

    return message

  # Override to enable SSL
  def get_request(self):
    conn, addr = self.socket.accept()

    if self.use_ssl:
      conn = ssl.wrap_socket(conn, **self.ssl_parameters)

    return conn, addr

  # Override to suppress "Broken pipe" errors
  def process_request_thread(self, request, client_address):
    try:
      self.finish_request(request, client_address)
      self.shutdown_request(request)
    except socket.error as e:
      if e.errno in (errno.EPIPE, errno.ECONNRESET):
        pass
      else:
        self.handle_error(request, client_address)
      self.shutdown_request(request)
    except:
      self.handle_error(request, client_address)
      self.shutdown_request(request)

  def __init__(self, server_address, HandlerClass, username=None, password=None, authfile=None, use_ssl=False, ssl_parameters = {}, cert_required=False):
      BaseHTTPServer.HTTPServer.__init__(self, server_address, HandlerClass)

      self.daemon_threads = True
      self.keep_serving = True

      if authfile:
        f = open(authfile, 'r')
        self.username = f.readline().rstrip('\r\n\0')
        self.password = f.readline().rstrip('\r\n\0')
        f.close()
      else:
        self.username = username
        self.password = password

      self.use_ssl = use_ssl


      self.ssl_parameters = ssl_parameters
      self.ssl_parameters['server_side'] = True
      if cert_required:
        self.ssl_parameters['cert_reqs'] = ssl.CERT_REQUIRED
        if not self.ssl_parameters['ca_certs']:
          self.ssl_parameters['ca_certs'] = self.ssl_parameters['certfile']

  # Convenience method for display some useful data at startup.
  def display_status(self):
    address, port = self.server_address

    if not address or address == '0.0.0.0':
      print "  address: all interfaces"
    else:
      print "  address: " + address
    print "  port: " + str(port)
    print "  pid: " + str(os.getpid())

    if self.username and self.password:
      print "  authentication"
      print "    username: " + self.username
      print "    password: " + self.password

    if self.use_ssl:
      print "  SSL enabled"
      if self.ssl_parameters['certfile']:
        print "    certificate: " + self.ssl_parameters['certfile']
      if self.ssl_parameters['keyfile']:
        print "    key: " + self.ssl_parameters['keyfile']


################################################################################
# BaseHTTPRequestHandler
################################################################################

class BaseHTTPRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):

  ##### Logging #####
  def log_date_time_string(self):
    return strftime('%Y-%m-%d %H:%M:%S')

  def log_message(self, fmtstr, *args):
    host, port = self.client_address
    timestamp = self.log_date_time_string()
    sys.stderr.write("[%s] %s:%s " % (timestamp, host, port) + fmtstr % args + "\n")

  ##### HTTP Authentication #####

  # nc limit: maximum value is 0xffffffff
  # The client must re-auth after this number of requests.
  NC_LIMIT = 0xffffffff

  # Client must re-auth if no requests were made in the last x seconds
  OPAQUE_TIMEOUT = 3600

  # nonce and opaque lengths
  NONCE_LENGTH = 32

  # Opaque values
  opaques = {}

  # Create a nonce value
  def create_nonce(self):
    NONCE_MAX = 2 ** (self.NONCE_LENGTH * 4) - 1
    NONCE_FORMAT = '%0' + str(self.NONCE_LENGTH) + 'x'
    return NONCE_FORMAT % randint(0, NONCE_MAX)

  # Get the nonce value
  def get_nonce(self,opaque,nc):
    # Purge values that have timed out or exceeded the limit
    t = time()
    for k in self.opaques.keys():
     if t - self.opaques[k]['time'] > self.OPAQUE_TIMEOUT or int(self.opaques[k]['nc'],16) > self.NC_LIMIT:
       del self.opaques[k]

    try:
      if self.opaques[opaque]['nc'] != nc:
        del self.opaques[opaque]
        return ''

      self.opaques[opaque]['nc'] = "%08x" % (int(nc,16) + 1)
      self.opaques[opaque]['time'] = t
      return self.opaques[opaque]['nonce']
    except KeyError:
      return None

  # Reject an unauthenticated request.
  def reject_unauthenticated_request(self):
    nonce =  self.create_nonce()
    opaque = self.create_nonce()
    self.opaques[opaque] = {'time': time(), 'nc': '00000001', 'nonce': nonce}
    self.send_response(401)
    self.send_header('Content-Length', 0)
    self.send_header('WWW-Authenticate', 'Digest realm="' + self.address_string() + '",qop="auth",nonce="' + nonce +'",opaque="' + opaque +'"')
    self.send_header('Connection', 'close')
    self.end_headers()

  # Attempt to authenticate requests and reject those which fail.
  # Accepts the method (e.g. "GET", "POST") and returns True if the request
  # could be authenticated, otherwise False
  def authenticate(self, method='GET'):
    username = self.server.username
    password = self.server.password
    if username and password:
      if 'Authorization' in self.headers and self.headers['Authorization'][:7] == 'Digest ':
        nc = None
        cnonce = None
        opaque = None
        client_response = None

        for field in self.headers['Authorization'][7:].split(','):
          field = field.strip()
          if field[:10] == 'response="':
            client_response = field[10:-1]
          elif field[:8] == 'cnonce="':
            cnonce = field[8:-1]
          elif field[:3] == 'nc=':
            nc = field[3:]
          elif field[:8] == 'opaque="':
            opaque = field[8:-1]

        if client_response != None and cnonce != None and opaque != None and nc != None:
          nonce = self.get_nonce(opaque,nc)
          if not nonce:
            self.reject_unauthenticated_request()
            return False

          m = md5()
          m.update(username + ':' + self.address_string() + ':' + password)
          ha1 = m.hexdigest()

          m = md5()
          m.update(method + ':' + self.path)
          ha2 = m.hexdigest()

          m = md5()
          m.update(ha1 + ':' + nonce + ':' + nc + ':' + cnonce + ':auth:' + ha2)
          response = m.hexdigest()

          if response == client_response:
            return True

      self.reject_unauthenticated_request()
      return False

    elif not username and not password:
      return True

    else:
      self.reject_unauthenticated_request()
      return False

  ##### Meta #####

  # HTTP protocol version
  protocol_version = 'HTTP/1.1'

  # Server version.
  def version_string(self):
    return '%s/%s' % (NAME, VERSION)

  ##### Convencience Methods #####

  # Convenience method for transfering content.
  def transfer_utf8_content(self, body, content_type, include_body=True, response_code=200):
    try:
      body = body.encode('utf-8')
    except UnicodeDecodeError:
      pass

    content_type += '; charset=UTF-8'

    try:
      self.send_response(response_code)
      self.send_header('Content-Type', content_type)
      self.send_header('Content-Length', len(body))
      self.end_headers()
      if include_body:
        self.wfile.write(body)
    except:
      pass

  # Convencience method for serving UTF-8 encoded HTML pages.
  def transfer_html(self, html, include_body=True, response_code=200):
    self.transfer_utf8_content(html, 'text/html', include_body, response_code=response_code)

  # Convencience method for serving UTF-8 encoded plaintext pages.
  def transfer_plaintext(self, text, include_body=True, response_code=200):
    self.transfer_utf8_content(text, 'text/plain', include_body, response_code=response_code)

  # Convenience method for transfering files and file headers.
  def transfer_file(self, fpath, include_body=True):
    self.send_response(200)
    size = os.path.getsize(fpath)
    range_start = 0
    range_end = size
    mimetype, encoding = guess_type(fpath)
    if not mimetype:
      mimetype = 'application/octet-stream'
    self.send_header('Content-Type', mimetype)

    if encoding:
      self.send_header('Content-Encoding', encoding)

    self.send_header('Accept-Ranges', 'bytes')

    if 'Range' in self.headers:
      s, e = self.headers['range'][6:].split('-', 1)
      # Ranges may be given as "a-b,c-d,e-f".
      # TODO
      # Handle this properly (probably better to wait until code is rewritten).
      e = e.split(',', 1)[0]
      sl = len(s)
      el = len(e)
      if sl > 0:
        range_start = int(s)
        if el > 0:
          range_end = int(e) + 1
      elif el > 0:
        ei = int(e)
        if ei < size:
          range_start = size - ei

    self.send_header('Content-Range', 'bytes ' + str(range_start) + '-' + str(range_end - 1) + '/' + str(size))
    self.send_header('Content-Length', range_end - range_start)
    self.end_headers()

    if include_body:
      f = open(fpath, 'rb')
      f.seek(range_start, 0)
      step = 0x8000
      total = 0
      while step > 0:
        if range_start + step > range_end:
          step = range_end - range_start
        try:
          self.wfile.write( f.read(step) )
        except:
          break
        total += step
        range_start += step
      f.close()

  def local_redirect(self, path='/', response_code=303, message=None):
    self.send_response(response_code, message)
#     address, port = self.request.getsockname()
#     if self.server.use_ssl:
#       scheme = 'https'
#     else:
#       scheme = 'http'
#     url = '%s://%s:%s%s' % (scheme, address, port, path)
    url = path
#    self.send_header('Content-Type', 'text/html')
    self.send_header('Content-Length', 0)
#    self.send_header('Content-Location', url)
    self.send_header('Location', url)
#    self.send_header('Connection', 'close')
    self.end_headers()
    self.wfile.write('')


  ##### Request Handlers #####
  def do_GET(self):
    if self.authenticate('GET'):
      self.do_authenticated_GET()

  def do_authenticated_GET(self):
    BaseHTTPServer.BaseHTTPRequestHandler.do_GET(self)

  def do_HEAD(self):
    if self.authenticate('GET'):
      self.do_authenticated_HEAD()

  def do_authenticated_HEAD(self):
    BaseHTTPServer.BaseHTTPRequestHandler.do_HEAD(self)

  def do_POST(self):
    if self.authenticate('POST'):
      self.do_authenticated_POST()
    return True

  def do_authenticated_POST(self):
    BaseHTTPServer.BaseHTTPRequestHandler.do_POST(self)

################################################################################
# Common Options
################################################################################

def add_common_options(parser, default_port=8000):
  # Address and port
  listening_options = OptionGroup(parser, "Server Address and Port", "Configure the server's listening address and port.")
  listening_options.add_option("-b", "--bind", dest="address", default='', action="store", help='Bind the server to this address. By default the server will listen on all interfaces.')
  listening_options.add_option("-p", "--port", dest="port", default=default_port, type="int", action="store", help='Set the server port (default: %s)' % (default_port))
  parser.add_option_group(listening_options)

  # HTTP Authentication
  auth_options = OptionGroup(parser, "HTTP Authentication", "HTTP digest authentication via a username and password.")
  auth_options.add_option("--username", dest="username", action="store")
  auth_options.add_option("--password", dest="password", action="store")
  auth_options.add_option("--authfile", dest="authfile", action="store", help="The path to a file containing a username on the first line and a password on the second line. This can be used if you do not want to type the password on the command line when starting the server, e.g. to prevent it from being displayed with \"ps aux\".")
  parser.add_option_group(auth_options)

  # SSL
  ssl_options = OptionGroup(parser, "SSL (HTTPS)",  'Wrap sockets in SSL for encrypted connections. Simply enabling SSL does not guarantee a secure connection and it is the user\'s responsibility to check that the implementation is correct and secure and that the server is properly configured. You can find information about generating self-signed certificates in the OpenSSL FAQ: http://www.openssl.org/support/faq.html')
  ssl_options.add_option("--ssl", dest="ssl", action="store_true", help='Enable SSL (HTTPS).')
  ssl_options.add_option("--certificate", dest="certfile", metavar="path", action="store", help='Set the path to the server\'s certificate.')
  ssl_options.add_option("--key", dest="keyfile", metavar="path", action="store", help='Set the path to the server\'s key.')
  ssl_options.add_option("--req-cert", dest="req_cert", action="store_true", help='Require a certificate from the client.')
  ssl_options.add_option("--ca-certs", dest="ca_certs", metavar="path", action="store", help='Set the path to a file containing concatenated CA certificates for verifying the client certificate. This defaults to the server\'s own certificate.')
  parser.add_option_group(ssl_options)

  # Logging
  logging_options = OptionGroup(parser, 'Logging', 'Log messages are printed to STDERR by default. You can easily redirect these to a file by appending "2>/path/to/file" to the end of the command, e.g. "<cmd> 2>/path/to/log".')
  parser.add_option_group(logging_options)

  return parser

##################################################################################
##################################################################################

class MyHandler(BaseHTTPRequestHandler):

  def version_string(self):
    return "%s/%s" % (NAME, VERSION)

  def do_authenticated_GET(self):
    self.do_GET_or_HEAD(True)


  def do_authenticated_HEAD(self):
    self.do_GET_or_HEAD(False)


  def do_GET_or_HEAD(self,is_GET):
    query_args = {'text':'html'}

    i = self.path.find('?')
    if i > -1:
      query = self.path[i+1:]
      self.path = self.path[:i]

      for q in query.split('&'):
        k, v = q.split('=')
        query_args[unquote(k)] = unquote(v)

    self.path = unquote(self.path)

    if options.upload_dir and query_args.has_key('upload'):
      try:
        n = int( query_args['upload'] )
        if n < 1:
          n = 1
      except ValueError:
        n = 1
      if query_args['text'] == 'plain':
        self.transfer_plaintext( "Post parameters for uploading files:\n\tfile_1=foo\n\tfile_2=bar\n\tetc.\n\nQuickupload: http://xyne.archlinux.ca/projects/quickserve/#quickupload\n", is_GET )
      else:
        self.transfer_html( get_upload_html(back=self.path, n=n), is_GET )
      return

    if options.filelist:
      maybe_load_list(self.server, options.filelist)

    if options.filterlist:
      maybe_load_list(self.server, options.filterlist)

    global paths

    if options.infopage and self.path == options.infopage:
      if query_args['text'] == 'plain':
        self.transfer_plaintext( get_info_plain(), is_GET )
      else:
        self.transfer_html( get_info_html(), is_GET )
      return

    elif self.path == '/':
      dirs = []
      files = []
      for k in paths.keys():
        if os.path.isdir(paths[k]):
          dirs.append(k)
        else:
          files.append(k)
      dirs = sorted(dirs)
      files = sorted(files)
      contents = dirs + files
      contents = filter(include_file, contents)
      if query_args['text'] == 'plain':
        text = get_page_plain(self.path, contents)
        self.transfer_plaintext( text, is_GET )
      else:
        html = get_page_html(self.server, self.path, contents, options.motd)
        self.transfer_html( html, is_GET )
      return

    else:
      self.path = self.path.rstrip('/')
      splitpath = self.path[1:].split(os.sep,1)
      if splitpath[0] in paths:
        if splitpath[0] == self.path[1:]:
          fpath = paths[splitpath[0]]
        elif len(splitpath) == 2:
          fpath = os.path.join(paths[splitpath[0]], splitpath[1])
        else:
          fpath = None
        if os.path.isfile(fpath) and include_file(fpath):
          self.transfer_file(fpath)
          return
        elif os.path.isdir(fpath):
          dirs, files = get_dirs_and_files(fpath)
          contents = dirs + files
          contents = filter(lambda x: include_file(x, base_dir=fpath), contents)
          if query_args['text'] == 'plain':
            text = get_page_plain(self.path, contents)
            self.transfer_plaintext( text, is_GET )
          else:
            html = get_page_html(self.server, self.path, contents, options.motd)
            self.transfer_html( html, is_GET )
          return

    self.local_redirect(message='File Not Found', response_code=404)


  def do_authenticated_POST(self):

    if options.upload_dir:
      form = cgi.FieldStorage(
          fp=self.rfile,
          headers=self.headers,
          environ={'REQUEST_METHOD':'POST',
                   'CONTENT_TYPE':self.headers['Content-Type'],
                   })
      if form.has_key('file_1'):
        if not os.path.exists(options.upload_dir):
          try:
            os.makedirs(options.upload_dir)
          except:
            self.server.log_message("failed to create %s", options.upload_dir)
            self.send_response(500, 'Internal Server Error')
            self.send_header('Connection', 'close')
            self.end_headers()
            return

      i = 1
      k = 'file_' + str(i)
      response = ''
      while form.has_key(k):
        # this prevent attribute errors if the form reuses a name
        if type(form[k]) is list:
          field = form[k][0]
        else:
          field = form[k]

        if field.filename:
          try:
            fpath = os.path.join(options.upload_dir, field.filename)
            if (options.no_clobber):
              npath = fpath
              j = 1
              while os.path.exists(fpath):
                fpath = npath + '.' + str(j)
                j += 1
            f =  open(fpath, 'w')
            f.write( field.value )
            f.close()
          except:
            self.server.log_message("failed to save %s", fpath)
            continue
        i += 1
        k = 'file_' + str(i)
      # this throws an error often enough to be worth catching
      try:
        message = "Upload accepted. Redirecting to " + self.path
        self.local_redirect(path=self.path, message=message)
      except:
        pass

    else:
      self.send_response(403, "Forbidden")
      self.send_header('Connection', 'close')
      self.end_headers()

def get_dirs_and_files(path):
  if os.path.isdir(path):
    paths = os.listdir(path)
    return sorted(filter(lambda x: os.path.isdir(os.path.join(path,x)), paths)), sorted(filter(lambda x: os.path.isfile(os.path.join(path,x)), paths))
  elif os.path.isfile(path):
    return [], [os.path.basename(path)]
  else:
    return [], []

def resolve(path, contents):
  global paths
  i = path.find('/',1)
  if i > 0:
    root = path[1:i]
  else:
    root = path[1:]

  if root != '':
    href = quote('/' + path[1:].rpartition('/')[0])
    if href[-1] != '/':
      href += '/'
    href_root = href
  else:
    href_root = ''

  resolved = []
  for c in contents:
    if root != '':
      upath = path.replace(root, paths[root], 1) + '/' + c
      href = path + '/' + c
    else:
      upath = paths[c]
      href = '/' + c
    href = quote(href)

    if not os.path.exists(upath):
      continue
    stat = os.stat(upath)
    gm_time = gmtime(stat.st_mtime)
    str_time = strftime("%Y-%m-%d %H:%M:%S", gm_time)
    if os.path.isdir(upath):
      href += '/'
      size = ''
    else:
      size = format_size(stat.st_size)

    resolved.append((href, c, size, str_time))

  return href_root, resolved


def get_page_html(server, path, contents, motd_fpath=None):
  root, resolved = resolve(path, contents)
  motd = ''
  if motd_fpath:
    try:
      with open(motd_fpath) as f:
        motd = f.read()
    except IOError as (errno, strerror):
      server.log_message("error: failed to load motd file %s: %s", motd_fpath, strerror)
      server.keep_serving = False
  if root != '':
    backlink = '<a class="extralink" href="%s">Back</a>' % root
  else:
    backlink = ''

  title = ''
  trunk = ''
  components = path.split('/')
  for p in components[:-1]:
    if p:

      trunk += '/' + p
      title += '/<a href="%s">%s</a>' % (trunk, p)
  title += '/' + components[-1]

  if options.upload_dir:
    uploadlink = '<a class="extralink" href="%s?upload=1">Upload</a>' % quote(path)
  else:
    uploadlink = ''

  filelist_html = "<table>\n      <tr><th>File</th><th>Size</th><th>Last Modified (GMT)</th></tr>\n"
  for (href, c, size, str_time) in resolved:
    filelist_html += '      <tr><td class="alignl"><a href="' + href + '">' + c + '</a></td><td>' + size + '</td><td>' + str_time + "</td></tr>\n"
  filelist_html += "    </table>"

  body = '''    <h1>%(title)s%(backlink)s%(uploadlink)s</h1>
%(motd)s
    %(filelist)s
''' % {'title': title, 'filelist': filelist_html, 'backlink': backlink, 'uploadlink': uploadlink, 'motd': motd}

  return get_html(path + " - " + NAME, body, style='.alignl { text-align: left } table { white-space: pre }')


def get_page_plain(path, contents):
  root, resolved = resolve(path, contents)
  links = []

  for (href, c, size, str_time) in resolved:
    links.append( ("%s  %10s  %s") % (str_time, size, href) )

  return ("\n".join(links) + "\n")


def get_upload_html(back='/', n=1):
  if n < 1:
    n = 1

  backlink = '<a href="%s">[Back]</a>' % (back)
  morelink = '<a href="%s?upload=%d">[More]</a>' % (back,n+1)

  if n > 1:
    fewerlink = '<a href="%s?upload=%d">[Fewer]</a>' % (back,n-1)
  else:
    fewerlink = ''

  w = len(str(n))

  def get_row(i):
    i = str(i)
    label = 'File'
    if n > 1:
      s = w - len(i) + 1
      label += (' ' * s) + i
    field = '<input type="file" name="file_' + i + '" size="40"/>'
    return '<tr><th>%(label)s</th><td>%(field)s</td></tr>' % {'label': label, 'field': field}

  input_rows = "\n        ".join( map(get_row, range(1,n+1)) )

  body = '''    <h1>Upload%(backlink)s%(morelink)s%(fewerlink)s</h1>
    <form action="%(back)s" enctype="multipart/form-data" method="post">
      <table>
        %(input_rows)s
        <tr><th></th><td><input style="margin-top: 20px" type="submit" value="Upload" onclick="document.getElementById(\'uploading\').style.display=\'\';"/></td></tr>
      </table>
    </form>
    <div id="uploading" style="display:none;text-align:center">Upload in progress, please wait...</div>
''' % {'back': back, 'backlink': backlink, 'morelink': morelink, 'fewerlink': fewerlink, 'input_rows': input_rows}
  return get_html('Upload - ' + NAME, body, style='form { margin-left: 10px; font-family: monospace }')


def get_info():
  global paths
  info = []

  if options.address:
    address = options.address
  else:
    address = 'all interfaces'
  info.append(('address',address))

  info.append(('port',options.port))
  info.append(('pid',os.getpid()))

  if options.username or options.password:
    auth = "yes"
  else:
    auth = "no"
  info.append(('HTTP authentication', auth))

  if options.upload_dir:
    upload_dir = options.upload_dir
  else:
    upload_dir = "none"
  info.append(('upload directory', upload_dir))

  info.append(('serving', sorted(paths.values())))

  return info


def get_info_html():
  info = get_info()
  body = '''    <h1>%s Information</h1>
    <table class="info_table">
''' % (NAME)
  for (k,v) in info:
    if type(v) is list:
      body += "        <tr><th valign=\"top\">%s</th><td>%s</td></tr>\n" % (k,"\n".join(v))
    else:
      body += "        <tr><th>%s</th><td>%s</td></tr>\n" % (k,v)
  body += '    </table>'
  style = '.info_table td { text-align: left; }'
  return get_html(NAME + ' Information', body, style=style)


def get_info_plain():
  info = get_info()
  body = NAME + ' Information'
  for (k,v) in info:
    if type(v) is list:
      v = "\n\t".join(v)
      body += "%s:\n\t%s\n" % (k,v)
    else:
      body += "%s: %s\n" % (k,v)
  return body


def get_html_doctype():
  return '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- %s - author: Xyne, homepage: http://xyne.archlinux.ca/projects/quickserve -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
''' % (NAME)

def get_html_head(title, tags="", style=""):
  return '''<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <link rel="icon" type="image/png" href="data:image/png;base64,%(icon)s" />
  <title>%(title)s</title>
  %(tags)s
  <style type="text/css">
    html, body { background-color: #fff;padding: 0;margin: 0 }
    body { font-family: "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", Verdana, Arial, sans-serif }
    h1 { font-weight: normal; color: #333; margin-bottom: 0.5em; font-size: 2.5em; line-height: 1em }
    h1 a { color: #339; }
    h1 a.extralink { font-size: 0.5em; text-decoration: none; margin-left: 1em }
    h1 a.extralink:before { content: "["; }
    h1 a.extralink:after { content: "]"; }
    table { font-family: monospace; border-spacing:10px 4px; margin-bottom: 5em }
    th { text-align: left; white-space: pre }
    td { text-align: right }

    #wrapper { margin: 0 auto;width: 90%% }

    %(style)s
  </style>
</head>
''' % {'icon': icon_png_b64, 'tags': tags, 'title': title, 'style': style}

def get_html(title, body, head_tags="", style=""):
  return get_html_doctype() + get_html_head(title, head_tags, style) + "<body>\n  <div id=\"wrapper\">\n" + body + "  </div>\n</body>\n</html>\n"

# SVG icon, source of the PNG icon base64-encoded below.
# icon_svg =
'''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.1"
   width="480"
   height="480.00009"
   id="svg2">
  <defs
     id="defs4" />
  <g
     transform="translate(402.63737,-254.74002)"
     id="layer1">
    <g
       transform="matrix(0.89691061,0,0,0.99219468,-41.495722,5.7348142)"
       id="g3746">
      <path
         d="m -400.02121,492.85212 143.52718,0 0,-239.51113 86.38433,0 0,479.02225 -229.91151,-239.51112 z"
         id="path2818"
         style="fill:#366994;fill-opacity:1;stroke:#000000;stroke-width:5;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
      <path
         d="m 129.8903,492.85211 -143.52718,0 0,239.51113 -86.38433,0 0,-479.02225 229.91151,239.51112 z"
         id="path3744"
         style="fill:#ffc331;fill-opacity:1;stroke:#000000;stroke-width:5;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
    </g>
  </g>
</svg>
'''

icon_png_b64 = '''iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
AAAAdgAAAHYBTnsmCAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAGASURB
VDiNY/j//z8DMlZ2jl+jG179Rs0r4zEDAwMHAwMDR2OyZAu6OhhmYkAD7HzCzJxCksKcghL8MLFg
e4HsFY2KyehqGRgYMA3ABjjZmZg9LfgmziqT8yDLAAYGBgZ+bmZufxuB+Z2Z0oZkGcDAwMAgLsQi
EeoosKwkUlyWLAMYGBgYlKTYNWLdhZZ5mPPzkWUAAwMDg74Kp015tNg8RkZGZiZGRkYJZPzv7x+c
hn778Y/hxbvfDC/e/WbQVOAInpQvM5NF3ia0RUjZEB5FzGwcOG0+cfXrJueCO+nIYiwPj6xO5xSS
FOCTVgsm5HQONqZ/////f4FiwP////8KyGklsXBwi3MJS9sQMgQdMDEwMDB8eHTt05ubp6J+fnpz
gywDGBgYGJ5f2PP43d3zUb+/fX6BTwNOAxgYGBgeHd9w/v2DS4l/f33/SpYBDAwMDPcPLNvx4dG1
/H9/fv8lxgAWbIJ3ds2bK2PmowjjX3/w4+P3n/9+3Xv+868VmloAYBOPZZUd3JEAAAAASUVORK5C
YII='''


def format_size(size):
  size = float(size)
  s = '  B'
  if size > 0x400:
    size /= 0x400
    s = 'kiB'
  if size > 0x400:
    size /= 0x400
    s = 'MiB'
  if size > 0x400:
    size /= 0x400
    s = 'GiB'
  if size > 0x400:
    size /= 0x400
    s = 'TiB'
  return "%6.02f %s" % (size,s)


def maybe_load_list(server, fpath):
  global mtimes
  global paths
  try:
    mtime = os.stat(fpath).st_mtime
    if mtime > mtimes[fpath]:
      if options.filelist == fpath:
        server.log_message("reloading filelist (%s)", fpath)
        paths = get_paths( read_filelist(server, fpath) )
        server.log_message("  serving:\n    " + ("\n    ").join(filter(include_file, sorted(paths.values()))))
        mtimes[fpath] = mtime
      elif options.filterlist == fpath:
        server.log_message("reloading filterlist (%s)", fpath)
        read_filterlist(server, fpath)
        mtimes[fpath] = mtime
  except OSError as (errno, strerror):
    server.log_message("error: failed to stat %s: %s", fpath, strerror)
    server.keep_serving = False
    paths = {}


def read_filelist(server, fpath):
  try:
    f = open(fpath,'r')
    ps = filter(lambda x: x, map(lambda x: x.rstrip('\r\n\0'), f.readlines()))
    f.close()
    # return paths relative to the location of the filelist
    basedir = os.path.dirname(fpath)
    ps = map(lambda p: os.path.join(basedir,p), ps)
    return ps
  except IOError as (errno, strerror):
    server.log_message("error: failed to open %s: %s", fpath, strerror)
    server.keep_serving = False
    exit(1)


def read_filterlist(server, fpath):
  try:
    f = open(fpath,'r')
    options.includes = []
    options.excludes = []
    for line in f:
      line = line.rstrip('\r\n\0')
      if line[:2] == '+ ':
        options.includes.append( re.compile(line[2:]) )
      elif line[:3] == '+i ':
        options.includes.append( re.compile(line[3:], re.I) )
      elif line[:2] == '- ':
        options.excludes.append( re.compile(line[2:]) )
      elif line[:3] == '-i ':
        options.excludes.append( re.compile(line[3:], re.I) )
    f.close()
  except IOError as (errno, strerror):
    server.log_message("error: failed to open %s: %s", fpath, strerror)
    server.keep_serving = False
    exit(1)


def get_paths(ps):
  paths = {}
  for p in ps:
    p = os.path.abspath(p)
    #if include_file(p):
    paths[os.path.basename(p)] = p
  return paths


def include_file(fpath, base_dir=None):
  if base_dir:
    fpath = os.path.join(base_dir, fpath)
  includable = True
  if options.includes:
    # files that do not match and include filter are excluded by default
    if os.path.isfile(fpath):
      includable = False
    for regex in options.includes:
      if regex.search(fpath):
        includable = True
        break
  if includable:
    for regex in options.excludes:
      if regex.search(fpath):
        includable = False
        break
  return includable


def display_filter_help(*args):
  print '''FILTER OPTIONS
  By default, all files specified on the command line or in the filelist are
  served. These options allow you to filter the served files using regular
  expressions.

  If any inclusive filters are given, only files matching at least one inclusive
  filter will be served. Inclusive filters are not applied to directories.

  Whether or not inclusive filters are given, exclusive filters are applied to
  all files *and* directories.

  The options "--include", "--Include", "--exclude" and "--Exclude" accept
  Python regular expressions as arguments. You may pass these options multiple
  times to create lists of inclusive and exclusive filters. The order of the
  arguments is irrelevant.

  You can find information about Python regular expression syntax here:

    http://docs.python.org/library/re.html#regular-expression-syntax

FILTERLIST
  In addition to the options mentioned above, it is also possible to use a list
  of filters in a file with the "--filterlist" option. This is similar to the
  "--filelist" option in that the file will be reloaded while the server is
  running if it is modified. This enables you to dynamically configure the
  filters without restarting the server.

  The following lines in the filterlist file will be recognized, where "<regex>
  is a regular expression continuing to the end of the line:

    + <regex>
      Case-sensitive inclusive filter

    +i <regex>
      Case-insensitive inclusive filter.

    - <regex>
      Case-sensitive exclusive filter

    -i <regex>
      Case-insensitive exclusive filter.

  Other lines should be ignored. Here is an example that would include pdf and
  mp3 files but filter anything nested inside a directory named "private":

    +i \.pdf$
    +i \.mp3$
    - /private/
'''
  sys.exit()

def main(options):

  ssl_parameters = { 'keyfile':options.keyfile, 'certfile':options.certfile, 'ca_certs':options.ca_certs }
  server = ThreadedHTTPServer((options.address, options.port), MyHandler, username=options.username,
                              password=options.password, authfile=options.authfile,
                              use_ssl=options.ssl, ssl_parameters=ssl_parameters, cert_required=options.req_cert )

  global paths

  print "Starting %s..." % (os.path.basename(sys.argv[0]))
  server.display_status()

  if options.infopage:
    print "  infopage: " + options.infopage

  if options.upload_dir:
    print "  upload directory: " + options.upload_dir

  print "  serving:\n    " + ("\n    ").join(sorted(paths.values()))
  print "Press <Ctrl-C> to exit.\n"
  print server.run_server()


if __name__ == '__main__':
  parser = OptionParser(description='%prog - a simple HTTP server for quickly sharing files', usage='%prog [options] [paths]')

  parser.add_option("-f", "--filelist", dest="filelist", action="store", help='Serve files listed in a filelist. The list should contain a single path per line. If the list is modified while the server is running, it will be reloaded. The directory that contains the filelist is considered the base directory for relative paths in the list. Absolute paths should be preferred.')

  parser.add_option("-i", "--infopage", dest="infopage", action="store", help='Specify an info page that you can visit to see information about the server. The value should be a path and must include the leading "/", e.g. "/info" or "/sklfj23k42jf/supersecret_info". This page will not be linked directly by any other page on the server, but if this path coincides with another path on the server, it will take precedence. This option is affected by the Firefox bug.')

  parser.add_option("--no-clobber", dest="no_clobber", action="store_true", help='Prevent uploaded files from clobbering existing files by appending an incrementing number to the filename.')

  parser.add_option("-u", "--upload", dest="upload_dir", action="store", help='Enable file uploads and save them in the specified directory.')

  parser.add_option("-m", "--motd", dest="motd", action="store", help='Path to file containing MOTD message to display on each page. The message should be valid XHTML.')

  # Includes and Excludes
  filter_options = OptionGroup(parser, "Filtering Options", "See the output of \"--filterhelp\" for more information.")
  filter_options.add_option("--filterhelp", action="callback", callback=display_filter_help, help="Display information about filtering options.")
  filter_options.add_option("--filterlist", dest="filterlist", action="store", help="A file containing a list of inclusive and exclusive filters. If the list is modified while the server is running, it will be reloaded.")
  filter_options.add_option("--include", dest="includes", metavar="<Python regex>", action="append", default=[], help='A regular expression to filter files for inclusion. Case-insensitive.')
  filter_options.add_option("--Include", dest="Includes", metavar="<Python regex>", action="append", default=[], help='A regular expression to filter files for inclusion. Case-sensitive.')
  filter_options.add_option("--exclude", dest="excludes", metavar="<Python regex>", action="append", default=[], help='A regular expression to filter files for exclusion. Case-insensitive.')
  filter_options.add_option("--Exclude", dest="Excludes", metavar="<Python regex>", action="append", default=[], help='A regular expression to filter files for exclusion. Case-sensitive.')
  parser.add_option_group(filter_options)

  parser = add_common_options(parser)

  (options, args) = parser.parse_args()

  if not (args or options.filelist or options.upload_dir):
    parser.print_help()
    exit(1)

  if options.upload_dir:
    options.upload_dir = os.path.abspath( options.upload_dir )

  # filtering
  options.includes = map(re.compile, options.includes) + map(re.compile, options.Includes, [re.I] * len(options.Includes))
  options.excludes = map(re.compile, options.excludes) + map(re.compile, options.Excludes, [re.I] * len(options.Excludes))

  global paths
  global mtimes
  mtimes = {}
  if options.filelist:
    try:
      mtimes[options.filelist] = os.stat(options.filelist).st_mtime
    except OSError as (errno, strerror):
      print "error: failed to stat %s: %s" % (options.filelist,strerror)
      exit(1)
    ps = read_filelist(server, options.filelist)
  else:
    ps = args

  if options.filterlist:
    try:
      mtimes[options.filterlist] = os.stat(options.filterlist).st_mtime
    except OSError as (errno, strerror):
      print "error: failed to stat %s: %s" % (options.filterlist,strerror)
      exit(1)
    read_filterlist(server, options.filterlist)

  paths = get_paths(ps)
  main(options)
