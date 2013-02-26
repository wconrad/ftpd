# FTPD

ftpd is a pure Ruby FTP server library.  It supports implicit and
explicit TLS, and can be used as part of a test fixture or to embed in
another program.

## HELLO WORLD

This is examples/hello_world.rb, a bare minimum FTP server.  It allows
any user/password, and serves files in a temporary directory.  It
binds to an ephemeral port on the local interface:

    require 'ftpd'
    require 'tmpdir'

    class Driver

      def initialize(temp_dir)
        @temp_dir = temp_dir
      end

      def authenticate(user, password)
        true
      end

      def file_system(user)
        Ftpd::DiskFileSystem.new(@temp_dir)
      end

    end

    Dir.mktmpdir do |temp_dir|
      driver = Driver.new(temp_dir)
      server = Ftpd::FtpServer.new(driver)
      server.start
      puts "Server listening on port #{server.bound_port}"
      gets
    end

A more full-featured example that allows TLS and takes options is in
examples/example.rb

## DRIVER

Ftpd's dynamic behavior such as authentication and file retrieval is
controlled by a driver that you supply.  The Driver class in the
"hello world" example above shows a rudimentary driver.  Ftpd calls
the authenticate method to decide who can log in.  Once someone is
logged on, it calls the file_system method to obtain a file system
driver for that user.

There is no base class for a driver.  Any class with that signature
will do.

## FILE SYSTEM

The file system object that the driver supplies to Ftpd is Ftpds
gateway to the logical file system.  Ftpd doesn't know or care whether
it's serving files from disk, memory, or any other means.

The file system can be very minimal.  If the file system is missing
certain methods, the server simply disables the commands which need
that method.  For example, if there is no write method, then STOR is
not supported and causes a "502 Command not implemented" response to
the client.

The canonical and commented example of an Ftpd file system is
Ftpd::DiskFileSystem.

## DEBUGGING

Ftpd can write debugging information (essentially a transcript of its
conversation with a client) to a file.  If you turn the debug flag on,
the server will write debug information to stdout:

    server = Ftpd::FtpServer.new(driver)
    server.debug = true

If you want to send the debug output to somewhere else, set
debug_path:

    server.debug_path = '/tmp/ftp_session'

Debug output can also be enabled by setting the environment variable
FTPD_DEBUG to a non-zero value.  This is a convenient way to get debug
output without having to change any code.

## LIMITATIONS

TLS is only supported in passive mode, not active, but I don't know
why.  Either the FTPS client used by the test doesn't work in active
mode, or this server doesn't work in FTPS active mode (or both).

The DiskFileSystem class only works in Linux.  This is because it
shells out to the "ls" command.  This affects the example, which uses
the DiskFileSystem.

The control connection is supposed to be a Telnet session.  It's not.
In practice, it doesn't seem to matter whether it's a Telnet session
or just plain sending and receiving characters.

The following commands defined by RFC969 are understood, but not
implemented.  They result in a "502 Command not implemented" response.

* ABOR - Abort
* ACCT - Account
* APPE - Append (with create)
* HELP - Help
* REIN - Reinitialize
* REST - Restart
* RNFR - Rename from
* RNTO - Rename to
* SITE - Site parameters
* SMNT - Structure mount
* STAT - Status
* STOU - Store Unique

## DEVELOPMENT

### TESTS

To run the cucumber (functional) tests:

    $ rake test:features

To run the rspec (unit) tests:

    $ rake test:spec

To run all tests:

    $ rake test

or just:

    $ rake

To run the stand-alone example:

    $ examples/example.rb

The example prints its port, username and password to the console.
You can connect to the stand-alone example with any FTP client.  This
is useful when testing how the server responds to a given FTP client.

## REFERENCES

(This list of references comes from the README of the em-ftpd gem,
which is licensed under the same MIT license as this gem, and is
Copyright (c) 2008 James Healy)

There are a range of RFCs that together specify the FTP protocol. In
chronological order, the more useful ones are:

* <http://tools.ietf.org/rfc/rfc959.txt>
* <http://tools.ietf.org/rfc/rfc1123.txt>
* <http://tools.ietf.org/rfc/rfc2228.txt>
* <http://tools.ietf.org/rfc/rfc2389.txt>
* <http://tools.ietf.org/rfc/rfc2428.txt>
* <http://tools.ietf.org/rfc/rfc3659.txt>
* <http://tools.ietf.org/rfc/rfc4217.txt>

For an english summary that's somewhat more legible than the RFCs, and
provides some commentary on what features are actually useful or
relevant 24 years after RFC959 was published:

* <http://cr.yp.to/ftp.html>

For a history lesson, check out Appendix III of RCF959. It lists the
preceding (obsolete) RFC documents that relate to file transfers,
including the ye old RFC114 from 1971, "A File Transfer Protocol"

## ORIGIN

I created ftpd to support the test framework I wrote for Databill,
LLC, which has given its kind permission to donate it to the
community.

## WHOAMI

Wayne Conrad <wconrad@yagni.com>

## CREDITS

Thanks to Databill, LLC, which supported the creation of this library,
and granted permission to donate it to the community.
