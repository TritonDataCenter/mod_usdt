mod_dtprovider
==============

mod_dtprovider is an Apache2 module that implements an "httpd" DTrace provider,
allowing you to trace Apache requests using DTrace.  DTrace is a comprehensive
dynamic tracing framework available on Illumos, BSD, and MacOS, systems.  For
more information about DTrace, see http://en.wikipedia.org/wiki/DTrace.


Example
-------

Use the included examples/http-requests.d to view all HTTP requests as Apache
completes them:

    # dtrace -s examples/http-requests.d
     time    latency  sta            local                 remote        method uri
    1.216   309850us  404      10.99.99.20:80        10.99.99.254:51067  GET    /hello
    3.103      646us  404      10.99.99.20:80        10.99.99.254:51068  GET    /world


Or, for busier services, summarize latency over time with a histogram:

    # dtrace -s examples/http-requests.d
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
headers available in some standard location.  Then run:

    # make

To install:

1. (optional) Copy build/mod_dtprovider.so to wherever you keep your Apache
   module binaries.

2. Modify the Apache configuration to include the new module by adding this
   line (specifing the appropriate path):

    LoadModule dtprovider_module path/to/mod_dtprovider.so

3. Restart Apache.

4. Copy build/httpd.d into /usr/lib/dtrace.  You can skip this step, but then
   every dtrace(1M) invocation must use "-L" to specify the path to the
   directory containing this file.

The module is very simple: it registers hooks for the beginning and end of each
request.  In each hook function, if the corresponding DTrace probe is enabled,
it constructs the appropriate arguments and fires the probe.  The module thus
has minimal overhead whether the DTrace probes are enabled or not.


Status
-----

This module is fully functional on 32-bit Apache.  64-bit support is
forthcoming.  It has only been tested on SmartOS, an Illumos-based
(Solaris-based) system.  It should be possible to modify this for MacOS and
BSD; pull requests welcome.
