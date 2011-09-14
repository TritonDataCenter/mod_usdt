/*
 * http_provider_impl.h: implementation-specific header file for HTTP provider
 */

/*
 * This structure is passed from the Apache module to DTrace when a probe is
 * fired.  DTrace constructs the probe arguments from the data contained
 * here.  The structure starts with a version field to allow it to be easily
 * expanded in the future.
 */
typedef struct {
	uint16_t	dt_version;	/* structure version number */
	uint64_t	dt_rqid;	/* unique request identifier */
	const char	*dt_laddr;	/* local IP address (as string) */
	uint16_t	dt_lport;	/* local TCP port */
	const char	*dt_raddr;	/* remote IP address (as string) */
	uint16_t	dt_rport;	/* remote TCP port */
	uint64_t  	dt_bytesin;	/* bytes received from client */
	const char	*dt_method;	/* requested HTTP method */
	const char	*dt_uri;	/* requested URI */
	const char	*dt_agent;	/* user agent header */
	const char	*dt_origin;	/* reported origin IP */
} dthttp_t;

#define	DT_VERS_1	1
#define	DT_VERS		DT_VERS_1
