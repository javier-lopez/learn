#!/usr/bin/python

# Copyright (C) 2012 Canonical, Ltd.
# Author: Matthew Fischer <matthew.fischer@canonical.com>

"""
find_input:
Finds the mouse and keyboard input devices using /sys
"""

import os
import platform
import logging

__author__ = "Matthew Fischer"
__version__ = "0.2"
__copyright__ = "Copyright (c) 2012 Canonical Ltd."
__license__ = "GPL"

SEARCH_DIR = '/sys/class/input'
logging.basicConfig(level=logging.INFO)

def word_size():
    bits, binary_format = platform.architecture()
    if bits.lower() == '32bit':
        logging.debug("word size is 32 bits")
        return 32
    elif bits.lower() == '64bit':
        logging.debug("word size is 64 bits")
        return 64
    else:
        raise Exception('word size is an unexpected value: %s' % bits)

WORD_SIZE = word_size()

def create_mask(length):
    ret = []
    for i in range (0,length):
        ret.append(False)
    return ret

def set_mask(intval, startidx, wordsize, mask):
    for i in range (startidx,startidx+wordsize):
        if (1 << (i-startidx)) & intval:
            mask[i] = True
        else:
            mask[i] = False

# we only process in words, so masks must be a multiple
def get_mask_length(max_bit):
    if max_bit <= 0:
        return WORD_SIZE
    else:
        return ((max_bit/WORD_SIZE) + 1) * WORD_SIZE

# These are all from /usr/include/linux/input.h
class Bits:
    # ev
    EV_KEY =        0x01
    EV_REL =        0x02
    EV_ABS =        0x03
    EV_MAX =        0x1f

    # rel
    REL_X =         0x00
    REL_Y =         0x01
    REL_MAX =       0x0f

    # abs
    ABS_X =         0x00
    ABS_Y =         0x01
    ABS_MAX =       0x3f

    # key
    KEY_1              = 2
    KEY_2              = 3
    KEY_3              = 4
    KEY_Q              = 16
    KEY_W              = 17
    KEY_E              = 18
    BTN_MISC           = 0x100
    BTN_MOUSE          = 0x110
    BTN_TOOL_FINGER    = 0x145
    KEY_OK             = 0x160
    BTN_TRIGGER_HAPPY  = 0x2c0
    KEY_MAX            = 0x2ff

class Device:
    _path = ""
    _evmask = []
    _absmask = []
    _relmask = []
    _keymask = []

    def __init__(self, path):
        self._path = path
        self._evmask = create_mask(get_mask_length(Bits.EV_MAX))
        self._absmask = create_mask(get_mask_length(Bits.ABS_MAX))
        self._relmask = create_mask(get_mask_length(Bits.REL_MAX))
        self._keymask = create_mask(get_mask_length(Bits.KEY_MAX))

    def path(self):
        return _path

    def name(self):
        name_path = os.path.join(self._path,"device/name")
        name = ""
        if os.path.exists(name_path):
            try:
                f = open(name_path, 'r')
                name = f.read()
                f.close()
            except Exception, e:
                logging.error("Unable to get name for %s" % self._path)
            return name.rstrip()

    def dev_path(self):
        return os.path.join("/dev/input",os.path.basename(self._path))

    # algorithm from test_key() in udev-builtin-input_id.c in udev
    def is_keyboard(self):
        # do we have any KEY_ capability?
        if self._evmask[Bits.EV_KEY] is False:
            return False

        # bit 0 should be false (KEY_RESERVED), bits 1-31 should all be true
        if self._keymask[0] is False:
            for i in range(1,32):
                if self._keymask[i] is False:
                    return False
            return True

        else:
            return False


    # algorithm from test_pointers() in udev-builtin-input_id.c in udev
    def is_mouse(self):
        if self._keymask[Bits.BTN_TOOL_FINGER]:
            logging.debug("found a touchpad, ignoring")
            return False
        if self._keymask[Bits.BTN_MOUSE]:
            # ABS stuff seems to be for VMWare's mouse according to comments
            # in the C code, leaving here in case
            if self._evmask[Bits.EV_ABS]:
                if self._absmask[Bits.ABS_X] and self._absmask[Bits.ABS_Y]:
                    return True
            # for a real actual mouse
            if self._evmask[Bits.EV_REL]:
                if self._relmask[Bits.REL_X] and self._relmask[Bits.REL_Y]:
                    return True
        return False

    #check for touchpads
    def is_touchpad(self):
        if self._evmask[Bits.EV_ABS] and self._keymask[Bits.BTN_TOOL_FINGER]\
            and self._absmask[Bits.ABS_X] and self._absmask[Bits.ABS_Y]:
                return True

    def _build_cap_mask(self, val, capname):
        if capname == 'ev':
            mask = self._evmask
        elif capname == 'rel':
            mask = self._relmask
        elif capname == 'abs':
            mask = self._absmask
        elif capname == 'key':
            mask = self._keymask
        # this shouldn't happen, here for sanity check
        else:
            mask = None

        vals = val.split()
        i = len(vals)-1
        j = 0
        # walk backwards due to endianness
        while i>=0:
            intval = int(vals[i], 16)
            set_mask(intval, j*WORD_SIZE, WORD_SIZE, mask)
            i -= 1
            j += 1

    def read_capabilities(self):
        """This should be called after you create the Device object so that
        the capabilities are read from /sys"""
        cap_dir = os.path.join(self._path,"device/capabilities")
        if os.path.isdir(cap_dir):
            try:
                caps = os.listdir(cap_dir)
                for cap in caps:
                    if cap in ['ev', 'abs', 'rel', 'key']:
                        cap_path = os.path.join(cap_dir, cap)
                        f = open(cap_path, 'r')
                        val = f.read().rstrip()
                        f.close()
                        self._build_cap_mask(val, cap)
            except Exception, e:
                logging.debug("Error when processing capabilities for %s,"\
                    "cap=%s" % (self._path, cap))

def scan():
    devices = []
    keyboards = []
    mice = []
    touchpads = []

    for f in os.listdir(SEARCH_DIR):
        if f.startswith('event'):
           d = Device(os.path.join(SEARCH_DIR,f))
           d.read_capabilities()
           devices.append(d)
        else:
            logging.debug("Skipping %s" + f)

    for device in devices:
        if device.is_mouse():
            logging.info("%s is a mouse (%s)" % (device.dev_path(),
                device.name()))
            mice.append(device)
        if device.is_keyboard():
            logging.info("%s is a keyboard (%s)" % (device.dev_path(),
                device.name()))
            keyboards.append(device)
        if device.is_touchpad():
            logging.info("%s is a touchpad (%s)" % (device.dev_path(),
                device.name()))
            touchpads.append(device)

if __name__ == "__main__":
    scan()
