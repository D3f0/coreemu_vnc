#!/usr/bin/env python2
from __future__ import print_function
from subprocess import check_call
from time import sleep
import os
import atexit
import sys
from functools import partial
stderr = partial(print, file=sys.stderr)

DISPLAY = os.environ.get("DISPLAY", ":1")

check_call('nc -v -z localhost 5901 ||'
           'rm -rf /tmp/.X*', shell=True)

def exit(*args):
    check_call("tightvncserver -kill :1 || true ", shell=True)
atexit.register(exit)

output = check_call('tightvncserver :1 {}'.format(DISPLAY).split())

print(output, file=sys.stderr)


while True:
    sleep(1)