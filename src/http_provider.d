/*
 * http_provider.d: defines the probes specified by the HTTP provider itself.
 *     This file is processed by dtrace(1M) twice: once before compiling to
 *     generate a header file used by the Apache module and once again at link
 *     time to enable the binary for USDT.
 */

/*
 * These definitions are unused but necessary to satisfy the DTrace compiler.
 */
typedef struct { int dummy; } dthttp_t;
typedef struct { int dummy; } conninfo_t;
typedef struct { int dummy; } http_rqinfo_t;
translator conninfo_t <dthttp_t *dp> { dummy = 0; };
translator http_rqinfo_t <dthttp_t *dp> { dummy = 0; };

/*
 * We follow existing conventions for DTrace providers in the names of probes
 * and names and types of probe arguments.  This provider defines two probes:
 *
 *	http*:::request-start		Processing begins for a given request
 *		arg0: conninfo_t	(see /usr/lib/dtrace/net.d)
 *		arg1: http_rqinfo_t	(see http_provider_impl.h)
 *
 *	http*:::request-done		Processing finishes for a given request
 *		arg0: conninfo_t	(see /usr/lib/dtrace/net.d)
 *		arg1: http_rqinfo_t	(see http_provider_impl.h)
 */
provider http {
	probe request__start(dthttp_t *p) : (conninfo_t *, http_rqinfo_t *);
	probe request__done(dthttp_t *p) : (conninfo_t *, http_rqinfo_t *);
}

#pragma D attributes Evolving/Evolving/ISA	provider http provider
#pragma D attributes Private/Private/Unknown	provider http module
#pragma D attributes Private/Private/Unknown	provider http function
#pragma D attributes Private/Private/ISA	provider http name
#pragma D attributes Evolving/Evolving/ISA	provider http args
