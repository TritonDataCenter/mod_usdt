mod_usdt
==============

mod_usdt is an Apache2 module that implements an "httpd" DTrace provider,
allowing you to trace Apache requests using DTrace.  DTrace is a comprehensive
dynamic tracing framework available on Illumos-based, BSD, and MacOS systems.
For more information about DTrace, see http://en.wikipedia.org/wiki/DTrace.


Example
-------

Use the included examples/http-requests.d to view all HTTP requests as Apache
completes them:

    # dtrace -s examples/http-requests.d
     time    latency  sta            local                 remote        method uri
    1.216   309850us  404      10.99.99.20:80        10.99.99.254:51067  GET    /hello
    3.103      646us  404      10.99.99.20:80        10.99.99.254:51068  GET    /world


Or, for busier services, summarize latency over time with a histogram:

    # dtrace -s examples/http-requests-bylatency.d
    Tracing.  Hit CTRL-C to stop.
    ^C
    
    microseconds                                      
    
           value  ------------- Distribution ------------- count    
              64 |                                         0        
             128 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       3367     
             256 |@@@@@@                                   578      
             512 |@                                        51       
            1024 |                                         3        
            2048 |                                         0        
            4096 |                                         0        
            8192 |                                         1        
           16384 |                                         0        



Instructions
------------

First, build the Apache module.  You'll need a C compiler and the Apache
headers available in some standard location.  If you want to build 64-bit,
first uncomment the appropriate line in the Makefile first.  Then run:

    # make

To install:

1. (optional) Copy build/mod_usdt.so to wherever you keep your Apache module
   binaries.

2. Modify the Apache configuration to include the new module by adding this
   line (specifing the appropriate path):

    LoadModule usdt_module path/to/mod_usdt.so

3. Restart Apache.

4. Copy src/httpd.d into /usr/lib/dtrace.  You can skip this step, but then
   every dtrace(1M) invocation must use "-L" to specify the path to the
   directory containing this file.

4a Using Inside Zones: Due to the current OS limitation of accessing the value 
   curpsinfo->pr_dmodel from within non-global zone; use the correct version of
   httpd.d (32 or 64-bit): src/httpd-zone-32.d or arc/httpd-zone-64.d respectively.
   Step #4 above applies.  

4b An easy way to determine if the Apache is 32-bit or 64-bit is to execute the following in the global zone:

    # dtrace -qn 'syscall::: /execname == "httpd"/ { ab = (curpsinfo->pr_dmodel == PR_MODEL_ILP32) ? "32-bit" : "64-bit" ; exit(0); } END { printf("Apache: %s",ab); }'
    Apache: 32-bit

4c Copy the right version and execute the examples to ensure it works in the non-global zone:

    # zlogin zone-percona0
    [root@zone-percona0 ~/]# cd ~/mod_usdt; mkdir trans32 
    [root@zone-percona0 ~/mod_usdt]# cp src/httpd-zone-32.d trans32/. 
    [root@zone-percona0 ~/mod_usdt]# dtrace -L trans32/ -s examples/http-requests-bylatency.d 
    dtrace: aggregation size lowered to 64k
    Tracing.  Hit CTRL-C to stop.
    ^C
    microseconds                                      
           value  ------------- Distribution ------------- count    
             512 |                                         0        
            1024 |@@@@@@@@@@@@@@@@@@@@                     1        
            2048 |                                         0        
            4096 |                                         0        
            8192 |@@@@@@@@@@@@@@@@@@@@                     1        
           16384 |                                         0 
       
4c Full details by Dave Pacheco at:
   https://www.listbox.com/member/archive/184261/2012/01/sort/time_rev/page/1/entry/0:5/20120117154842:A29D5E5A-414C-11E1-A2C5-B34EA897F121/

The module is very simple: it registers hooks for the beginning and end of each
request.  In each hook function, if the corresponding DTrace probe is enabled,
it constructs the appropriate arguments and fires the probe.  The module thus
has minimal overhead whether the DTrace probes are enabled or not.


Provider details
----------------

This provider defines the following probes:

* `httpd$pid:::request-start`: request received
* `httpd$pid:::request-start`: request completed (response sent)

Both probes are passed two arguments:

* `arg0` (`conninfo_t`): IP connection details
* `arg1` (`httpd_rqinfo_t`): HTTP request details

The `conninfo_t` is the same one used by the NFS, iSCSI, and various other
network protocol providers, included here for reference from
/usr/lib/dtrace/net.d:

    typedef struct conninfo {
    	string ci_local;	/* local host address */
    	string ci_remote;	/* remote host address */
    	string ci_protocol;	/* protocol (ipv4, ipv6, etc) */
    } conninfo_t;

The `httpd_rqinfo_t` structure looks like this:

    typedef struct {
    	uint64_t	rq_id;		/* unique request identifier */
    	uint16_t	rq_status;	/* status code (only on "done" probe) */
    	uint16_t	rq_lport;	/* local TCP port */
    	uint16_t	rq_rport;	/* remote TCP port */
    	string		rq_method;	/* requested method */
    	string 		rq_uri;		/* requested URI */
    	string 		rq_agent;	/* user agent string */
    } httpd_rqinfo_t;

See the source of the example scripts above to see how these structures can be
used.


Status
-----

This module is fully functional on 32-bit Apache.  64-bit support is
forthcoming.  It has only been tested on SmartOS, an Illumos-based
(Solaris-based) system.  It should be possible to modify this for MacOS and
BSD; pull requests welcome.
