/*
 * httpd_provider_impl.h: implementation-specific header file for HTTP provider
 */

/*
 * This structure is passed from the Apache module to DTrace when a probe is
 * fired.  DTrace constructs the probe arguments from the data contained here
 * using the translators defined in httpd.d.  To simplify the translators, all
 * fixed-size fields are up front, followed by the pointer-sized values whose
 * sizes depends on whether this is a 32-bit or 64-bit application.  We use
 * padding in each section to allow for future expansion.
 */
typedef struct {
	uint64_t	dt_rqid;	/* unique request identifier */
	uint16_t	dt_status;	/* status code (only on "done" probe) */
	uint16_t	dt_lport;	/* local TCP port */
	uint16_t	dt_rport;	/* remote TCP port */
	uint8_t		dt_pad1[34];	/* padding for fixed-length fields */
	const char	*dt_laddr;	/* local IP address (as string) */
	const char	*dt_raddr;	/* remote IP address (as string) */
	const char	*dt_method;	/* requested HTTP method */
	const char	*dt_uri;	/* requested URI */
	const char	*dt_agent;	/* user agent header */
	uint8_t		dt_pad2[32];	/* padding for word-size fields */
} dthttpd_t;
