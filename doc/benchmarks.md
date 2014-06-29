# Benchmarks

Benchmarks using pyftpd's benchmark script and
[procedures](http://code.google.com/p/pyftpdlib/wiki/Benchmarks).

## Results

### ftpd 0.17.0

    (starting with 14.9M of memory being used)
    STOR (client -> server)                              120.75 MB/sec  14.9M
    RETR (server -> client)                              741.77 MB/sec  22.7M
    200 concurrent clients (connect, login)                0.20 secs    19.2M
    STOR (1 file with 200 idle clients)                  144.77 MB/sec  19.2M
    RETR (1 file with 200 idle clients)                  542.86 MB/sec  27.1M
    200 concurrent clients (RETR 10.0M file)               6.38 secs    32.1M
    200 concurrent clients (STOR 10.0M file)               2.76 secs    21.7M
    200 concurrent clients (QUIT)                          0.03 secs

### pyftpd 1.4.0

    (starting with 4.2M of memory being used)
    STOR (client -> server)                              127.62 MB/sec  4.2M
    RETR (server -> client)                             1170.82 MB/sec  4.3M
    200 concurrent clients (connect, login)                2.53 secs    4.8M
    STOR (1 file with 200 idle clients)                  113.38 MB/sec  4.9M
    RETR (1 file with 200 idle clients)                 1139.89 MB/sec  4.9M
    200 concurrent clients (RETR 10.0M file)               2.55 secs    5.6M
    200 concurrent clients (STOR 10.0M file)               2.03 secs    5.7M
    200 concurrent clients (QUIT)                          0.02 secs

### proftpd 1.3.5rc4

    (starting with 1.4M of memory being used)
    STOR (client -> server)                              117.59 MB/sec  3.2M
    RETR (server -> client)                             1318.32 MB/sec  3.2M
    200 concurrent clients (connect, login)               12.20 secs    366.4M
    STOR (1 file with 200 idle clients)                  123.82 MB/sec  368.3M
    RETR (1 file with 200 idle clients)                 1302.86 MB/sec  368.3M
    200 concurrent clients (RETR 10.0M file)               2.33 secs    366.4M
    200 concurrent clients (STOR 10.0M file)               2.76 secs    366.4M
    200 concurrent clients (QUIT)                          0.00 secs

### Notes

* Ftpd's fast time on the login test, compared to proftpd and
  pyftpdlib, is probably a result of it not doing PAM authentication
  whereas the other ftpd servers are.  It is not an apples-to-apples
  comparison.

* The only benchmark for which ftpd beats the competition is the
  single-client STOR.

## Setup

### Machine

* Intel(R) Core(TM) i5-2500 CPU @ 3.30GHz (4 cores)
* Python 3.4.1rc1
* pyftpd 1.4.0
* ruby 2.1.1p76 (2014-02-24 revision 45161) [i686-linux]
* Linux 3.0.0-1-686-pae #1 SMP Sat Aug 27 16:41:03 UTC 2011 i686 GNU/Linux

### Benchmark command

bench.py needs psutil.  Under Debian, install _python-psutil_.

    pyftpdlib-1.0.1/test$ python3 bench.py  -u <USER> -p <PASS> -H localhost -P <PORT> -b all -n 200 -k <PID>

### Proftpd

/etc/proftpd/proftpd.conf:

    MaxInstances        2000

### Ftpd

    $ bundle exec examples/example.rb -p 2222 -U bench -P bench

### Pyftpd

    pyftpdlib-1.4.0/demo$ sudo python ./unix_daemon.py 2>/dev/null
