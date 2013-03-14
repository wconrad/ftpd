# REFERENCES

## RFCs

_This list of references comes from the README of the em-ftpd gem,
which is licensed under the same MIT license as this gem, and is
Copyright (c) 2008 James Healy_

There are a range of RFCs that together specify the FTP protocol. In
chronological order, the more useful ones are:

* [RFC-854](http://tools.ietf.org/rfc/rfc854.txt) - Telnet Protocol
  Specification

* [RFC-959](http://tools.ietf.org/rfc/rfc959.txt) - File Transfer
  Protocol

* [RFC-1123](http://tools.ietf.org/rfc/rfc1123.txt) - Requirements for
  Internet Hosts

* [RFC-1143](http://tools.ietf.org/rfc/rfc1143.txt) - The Q Method of
  Implementing TELNET Option Negotation

* [RFC-2228](http://tools.ietf.org/rfc/rfc2228.txt) - FTP Security
  Extensions

* [RFC-2389](http://tools.ietf.org/rfc/rfc2389.txt) - Feature
  negotiation mechanism for the File Transfer Protocol

* [RFC-2428](http://tools.ietf.org/rfc/rfc2428.txt) - FTP Extensions
  for IPv6 and NATs

* [RFC-2577](http://tools.ietf.org/rfc/rfc2577.txt) - FTP Security
  Considerations

* [RFC-2640](http://tools.ietf.org/rfc/rfc2640.txt) -
  Internationalization of the File Transfer Protocol

* [RFC-3659](http://tools.ietf.org/rfc/rfc3659.txt) - Extensions to
  FTP

* [RFC-4217](http://tools.ietf.org/rfc/rfc4217.txt) -
  Securing FTP with TLS

For an english summary that's somewhat more legible than the RFCs, and
provides some commentary on what features are actually useful or
relevant 24 years after RFC959 was published:

* <http://cr.yp.to/ftp.html>

For a history lesson, check out Appendix III of RCF959. It lists the
preceding (obsolete) RFC documents that relate to file transfers,
including the ye old RFC114 from 1971, "A File Transfer Protocol"

There is a [public test server](http://secureftp-test.com) which is
very handy for checking out clients, and seeing how at least one
server behaves.

## How to reliably close a socket (and not lose data)

[Why is my TCP not reliable](http://ia600609.us.archive.org/22/items/TheUltimateSo_lingerPageOrWhyIsMyTcpNotReliable/the-ultimate-so_linger-page-or-why-is-my-tcp-not-reliable.html) by Bert Hubert

## LIST output format

* [GNU docs for ls](http://www.gnu.org/software/coreutils/manual/html_node/What-information-is-listed.html#What-information-is-listed)
* [Easily Parsed LIST format (EPLF)](http://cr.yp.to/ftp/list/eplf.html)
