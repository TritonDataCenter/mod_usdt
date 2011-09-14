/*
 * http.d: DTrace library for translating arguments from the Apache DTrace provider
 */

#pragma D depends_on library net.d

/*
 * The Apache module passes us a dthttp_t structure from which we construct the
 * conninfo_t and http_rqinfo_t structures that get passed into DTrace probes.
 * We must redefine the dthttp_t structure here and it must exactly match that
 * used by Apache.
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

/*
 * This is the structure that's actually provided to DTrace probe consumers.
 */
typedef struct {
	uint64_t	rq_id;		/* unique request identifier */
	uint64_t	rq_bytesin;	/* bytes received from client */
	string		rq_method;	/* requested method */
	string 		rq_uri;		/* requested URI */
	string 		rq_useragent;	/* user agent string */
	string 		rq_origin;	/* reported origin */
} http_rqinfo_t;

#pragma D binding "1.6.1" translator
translator conninfo_t <dthttp_t *dp> {
	ci_local = "<unknown>";
	ci_remote = "<unknown>";
	ci_protocol = "<unknown>";
};

#pragma D binding "1.6.1" translator
translator http_rqinfo_t <dthttp_t *dp>
{
	rq_id = (uint64_t)dp;
	rq_bytesin = 0;
	rq_method = "<unknown>";
	rq_uri = "<unknown>";
	rq_useragent = "<unknown>";
	rq_origin = "<unknown>";
};
