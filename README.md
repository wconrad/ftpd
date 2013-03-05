# FTPD

ftpd is a pure Ruby FTP server library.  It supports implicit and
explicit TLS, passive and active mode, and most of the commands
specified in RFC 969.  It an be used as part of a test fixture or
embedded in a program.

## A note about this README

This readme, and the other files, contains Yardoc markup, especially
for links to the API docs.  You'll find a properly rendered version
{http://rubydoc.info/gems/ftpd on rubydoc.info}

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

There is no base class for a driver.  Any object that quacks like a
driver will do.  Here are the methods your driver needs:

* {Example::Driver#authenticate authenticate}
* {Example::Driver#file_system file_system}

## FILE SYSTEM

The file system object that the driver supplies to Ftpd is Ftpd's
gateway to the logical file system.  Ftpd doesn't know or care whether
it's serving files from disk, memory, or any other means.

The file system can be very minimal.  If the file system is missing
certain methods, the server simply disables the commands which need
that method.  For example, if there is no write method, then STOR is
not supported and causes a "502 Command not implemented" response to
the client.

The canonical and commented example of an Ftpd file system is
{Ftpd::DiskFileSystem}.  You can use it as a template for creating
your own, and its comments are the official specification for an Ftpd
file system.

Here are the methods a file system may expose:

* {Ftpd::DiskFileSystem::Accessors#accessible? accessible?}
* {Ftpd::DiskFileSystem::Accessors#exists? exists?}
* {Ftpd::DiskFileSystem::Accessors#directory? directory?}
* {Ftpd::DiskFileSystem::Write#write write}
* {Ftpd::DiskFileSystem::Mkdir#mkdir mkdir}
* {Ftpd::DiskFileSystem::Rmdir#rmdir rmdir}
* {Ftpd::DiskFileSystem::List#file_info file_info}
* {Ftpd::DiskFileSystem::List#dir dir}
* {Ftpd::DiskFileSystem::Rename#rename rename}

### DiskFileSystem

Ftpd includes a disk based file system:

    class Driver

      ...

      def file_system(user)
        Ftpd::DiskFileSystem.new('/var/lib/ftp')
      end

    end

*Warning*: The DiskFileSystem allows file and directory modification
including writing, renaming, deleting, etc.  If you want a read-only
file system, then use {Ftpd::ReadOnlyDiskFileSystem} instead.

The DiskFileSystem is composed out of modules:

* {Ftpd::DiskFileSystem::Base Base} - You will need this
* {Ftpd::DiskFileSystem::Delete Delete} - File deletion
* {Ftpd::DiskFileSystem::List List} - Directory listing
* {Ftpd::DiskFileSystem::Mkdir Mkdir} - Directory creation
* {Ftpd::DiskFileSystem::Read Read} - File reading
* {Ftpd::DiskFileSystem::Rename Rename} - File renaming
* {Ftpd::DiskFileSystem::Rmdir Rmdir} - Directory removal
* {Ftpd::DiskFileSystem::Write Write} - File writing

For example, to create a custom file system that allows reading and
writing only, then:

    class CustomDiskFileSystem
      include DiskFileSystem::Base
      include DiskFileSystem::List
      include DiskFileSystem::Read
      include DiskFileSystem::Write
    end

    class Driver

      ...

      def file_system(user)
        CustomDiskFileSystem('/var/lib/ftp')
      end

    end

## LIST output format

By default, the LIST command uses Unix "ls -l" formatting:

    -rw-r--r-- 1 user     group        1234 Mar  3 08:38 foo

To switch to
{http://cr.yp.to/ftp/list/eplf.html Easily Parsed LIST format (EPLF)}
format:

    ftp_server.list_formatter = Ftpd::ListFormat::Eplf

To create your own custom formatter, create a class with these
methods:

* {Ftpd::ListFormat::Ls#initialize initialize}
* {Ftpd::ListFormat::Ls#to_s to_s}

And register your class with the ftp_server before starting it:

    ftp_server.list_formatter = MyListFormatter

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

Ftpd is not fully RFC compliant.  It does most of RFC969, and enough
TLS to get by.  {file:doc/rfc.md Here} is a list of RFCs, indicating
how much of each Ftpd complies with.

RFC does not meet the following The following 
[RFC-1123](http://tools.ietf.org/rfc/rfc1123.txt)
"MUST" requrements.  If FTPD met these requirements, it would be
"conditionally compliant":

* Server-FTP handle Telnet options
* Support TYPE "LOCAL 8"
* Support command APPE
* Support command STAT

RFC does not meet the following The following 
[RFC-1123](http://tools.ietf.org/rfc/rfc1123.txt)
"SHOULD" requrements.  If FTPD met both the "MUST" and the "SHOULD"
requirements, it would be "unconditionally compliant":

* Implement TYPE T if same as TYPE N
* Idle timeout in server-FTP
* Configurable idle timeout
* Support TYPE ASCII - Telent (AT)

## RUBY COMPATABILITY

The tests pass with these Rubies:

* ruby-1.8.7-p371
* ruby-1.9.3-p392
* ruby-2.0.0-p0

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

## ORIGIN

I created ftpd to support the test framework I wrote for Databill,
LLC, which has given its kind permission to donate it to the
community.

## WHOAMI

Wayne Conrad <wconrad@yagni.com>

## CREDITS

Thanks to Databill, LLC, which supported the creation of this library,
and granted permission to donate it to the community.

## See also

* {file:Changelog.md}
* {file:doc/rfc-compliance.md RFC compliance}
* {file:doc/references.md}
