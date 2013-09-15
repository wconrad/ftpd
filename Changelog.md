This is the changelog for the Ruby 1.8.7 branch (version 0.7) of ftpd.
For later version of Ruby, please use ftpd version >= 0.8.

### 0.7.1

* Upgrade gems to latest version that work with Ruby 1.8.7
* Separate Ruby 1.8 branch

### 0.7.0

Bug fixes

* Gracefully handle Errno::ENOTCONN during socket shutdown (fixes
  gh-1)

### 0.6.0

Enhancements

* Configurable maximum connections (defaults to unlimited).
* Configurable maximum connections per IP (defaults to unlimited).
* Configurable disconnect after too many failed login attempts
  (defaults to unlimited)
* Delay after failed login (configurable).

API Changes

* Changes to {Ftpd::FtpServer} attributes should now only be made
  before calling #start.  The effect of setting these attributes
  after #start is undefined.
* Added {Ftpd::FtpServer#max_connections}
* Added {Ftpd::FtpServer#max_connections_per_ip}
* Added {Ftpd::FtpServer#max_failed_logins}
* Added {Ftpd::FtpServer#failed_login_delay}
* Support FEAT (feature list)
* Support OPTS (set options)

### 0.5.0

Bug fixes

* Replies are sent with the correct line ending ("\r\n" instead of
  "\n")
* Do not hang on out-of-band commands.
* When data connection disconnects, send "426 Connection closed"
  response instead of ending the session.

Enhancements

* Now unconditionally compliant
* Configurable session timeout (see {Ftpd::FtpServer#session_timeout}).
  Defaults to 5 minutes.
* Disable Nagle algorithm on control connection to decrease latency.
  This makes the tests run much faster.
* Support STAT (server status).
* Example has --timeout option for session idle timeout.
* Write log to Logger (see {Ftpd::FtpServer#log}).
* Disallow active-mode connections to privileged ports (configurable).
  See RFC 2577 section 3.
* Added benchmarks.
* Support telnet sequences.

API Changes

* Added {Ftpd::FtpServer#server_name}
* Added {Ftpd::FtpServer#server_version}
* Removed #debug and #debug_path from Ftpd::FtpServer.  They have been
  replaced with #log
# Added {Ftpd::FtpServer#allow_low_data_ports}

### 0.4.0

Enhancements

* Improved driver and file-system documentation.
* Added {Ftpd::ReadOnlyDiskFileSystem read only disk file system}
* Example can be run with a read-only file system
* Supports three different levels of authentication:
  * User
  * User + Password
  * User + Password + Account
* Added --auth switch to the example to select the authentication
  level.
* Support APPE
* Support TYPE "A T" (ASCII/Telnet)
* Support TYPE "LOCAL 8"
* Added switches to example to set authentication values
  * --user
  * --password
  * --account

API changes

* {Example::Driver#authenticate authenticate} now takes three
  parameters (user, password, account).  For compatability, it can be
  defined to take only two, provided you are not doing account
  authentication.
* Added {Ftpd::FtpServer#auth_level} option
* Added {Ftpd::DiskFileSystem::Append}

### 0.3.1

API changes

The file system interface for directory listing was completely
rewritten.  It no longer shells out to ls, which removes potential
command injection security holes, and improves prospects for
portability.

* Removed Ftpd::DiskFileSystem::Ls
* Removed Ftpd::DiskFileSystem::NameList.  NLIST now uses the
  functions in {Ftpd::DiskFileSystem::List}.
* Removed Ftpd::DiskFileSystem::List#list.  The formatting of
  directory output is now done by ftpd, not by the file system driver.
* Added {Ftpd::DiskFileSystem::List#file_info}, used by LIST.
* Added {Ftpd::DiskFileSystem::List#dir}, used by LIST and NLST.

Bug fixes

* LIST and NLST support globs again.
* STOU (store unique) works in Ruby 1.8.7

Enhancements

* The output of the "LIST" command can be customized (see
  {Ftpd::FtpServer#list_formatter})

### 0.2.2

Bug fixes

* Respond with sequence error if RNFR is not immediately followed by
  RNTO
* Respond with sequence error if USER is not immediately followed by
  PASS
* Open PASV mode data connection on same local IP as control connection.
  This is required by RFC 1123.
* Disabled globbing in LIST (for now) due to a command (shell)
  injection vulnerability.  This patch also disables globbing in NLST,
  but NLST probably shouldn't do globbing.  Thanks to Larry Cashdollar
  for the report.

Enhancements

* Support STOU (store unique)
* Support HELP

### 0.2.1

API changes

* Introduced PermanentFileSystemError and TransientFileSystemError exceptions.
* Deprecated FileSystemError (use PermanentFileSystemError instead).
* DiskFileSystem errors generate 550 responses, not 450

Enhancements

* Support MKD and XMKD (make directory)
* Support RMD and XRMD (remove directory)
* Support RNFR/RNTO (rename/move file/directory)
* Support XCUP (alias for CDUP)
* Support XPWD (alias for PWD)
* Support XCWD (alias for CWD)
* Test implicit TLS

Bug Fixes

* Passive mode transfers bind to the correct interface.  They were
  erroneously binding to the local interface, which kept passive mode
  transfers from working when the client was on another machine.
* CDUP responds with syntax error if given an argument.
* RNTO checks that RNFM was called.
* Tests pass in Ruby 2.0.

### 0.2.0

API changes

* Renamed two of the file system methods:

  * `list_long -> long`
  * `list_short -> short`

  This will affect anyone who has written their own disk system.
  Anyone using Ftpd::DiskFileSystem won't notice this change.

Enhancements

* Some commands are now optional, depending upon the file system.
  These are RETR, DELE, LIST and NLST.  See the comments in
  Ftpd::DiskFileSystem for what command depends upon what method.
* Better text in example's ephemeral README
* Divided the DiskFileSystem into mixins.
* Improved documentation.
* Support SYST
* Support ALLO
* Removed dead code
* Added more tests

### 0.1.1

Enhancements

* Improved documentation.
* Gemfile: development gems no longer lock down version

### 0.1.0

First usable release
