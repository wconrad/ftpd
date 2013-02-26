### dev

API changes

* Introduced PermanentFileSystemError and TransientFileSystemError exceptions.
* Deprecated FileSystemError (use PermanentFileSystemError instead).
* DiskFileSystem errors generate 550 responses, not 450

Enhancements

* Support MKD and XMKD (make directory)
* Support RMD and XRMD (remove directory)
* Support RNFR/RNTO (rename/move file/directory)
* Support XCUP (alias for CDUP)
* Test implicit TLS

Bug Fixes

* Passive mode transfers bind to the correct interface.  They were
  erroneously binding to the local interface, which kept passive mode
  transfers from working when the client was on another machine.
* CDUP responds with syntax error if given an argument.

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
