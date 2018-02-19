#
# Ping - bounce ICMP identify packets off remote hosts
#
#    The author of this code (a) does not expect anything from you, and
#    (b) is not responsible for any problems you may have using this code.
#
# requires: python2 and root/administrator privs to use icmp port 22
# tested on: Arch Linux (as of feb 2014), Windows 8
#
# Linux:
#
#   On Linux capabilities can be used to grant 'cap_net_raw+ep' to
#   python scripts by copying the python *binary* to a separate
#   directory and setting the copy's capabilities with setcap:
#
#       $ cp /usr/bin/python2.7 python_net_raw
#       # setcap cap_net_raw+ep python_net_raw
#       $ ./python_net_raw ping.py ...
#
# Windows 8:
#
#   Right click icon in lower left of screen, use Command Prompt (Admin)

__date__ = "2014/02/27"
__version__ = "v0.93"

import sys
import time

# -----------------------------------------------------------------------
# A thread based polling service with pause and kill.
# Since it polls the function passed in, the function
# needs to return as soon as possible.

import threading

ST_KILLED  = 0
ST_PAUSED  = 1
ST_RUNNING = 2
ST_names = { 0:"killed", 1:"paused", 2:"running" }

class Poll(threading.Thread):
    def __init__(self, func, args=(), name=None, period=0.1):
        # we need a tuple here
        if type(args) != type((1,)):
            args = (args,)
        self._function = func
        self._args = args
        self.period = period
        threading.Thread.__init__(self, target=func, name=name, args=())
        self._uptime = time.time()
        self._state = ST_RUNNING
        self.start()

    def run(self):
        while self._state != ST_KILLED:
            if self._state == ST_RUNNING:
                self._function(self._args)
            time.sleep(self.period)

    # note: all threads must be killed before python will exit!
    def kill(self):
        self._state = ST_KILLED

    def pause(self):
        if self._state == ST_RUNNING:
            self._state = ST_PAUSED

    def resume(self):
        if self._state == ST_PAUSED:
            self._state = ST_RUNNING

    def uptime(self):
        return time.time() - self._uptime

    def state(self):
        return ST_names[self._state]

    def __str__(self):
        return self.getName()

    @staticmethod
    def thread_list():
        return [x for x in threading.enumerate()
                    if x.getName() != "MainThread"]

    @staticmethod
    def tlist():
        """Human readable version of thread_list()"""
        for t in Poll.thread_list(): 
            if isinstance(t, Poll):
                print "%-16s  %-8s  %4.3f" % (t, t.state(), t.uptime())

    @staticmethod
    def killall():
        for t in Poll.thread_list(): 
            t.kill()

# -----------------------------------------------------------------------
# ping from scratch

import os
import types
import struct
import socket

