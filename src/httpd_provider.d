/*
 * httpd_provider.d: defines the probes specified by the HTTP provider itself.
 *     This file is processed by dtrace(1M) twice: once before compiling to
 *     generate a header file used by the Apache module and once again at link
 *     time to enable the binary for USDT.
 */

/*
 * These definitions are unused but necessary to satisfy the DTrace compiler.
 */
typedef struct { int dummy; } dthttpd_t;
typedef struct { int dummy; } conninfo_t;
typedef struct { int dummy; } httpd_rqinfo_t;

/*
 * We follow existing conventions for DTrace providers in the names of probes
 * and names and types of probe arguments.  This provider defines two probes:
 *
 *	httpd*:::request-start		Processing begins for a given request
 *		arg0: conninfo_t	(see /usr/lib/dtrace/net.d)
 *		arg1: httpd_rqinfo_t	(see httpd_provider_impl.h)
 *
 *	httpd*:::request-done		Processing finishes for a given request
 *		arg0: conninfo_t	(see /usr/lib/dtrace/net.d)
 *		arg1: httpd_rqinfo_t	(see httpd_provider_impl.h)
 */
provider httpd {
	probe request__start(dthttpd_t *p) : (conninfo_t *p, httpd_rqinfo_t *p);
	probe request__done(dthttpd_t *p) : (conninfo_t *p, httpd_rqinfo_t *p);
};

#pragma D attributes Evolving/Evolving/ISA	provider httpd provider
#pragma D attributes Private/Private/Unknown	provider httpd module
#pragma D attributes Private/Private/Unknown	provider httpd function
#pragma D attributes Private/Private/ISA	provider httpd name
#pragma D attributes Evolving/Evolving/ISA	provider httpd args
