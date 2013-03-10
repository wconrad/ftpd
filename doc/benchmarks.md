# Benchmarks

Benchmarks using pyftpd's [benchmark
script](http://pyftpdlib.googlecode.com/svn/trunk/test/bench.py) and
[procedures](http://code.google.com/p/pyftpdlib/wiki/Benchmarks).

## Results

### ftpd 0.4.0

    (starting with 13.6M of RSS memory being used)
    STOR (client -> server)                              845.55 MB/sec  13.6M RSS
    RETR (server -> client)                             1234.80 MB/sec  859.5M RSS
    200 concurrent clients (connect, login)                0.14 secs    863.0M RSS
    STOR (1 file with 200 idle clients)                  848.56 MB/sec  863.0M RSS
    RETR (1 file with 200 idle clients)                 1227.46 MB/sec  866.4M RSS
    200 concurrent clients (RETR 10.0M file)               5.36 secs    2.0G RSS
    200 concurrent clients (STOR 10.0M file)               4.65 secs    2.0G RSS
    200 concurrent clients (QUIT)                          0.01 secs

### pyftpdlib 1.0.1

    (starting with 8.9M of RSS memory being used)
    STOR (client -> server)                               81.73 MB/sec  8.9M RSS
    RETR (server -> client)                             1001.05 MB/sec  8.9M RSS
    200 concurrent clients (connect, login)                2.58 secs    9.6M RSS
    STOR (1 file with 200 idle clients)                  108.46 MB/sec  9.6M RSS
    RETR (1 file with 200 idle clients)                 1134.18 MB/sec  9.6M RSS
    200 concurrent clients (RETR 10.0M file)               2.32 secs    10.3M RSS
    200 concurrent clients (STOR 10.0M file)               4.12 secs    10.4M RSS
    200 concurrent clients (QUIT)                          0.02 secs

### proftpd 1.3.4a-3

    (starting with 2.3M of RSS memory being used)
    STOR (client -> server)                               93.06 MB/sec  6.6M RSS
    RETR (server -> client)                             1267.63 MB/sec  6.6M RSS
    200 concurrent clients (connect, login)               14.21 secs    868.0M RSS
    STOR (1 file with 200 idle clients)                   76.04 MB/sec  872.3M RSS
    RETR (1 file with 200 idle clients)                 1289.75 MB/sec  872.3M RSS
    200 concurrent clients (RETR 10.0M file)               2.04 secs    868.0M RSS
    200 concurrent clients (STOR 10.0M file)               4.51 secs    868.2M RSS
    200 concurrent clients (QUIT)                          0.00 secs

### Discussion

ftpd's STOR results seen anomalous.  I suspect that proftpd and
pyftpdlib aren't getting a fair shake here.  proftpd and pyftpdlib are
serving my home directory, whereas ftpd is serving a temporary
directory, but I don't know what difference that could make.

Ftpd is a memory hog.  During a STOR or RETR, it loads the entire
contents of a file into memory.  This limits the number of concurrent
file transfers it can handle.  The pyftpd team uses -n 300 (300
concurrent connections) when benchmarking, but Ftpd can't handle that
many at the moment.

Ftpd's fast time on the login test, compared to proftpd and pyftpdlib,
is a result of it not doing PAM authentication.  It is an unfair
comparison and should be disregarded.

pyftpd's memory footprint is impressive.

ftpd is less performant with many concurrent connections than either
proftpd or pyftpdlib.

## Setup

### Machine

* Intel(R) Core(TM) i5-2500 CPU @ 3.30GHz (4 cores)
* Python 2.7.3rc2 (default, Apr 22 2012, 22:35:38)
* ruby 2.0.0p0 (2013-02-24 revision 39474) [i686-linux]
* Linux 3.0.0-1-686-pae #1 SMP Sat Aug 27 16:41:03 UTC 2011 i686 GNU/Linux

### Benchmark command

    $ python bench.py  -u <USER> -p <PASS> -H localhost -p <PORT> -b all -n 200 -k <PID>

### Proftpd

/etc/proftpd/proftpd.conf:

    MaxInstances        2000

### Ftpd

    $ bundle exec examples/example.rb -p 2222 -U bench -P bench

### Pyftpd

    pyftpdlib-1.0.0/demo$ sudo python unix_daemon.py 2>/dev/null
