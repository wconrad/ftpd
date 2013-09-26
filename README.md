# Ftpd

ftpd is a pure Ruby FTP server library.  It supports implicit and
explicit TLS, passive and active mode, and is unconditionally
compliant per [RFC-1123][1].  It an be used as part of a test fixture or
embedded in a program.

## A note about this README

This readme, and other files, contains Yardoc markup, especially for
links to the API docs; those links don't display properly on github.
You'll find a properly rendered version [on
rubydoc.info](http://rubydoc.info/gems/ftpd)

## The state of this library

Ftpd has been used for many years to test FTP clients, and is stable
and reliable for that purpose.  However, it was not originally
intended to be part of a publically accessible FTP server.  I would be
cautious in using it in an untrusted environment due to the
probability that it contains critical flaws (or even security
vulnarabilities) that have not been discovered in its use as a test
harness.

In this 0.X.X release, the API is changing at least a little with
almost every release.  If you need to keep those changes from
impacting you (or at least want to let many of them build up before
you have to deal with them), then lock your Gemfile down to a minor
release (e.g. :version => '~> 0.5.0').

Ftpd currently does not support IPV6 and therefore you are urged to
ensure binding the server interface as `server.interface = '127.0.0.1'`.

## Hello World

This is examples/hello_world.rb, a bare minimum FTP server.  It allows
any user/password, and serves files in a temporary directory.  It
binds to an ephemeral port on the local interface:

```ruby
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
  server.interface = '127.0.0.1'
  server.start
  puts "Server listening on port #{server.bound_port}"
  gets
end
```

A more full-featured example that allows TLS and takes options is in
examples/example.rb

## Driver

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

## File System

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
* {Ftpd::DiskFileSystem::Accessors#directory? directory?}
* {Ftpd::DiskFileSystem::Accessors#exists? exists?}
* {Ftpd::DiskFileSystem::Append#append append}
* {Ftpd::DiskFileSystem::Delete#delete delete}
* {Ftpd::DiskFileSystem::List#dir dir}
* {Ftpd::DiskFileSystem::List#file_info file_info}
* {Ftpd::DiskFileSystem::Mkdir#mkdir mkdir}
* {Ftpd::DiskFileSystem::Read#read read}
* {Ftpd::DiskFileSystem::Rename#rename rename}
* {Ftpd::DiskFileSystem::Rmdir#rmdir rmdir}
* {Ftpd::DiskFileSystem::Write#write write}

### DiskFileSystem

Ftpd includes a disk based file system:

```ruby
class Driver

  ...

  def file_system(user)
    Ftpd::DiskFileSystem.new('/var/lib/ftp')
  end

end
```

**Warning**: The DiskFileSystem allows file and directory modification
including writing, renaming, deleting, etc.  If you want a read-only
file system, then use {Ftpd::ReadOnlyDiskFileSystem} instead.

The DiskFileSystem is composed out of modules:

* {Ftpd::DiskFileSystem::Base Base} - You will need this
* {Ftpd::DiskFileSystem::Append Append} - File appending
* {Ftpd::DiskFileSystem::Delete Delete} - File deletion
* {Ftpd::DiskFileSystem::List List} - Directory listing
* {Ftpd::DiskFileSystem::Mkdir Mkdir} - Directory creation
* {Ftpd::DiskFileSystem::Read Read} - File reading
* {Ftpd::DiskFileSystem::Rename Rename} - File renaming
* {Ftpd::DiskFileSystem::Rmdir Rmdir} - Directory removal
* {Ftpd::DiskFileSystem::Write Write} - File writing

You can use these modules to create a custom disk file system that
allows only the operations you want, or which mixes the predefined
modules with your customizations, as in this silly example that allows
uploads but then throws them away.

```ruby
class BlackHole
  def write(ftp_path, contents)
  end
end

class CustomDiskFileSystem
  include DiskFileSystem::Base
  include DiskFileSystem::Read
  include BlackHole
end
```

## Configuration

Configuration is done via accessors on {Ftpd::FtpServer}.  For
example, to set the session timeout to 10 minutes:

```ruby
server = Ftpd::FtpServer.new(driver)
server.session_timeout = 10 * 60
server.interface = '127.0.0.1'
server.start
```

You can set any of these attributes before starting the server:

* {Ftpd::FtpServer#allow_low_data_ports}
* {Ftpd::FtpServer#auth_level}
* {Ftpd::FtpServer#failed_login_delay}
* {Ftpd::FtpServer#list_formatter}
* {Ftpd::FtpServer#log}
* {Ftpd::FtpServer#max_connections_per_ip}
* {Ftpd::FtpServer#max_connections}
* {Ftpd::FtpServer#max_failed_logins}
* {Ftpd::FtpServer#response_delay}
* {Ftpd::FtpServer#server_name}
* {Ftpd::FtpServer#server_version}
* {Ftpd::FtpServer#session_timeout}
* {Ftpd::Server#interface}
* {Ftpd::Server#port}
* {Ftpd::TlsServer#certfile_path}
* {Ftpd::TlsServer#tls}

### LIST output format

By default, the LIST command uses Unix "ls -l" formatting:

    -rw-r--r-- 1 user     group        1234 Mar  3 08:38 foo

An alternative to "ls -l" formatting is [Easily Parsed LIST format
(EPLF)](http://cr.yp.to/ftp/list/eplf.html) format:

    +r,s1234,m1362325080\tfoo

to configure Ftpd for EPLF formatting:

    ftp_server.list_formatter = Ftpd::ListFormat::Eplf

To create your own custom formatter, create a class with these
methods:

* {Ftpd::ListFormat::Ls#initialize initialize}
* {Ftpd::ListFormat::Ls#to_s to_s}

And register your class with the ftp_server before starting it:

    ftp_server.list_formatter = MyListFormatter

### Logging

Ftpd can write to an instance of
{http://www.ruby-doc.org/stdlib-2.0.0/libdoc/logger/rdoc/Logger.html Logger} that you provide.  To log to standard out:

    server.log = Logger.new($stdout)

To log to a file:

    server.log = Logger.new('/tmp/ftpd.log')

## Standards Compliance

* Unconditionally compliant per [RFC-1123][1] (Requirements for
  Internet Hosts).

* Implements all of the security recommendations in
  [RFC-2577](http://tools.ietf.org/rfc/rfc2577.txt) (FTP Security
  Considerations).

* Implements [RFC-2389](http://tools.ietf.org/rfc/rfc2389.txt)
  (Feature negotiation mechanism for the File Transfer Protocol)

* Implements enough of
  [RFC-4217](http://tools.ietf.org/rfc/rfc4217.txt) (Securing FTP with
  TLS) to get by.

See [RFC Compliance](doc/rfc-compliance.md) for details

## Ruby Compatability

The tests pass with these Rubies:

* ruby-1.8.7-p371
* ruby-1.9.3-p392
* ruby-2.0.0-p0

For Ruby 1.8, use an ftpd version before 0.8.  In your Gemfile:

    gem 'ftpd', '<0.8'

## Development

### Tests

To run the cucumber (functional) tests:

    $ rake test:features

To run the rspec (unit) tests:

    $ rake test:spec

To run all tests:

    $ rake test

or just:

    $ rake

To force features to write the server log to stdout:

    $ FTPD_DEBUG=1 rake test:features

### Example

The stand-alone example is good for manually testing Ftpd with any FTP
client.  To run the stand-alone example:

    $ examples/example.rb

The example prints its port, username and password to the console.
You can connect to the stand-alone example with any FTP client.

example.rb has many options.  To see them:

    $ examples/example.rb -h

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Origin

I created ftpd to support the test framework I wrote for Databill,
LLC, which has given its kind permission to donate it to the
community.

## Whoami

Wayne Conrad <wconrad@yagni.com>

## Credits

Thanks to Databill, LLC, which supported the creation of this library,
and granted permission to donate it to the community.

## See also

* [Changelog](Changelog.md)
* [RFC compliance](doc/rfc-compliance.md)
* [References](doc/references.md)
* [Benchmarks](doc/benchmarks.md)

[1]: http://tools.ietf.org/rfc/rfc1123.txt
