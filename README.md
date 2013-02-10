# FTPD

ftpd is a pure Ruby FTP server library.  It supports implicit and
explicit TLS, suitlble for use by a program such as a test fixture or
FTP daemon.

## UNFINISHED

I created ftpd to support the test framework I wrote for Databill,
LLC, which has given its kind permission to donate it to the
community.

I've moved the code from Databill's source tree, but it's not ready
for prime time yet.  It needs pluggable authentication and file system
drivers, refactoring, and the removal of bits of the Databill source
tree which are temporarily included.

## LIMITATIONS

TLS is only supported in passive mode, not active.  Either the FTPS
client used by the test doesn't work in active mode, or this server
doesn't work in FTPS active mode (or both).

## REFERENCES

(This list of references comes from the README of the em-ftpd gem,
which is licensed under the same MIT license as this gem, and is
Copyright (c) 2008 James Healy)

There are a range of RFCs that together specify the FTP protocol. In
chronological order, the more useful ones are:

    http://tools.ietf.org/rfc/rfc959.txt
    http://tools.ietf.org/rfc/rfc1123.txt
    http://tools.ietf.org/rfc/rfc2228.txt
    http://tools.ietf.org/rfc/rfc2389.txt
    http://tools.ietf.org/rfc/rfc2428.txt
    http://tools.ietf.org/rfc/rfc3659.txt
    http://tools.ietf.org/rfc/rfc4217.txt

For an english summary that's somewhat more legible than the RFCs, and
provides some commentary on what features are actually useful or
relevant 24 years after RFC959 was published:

    http://cr.yp.to/ftp.html

For a history lesson, check out Appendix III of RCF959. It lists the
preceding (obsolete) RFC documents that relate to file transfers,
including the ye old RFC114 from 1971, "A File Transfer Protocol"

## WHOAMI

Wayne Conrad <wconrad@yagni.com>

## CREDITS

Thanks to Databill, LLC, which supported the creation of this library,
and granted permission to donate it ot the community.
