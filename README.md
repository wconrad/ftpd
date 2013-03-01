# FTPD

ftpd is a pure Ruby FTP server library.  It supports implicit and
explicit TLS, passive and active mode, and most of the commands
specified in RFC 969.  It an be used as part of a test fixture or
embedded in a program.

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

Ftpd is not yet RFC compliant.  It does most of RFC969, and enough TLS
to get by.  {file:doc/rfc.md Here} is a list of RFCs, indicating how
much of each Ftpd complies with.

The DiskFileSystem class only works in Linux.  This is because it
shells out to the "ls" command.  This affects the example, which uses
the DiskFileSystem.

To bind the server to an external interface, the interface must be set
to the public IP of that interface (e.g. "1.2.3.4"), not to "0.0.0.0".
That's because the interface IP is used both for binding server ports,
_and_ for advertising to the client which IP to connect to.  Binding
to 0.0.0.0 will work fine, but when the client tries to connect to
0.0.0.0, it won't get to the server.

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
