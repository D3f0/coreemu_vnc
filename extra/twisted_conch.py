#!/usr/bin/env python2
from zope.interface import implements

from twisted.application import service, internet
from twisted.conch.ssh.keys import Key
from twisted.conch.ssh.factory import SSHFactory
from twisted.conch.unix import UnixSSHRealm
from twisted.cred.checkers import ICredentialsChecker
from twisted.cred.credentials import IUsernamePassword
from twisted.cred.portal import Portal
import posixpath

def get_key(path):
    path = posixpath.expanduser(path)
    return Key.fromString(data=open(path).read())


class DummyChecker(object):
    credentialInterfaces = (IUsernamePassword,)
    implements(ICredentialsChecker)

    def requestAvatarId(self, credentials):
        return credentials.username


def makeService():
    public_key = get_key('~/.ssh/id_rsa.pub')
    private_key = get_key('~/.ssh/id_rsa')

    factory = SSHFactory()
    factory.privateKeys = {'ssh-rsa': private_key}
    factory.publicKeys = {'ssh-rsa': public_key}
    factory.portal = Portal(UnixSSHRealm())
    factory.portal.registerChecker(DummyChecker())

    return internet.TCPServer(22, factory)


application = service.Application("sftp server")
sftp_server = makeService()
sftp_server.setServiceParent(application)

from twisted.internet import reactor

reactor.run()