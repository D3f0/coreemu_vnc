#!/usr/bin/env python2
# Copyright (c) Twisted Matrix Laboratories.
# See LICENSE for details.

"""
An example FTP server with minimal user authentication.
"""
import sys
from twisted.python import log

from twisted.protocols.ftp import FTPFactory, FTPRealm
from twisted.cred.portal import Portal
from twisted.cred.checkers import AllowAnonymousAccess, FilePasswordDB
from twisted.internet import reactor


log.startLogging(sys.stderr)

with open('/passwords.dat', 'w') as fp:
    fp.write('root:root')

p = Portal(FTPRealm('/root'),
           [AllowAnonymousAccess(), FilePasswordDB("/passwords.dat")])

f = FTPFactory(p)

reactor.listenTCP(2121, f)
reactor.run()