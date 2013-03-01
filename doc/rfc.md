# RFC compliance

This page documents FTPDs compliance (or not) with the RFCs that
define the FTP protocol.

This document is modeled after [this one from the pyftpdlib
wiki](http://code.google.com/p/pyftpdlib/wiki/RFCsCompliance).
pyftpdlib is what every FTP library wants to be when it grows up.

## RFC-959 - File Transfer Protocol

* Issued: October 1985
* Status: STANDARD
* Obsoletes: [RFC-765](http://tools.ietf.org/rfc/rfc765.txt)
* Updated by: 
 [RFC-1123](http://tools.ietf.org/rfc/rfc1123.txt)
 [RFC-2228](http://tools.ietf.org/rfc/rfc2228.txt)
 [RFC-2640](http://tools.ietf.org/rfc/rfc2640.txt)
 [RFC-2773](http://tools.ietf.org/rfc/rfc2773.txt)
* [link](http://tools.ietf.org/rfc/rfc959.txt)

Commands supported:

    ABOR    No      ---     Abort transfer
    ACCT    No      ---     Specify user's account
    ALLO    Yes    0.2.0    Allocate storage space
                            Treated as a NOOP
    APPE    No      ---     Append to file
    CDUP    Yes    0.1.0    Change to parent directory    
    CWD     Yes    0.1.0    Change working directory    
    DELE    Yes    0.1.0    Delete file    
    HELP    No      ---     Help
    LIST    Yes    0.1.0    List directory    
    MKD     Yes    0.2.1    Make directory    
    MODE    Yes    0.1.0    Set transfer mode
                            "Stream" mode supported; "Block" and
                            "Compressed" are not
    NLST    Yes    0.1.0    Name list    
    NOOP    Yes    0.1.0    No Operation    
    PASS    Yes    0.1.0    Set user password    
    PASV    Yes    0.1.0    Set passive mode    
    PORT    Yes    0.1.0    Set active mode    
    PWD     Yes    0.1.0    Print working directory    
    QUIT    Yes    0.1.0    Quit session    
    REIN    No      ---     Reinitialize session    
    REST    No      ---     Restart transfer    
    RETR    Yes    0.1.0    Retrieve file    
    RMD     Yes    0.2.1    Remove directory    
    RNFR    Yes    0.2.1    Rename file (from)    
    RNTO    Yes    0.2.1    Rename file (to)    
    SITE    No      ---     Site specific commands
    SMNT    No      ---     Structure Mount    
    STAT    No      ---     Server status    
    STOR    Yes    0.1.0    Store file    
    STOU    No      ---     Store with unique name    
    STRU    Yes    0.1.0    Set file structure
                            Supports "File" structure only. "Record" and
                            "Page" are not supported
    SYST    Yes    0.2.0    Get system type
                            Always returns "UNIX Type: L8"
    TYPE    Yes    0.1.0    Set representation type
                            Supports ascii non-print and binary-non-print
                            only
    USER    Yes    0.1.0    Set user    

## RFC-1123 - Requirements for Internet Hosts

Extends and clarifies some aspects of RFC-959. Introduces new response
codes 554 and 555.

* Issued: October 1989
* Status: STANDARD
* [link](http://tools.ietf.org/rfc/rfc1123.txt)

The following compliance table is lifted out of the RFC and annotated
with "C" where FTPD complies, or "E" where compliance is not required.

<pre>
                                           |               | | | |S| |
                                           |               | | | |H| |F
                                           |               | | | |O|M|o
                                           |               | |S| |U|U|o
                                           |               | |H| |L|S|t
                                           |               |M|O| |D|T|n
                                           |               |U|U|M| | |o
                                           |               |S|L|A|N|N|t
                                           |               |T|D|Y|O|O|t
FEATURE                                    |SECTION        | | | |T|T|e
-------------------------------------------|---------------|-|-|-|-|-|--
Implement TYPE T if same as TYPE N         |4.1.2.2        | |x| | | |  
File/Record transform invertible if poss.  |4.1.2.4        | |x| | | |  
Server-FTP implement PASV                  |4.1.2.6        |x| | | | |  C
  PASV is per-transfer                     |4.1.2.6        |x| | | | |  
NLST reply usable in RETR cmds             |4.1.2.7        |x| | | | |  C
Implied type for LIST and NLST             |4.1.2.7        | |x| | | |  C
SITE cmd for non-standard features         |4.1.2.8        | |x| | | |  
STOU cmd return pathname as specified      |4.1.2.9        |x| | | | |  
Use TCP READ boundaries on control conn.   |4.1.2.10       | | | | |x|  C
Server-FTP send only correct reply format  |4.1.2.11       |x| | | | |  C
Server-FTP use defined reply code if poss. |4.1.2.11       | |x| | | |  C
  New reply code following Section 4.2     |4.1.2.11       | | |x| | |
Default data port same IP addr as ctl conn |4.1.2.12       |x| | | | |
Server-FTP handle Telnet options           |4.1.2.12       |x| | | | |
Handle "Experimental" directory cmds       |4.1.3.1        | |x| | | |  C
Idle timeout in server-FTP                 |4.1.3.2        | |x| | | |
    Configurable idle timeout              |4.1.3.2        | |x| | | |
Receiver checkpoint data at Restart Marker |4.1.3.4        | |x| | | |
Sender assume 110 replies are synchronous  |4.1.3.4        | | | | |x|
                                           |               | | | | | |
Support TYPE:                              |               | | | | | |
  ASCII - Non-Print (AN)                   |4.1.2.13       |x| | | | |  C
  ASCII - Telnet (AT) -- if same as AN     |4.1.2.2        | |x| | | |
  ASCII - Carriage Control (AC)            |959 3.1.1.5.2  | | |x| | |
  EBCDIC - (any form)                      |959 3.1.1.2    | | |x| | |
  IMAGE                                    |4.1.2.1        |x| | | | |  C
  LOCAL 8                                  |4.1.2.1        |x| | | | |
  LOCAL m                                  |4.1.2.1        | | |x| | |2
                                           |               | | | | | |
Support MODE:                              |               | | | | | |
  Stream                                   |4.1.2.13       |x| | | | |  C
  Block                                    |959 3.4.2      | | |x| | |
                                           |               | | | | | |
Support STRUCTURE:                         |               | | | | | |
  File                                     |4.1.2.13       |x| | | | |  C
  Record                                   |4.1.2.13       |x| | | | |3 E
  Page                                     |4.1.2.3        | | | |x| |
                                           |               | | | | | |
Support commands:                          |               | | | | | |
  USER                                     |4.1.2.13       |x| | | | |  C
  PASS                                     |4.1.2.13       |x| | | | |  C
  ACCT                                     |4.1.2.13       |x| | | | |
  CWD                                      |4.1.2.13       |x| | | | |  C
  CDUP                                     |4.1.2.13       |x| | | | |  C
  SMNT                                     |959 5.3.1      | | |x| | |
  REIN                                     |959 5.3.1      | | |x| | |
  QUIT                                     |4.1.2.13       |x| | | | |  C
                                           |               | | | | | |
  PORT                                     |4.1.2.13       |x| | | | |  C
  PASV                                     |4.1.2.6        |x| | | | |  C
  TYPE                                     |4.1.2.13       |x| | | | |1 C
  STRU                                     |4.1.2.13       |x| | | | |1 C
  MODE                                     |4.1.2.13       |x| | | | |1 C
                                           |               | | | | | |
  RETR                                     |4.1.2.13       |x| | | | |  C
  STOR                                     |4.1.2.13       |x| | | | |  C
  STOU                                     |959 5.3.1      | | |x| | |
  APPE                                     |4.1.2.13       |x| | | | |
  ALLO                                     |959 5.3.1      | | |x| | |  C
  REST                                     |959 5.3.1      | | |x| | |
  RNFR                                     |4.1.2.13       |x| | | | |  C
  RNTO                                     |4.1.2.13       |x| | | | |  C
  ABOR                                     |959 5.3.1      | | |x| | |
  DELE                                     |4.1.2.13       |x| | | | |  C
  RMD                                      |4.1.2.13       |x| | | | |  C
  MKD                                      |4.1.2.13       |x| | | | |  C
  PWD                                      |4.1.2.13       |x| | | | |  C
  LIST                                     |4.1.2.13       |x| | | | |  C
  NLST                                     |4.1.2.13       |x| | | | |  C
  SITE                                     |4.1.2.8        | | |x| | |
  STAT                                     |4.1.2.13       |x| | | | |
  SYST                                     |4.1.2.13       |x| | | | |
  HELP                                     |4.1.2.13       |x| | | | |
  NOOP                                     |4.1.2.13       |x| | | | |  C

Footnotes:

(1)  For the values shown earlier.
(2)  Here m is number of bits in a memory word.
(3)  Required for host with record-structured file system, optional
     otherwise.

</pre>

## RFC-2228 - FTP Security Extensions

Specifies several security extensions to the base FTP protocol defined
in RFC-959. New commands: AUTH, ADAT, PROT, PBSZ, CCC, MIC, CONF, and
ENC. New response codes: 232, 234, 235, 334, 335, 336, 431, 533, 534,
535, 536, 537, 631, 632, and 633.

<pre>
AUTH    Yes    0.1.0    Authentication/Security Mechanism
ADAT    No      ---     Authentication/Security Data
PROT    Yes    0.1.0    Data Channel Protection Level
PBSZ    Yes    0.1.0    Protection Buffer Size
CCC     No      ---     Clear Command Channel
MIC     No      ---     Integrity Protect Command
CONF    No      ---     Confidentiality Protected Command
ENC     No      ---     Privacy Protected Command
</pre>

## RFC-2389 - Feature negotiation mechanism for the File Transfer Protocol

Introduces the new FEAT and OPTS commands.

* Issued: August 1998
* Status: PROPOSED STANDARD
* [link](http://tools.ietf.org/rfc/rfc2389.txt)

<pre>
FEAT    No      ---     List new supported commands
OPTS    No      ---     Set options for certain commands
</pre>

## RFC-2428 - FTP Extensions for IPv6 and NATs

Introduces the new commands EPRT and EPSV extending FTP to enable its
use over various network protocols, and the new response codes 522 and
229.

* Issued: September 1998
* Status: PROPOSED STANDARD
* [link](http://tools.ietf.org/rfc/rfc2428.txt)

<pre>
EPRT    No      ---     Set active data connection over IPv4 or IPv6    
EPSV    No      ---     Set passive data connection over IPv4 or IPv6 
</pre>

##RFC-2577 - FTP Security Considerations

Provides several configuration and implementation suggestions to
mitigate some security concerns, including limiting failed password
attempts and third-party "proxy FTP" transfers, which can be used in
"bounce attacks".

* Issued: May 1999
* Status: INFORMATIONAL
* [link](http://tools.ietf.org/rfc/rfc2577.txt)

<pre>
FTP bounce protection
Restruct PASV/PORT to non-priv. ports     No      ---
Disconnect after so many wrong auths.     No      ---
Delay on invalid password                 No      ---
Per-source IP limit                       No      ---
Do not reject wrong usernames             Yes    0.1.0
Port stealing protection                  No      ---
</pre>

## RFC-2640 - Internationalization of the File Transfer Protocol

Extends the FTP protocol to support multiple character sets, in
addition to the original 7-bit ASCII. Introduces the new LANG command.

* Issued: July 1999
* Status: PROPOSED STANDARD
* [link](http://tools.ietf.org/rfc/rfc2640.txt)

<pre>
LANG command     No      --- 
UNICODE          No      ---
</pre>

RFC-3659 - Extensions to FTP

Four new commands are added: "SIZE", "MDTM", "MLST", and "MLSD". The existing command "REST" is modified.

* Issued: March 2007
* Status: PROPOSED STANDARD
* Updates: [RFC-959](http://tools.ietf.org/rfc/rfc959.txt)
* [link](http://tools.ietf.org/rfc/rfc3659.txt)

<pre>
MDTM command      No    ---   Get file's last modification time       
MLSD command      No    ---   Get directory list in a standardized form.
MLST command      No    ---   Get file information in a standardized form.
SIZE command      No    ---   Get file size.
TVSF mechanism    No    ---   Unix-like file system naming conventions
Min. MLST facts   No    ---   
GMT timestamps    No    ---
</pre>

##RFC-4217 - Securing FTP with TLS

Provides a description on how to implement TLS as a security mechanism to secure FTP clients and/or servers.

* Issued: October 2005
* Status: STANDARD
* Updates:
  [RFC-959](http://tools.ietf.org/rfc/rfc959.txt)
  [RFC-2246](http://tools.ietf.org/rfc/rfc2246.txt)
  [RFC-2228](http://tools.ietf.org/rfc/rfc2228.txt)
* [link](http://tools.ietf.org/rfc/rfc4217.txt)

<pre>
AUTH    Yes    0.1.0    Authentication/Security Mechanism
CCC     No      ---     Clear Command Channel
PBSZ    Yes    0.1.0    Protection Buffer Size
PROT    Yes    0.1.0    Data Channel Protection Level.
                        Support only "Private" level
</pre>