class PingService(object):
    """Send out icmp ping requests at 'delay' intervals and
       watch for replies.  The isup() method can be used by
       other threads to check the status of the remote host.

       @host         - (string) ip of host to ping
       @delay        - (float) delay in seconds between pings
       @its_dead_jim - (int) seconds to wait before running offline()
       @verbose      - (bool) print round trip stats for every reply
       @persistent   - (bool) thread continues to run even if no reply

       usage:       p = PingService('192.168.1.1')
                    p.start()           - begin ping loop
                    p.isup()            - True if host has replied recently
                    p.stop()            - stop ping loop

       online() and offline() methods can be overloaded:

                    def my_online(self):
                        self.log(self.host + " is up")

                    p.online = types.MethodType(my_online, p)

    """

    # provide a class-wide thread-safe message queue
    msgs = []

    def __init__(self, host, delay=1.0, its_dead_jim=4,
                 verbose=True, persistent=False):
        self.host = host
        self.delay = delay
        self.verbose = verbose
        self.persistent = persistent
        self.obituary_delay = its_dead_jim * delay
        self.pad = "getoff my lawn"         # should be 14 chars or more
        socket.setdefaulttimeout(0.01)
        self.started = 0
        self.thread = None
        self._isup = False
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_RAW,
                                  socket.getprotobyname('icmp'))
        try:
            self.sock.connect((host, 22))
        except socket.gaierror, ex:
            self.log("ping socket cannot connect to %s: %s" % (host, ex[1]))
            self.sock.close()
            return

    def log(self, msg):
        if not self.verbose:
            msg = time.strftime("%H:%M:%S ") + msg
        self.msgs.append(msg)

    def start(self):
        self.seq = 0
        self.pid = os.getpid()
        self.last_heartbeat = 0
        # send a ping right away
        self.time_to_send = self.started = time.time()
        self.thread = Poll(self._ping, (None), name=self.host)
        #retry = int(round(self.obituary_delay / 0.2))
        ## retry, before letting caller deal with a down state
        #while retry > 0 and not self._isup:
        #    time.sleep(0.2)
        #    retry -= 1

    def stop(self):
        if self.thread:
            self.thread.kill()
            self.thread = None

    def _icmp_checksum(self, pkt):
        n = len(pkt)
        two_bytes = struct.unpack("!%sH" % (n/2), pkt)
        chksum = sum(two_bytes)
        if n & 1 == 1:
            chksum += pkt[-1]
        chksum = (chksum >> 16) + (chksum & 0xffff)
        chksum += chksum >> 16
        return ~chksum & 0xffff

    def _icmp_create(self, data):
        fmt = "!BBH"
        args = [8, 0, 0]
        if data and len(data) > 0:
            fmt += "%ss" % len(data)
            args.append(data)
        args[2] = self._icmp_checksum(struct.pack(fmt, *args))
        return struct.pack(fmt, *args)

    def _icmp_parse(self, pkt):
        """Parse ICMP packet"""
        string_len = len(pkt) - 4 # Ignore IP header
        fmt = "!BBH"
        if string_len:
            fmt += "%ss" % string_len
        unpacked_packet = struct.unpack(fmt, pkt)
        typ, code, chksum = unpacked_packet[:3]
        if self._icmp_checksum(pkt) != 0:
            self.log("%s reply checksum is not zero" % self.host)
        try:
            data = unpacked_packet[3]
        except IndexError:
            data = None
        return typ, code, data


    def _ping(self, args):
        pdatafmt = "!HHd%ds" % len(self.pad)
        now = time.time()
        if now >= self.time_to_send:
            # send ping packet 
            self.seq += 1
            self.seq &= 0xffff
            pdata = struct.pack(pdatafmt, self.pid, self.seq, now, self.pad)
            self.sock.send(self._icmp_create(pdata))
            self.time_to_send = now + self.delay

        if self._isup and now - self.last_heartbeat > self.obituary_delay:
            self._isup = False
            self.offline()

        if self.last_heartbeat == 0 \
        and not self.persistent \
        and now - self.started > self.obituary_delay:
            if self.verbose:
                self.log("no response from " + self.host)
            self.thread.kill()
            self.thread = None
            return

        try:
            rbuf = self.sock.recv(10000)
            now = time.time()       # refresh 'now' to make rtt more accurate
        except socket.timeout:
            return

        if len(rbuf) <= 20:
            self.log("%s truncated reply" % self.host)
            return

        # parse ICMP packet; ignore IP header
        typ, code, rdata = self._icmp_parse(rbuf[20:])

        if typ == 8:
            self.log("%s is pinging us" % self.host)
            self.last_heartbeat = now
            if not self._isup:
                self._isup = True
                self.online()
            return
 
        if typ == 3:
            self.log("%s dest unreachable (code=%d)" % (self.host, code));
            return

        if typ != 0:
            self.log("%s packet not an echo reply (%d) " % (self.host, typ))
            return

        if not rdata:
            self.log("%s packet contains no data" % (self.host))
            return

        if len(rdata) != 12 + len(self.pad):
            # other ping programs can cause this
            # self.log("%s not our ping (len=%d)" % (self.host, len(rdata)))
            return

        # parse ping data
        (ident, seqno, timestamp, pad) = struct.unpack(pdatafmt, rdata)

        if ident != self.pid:
            # other instances of PingService can cause this
            #self.log("%s not our ping (ident=%d)" % (self.host, ident))
            return

        if seqno != self.seq:
            self.log("%s sequence out of order " % self.host +
                     "got(%d) expected(%d)" % (seqno, self.seq))
            return

        if rdata and len(rdata) >= 8:
            self.last_heartbeat = now

            if not self._isup:
                self._isup = True
                self.online()

            if self.verbose:
                str = "%d bytes from %s: seq=%u" % (
                      len(rbuf),
                      # inet_ntop not available on windows
                      '.'.join([('%d' % ord(c)) for c in list(rbuf[12:16])]),
                      self.seq)

                # calculate rounttrip time
                rtt = now - timestamp
                rtt *= 1000
                # note that some boxes that run python
                # can't resolve milisecond time deltas ...
                if rtt > 0:
                    str += ", rtt=%.1f ms" % rtt

                self.log(str)

    def online(self):
        if not self.verbose:
            self.log("%s is up" % self.host)

    def offline(self):
        if not self.verbose:
            self.log("%s is down" % self.host)

    def isup(self):
        return self._isup

# ----------------------------------------------------------------------------
# demonstrate PingService

if __name__ == "__main__":
    import traceback
    import types

    if len(sys.argv) < 2:
        print "usage: python2 ping.py <ip>"
        sys.exit(1)

    ping_svc = PingService(sys.argv[1])

    try:
        ping_svc.start()

        while len(Poll.thread_list()) > 0:
            time.sleep(0.2)

            # print log messages
            while len(PingService.msgs) > 0:
                print PingService.msgs.pop(0)

    except KeyboardInterrupt:
        pass

    except:
        t, v, tb = sys.exc_info()
        traceback.print_exception(t, v, tb)

    # note: all threads must be stopped before python will exit!
    ping_svc.stop()

    sys.exit(0)


# ex: set tabstop=8 expandtab softtabstop=4 shiftwidth=4:
