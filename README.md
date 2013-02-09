= FTPD

ftpd is a pure Ruby FTP server library.  It supports implicit and
explicit TLS.

== UNFINISHED

I created ftpd to support the test framework I wrote for Databill,
LLC, whcih has given its kind permission to donate it to the
community.

I've moved the code from Databill's source tree, but it's not ready
for prime time yet.  It needs pluggable authentication and file system
drivers, refactoring, and the removal of bits of the Databill source
tree which are temporarily included.

== LIMITATIONS

TLS is only supported in passive mode, not active.  Either the FTPS
client used by the test doesn't work in active mode, or this server
doesn't work in FTPS active mode (or both).

== WHOAMI

Wayne Conrad <wconrad@yagni.com>

== CREDITS

Thanks to Databill, LLC, which supported the creation of this library,
and granted permission to donate it ot the community.
