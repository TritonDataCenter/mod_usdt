/*
 * httpd.d: DTrace library for translating arguments from the httpd provider
 */

#pragma D depends_on library net.d
#pragma D depends_on library procfs.d

/*
 * The Apache module passes us a dthttpd_t structure from which we construct the
 * conninfo_t and httpd_rqinfo_t structures that get passed into DTrace probes.
 * We must redefine the dthttpd_t structure here and it must exactly match that
 * used by Apache.
 */
typedef struct {
	uint16_t	dt_version;	/* structure version number */
	uint16_t	dt_status;	/* status code (only on "done" probe) */
	uint16_t	dt_lport;	/* local TCP port */
	uint16_t	dt_rport;	/* remote TCP port */
	uint64_t	dt_rqid;	/* unique request identifier */
	uint64_t	dt_laddr;	/* local IP address (as string) */
	uint64_t	dt_raddr;	/* remote IP address (as string) */
	uint64_t	dt_method;	/* requested HTTP method */
	uint64_t	dt_uri;		/* requested URI */
	uint64_t	dt_agent;	/* user agent header */
} dthttpd_t;

typedef struct {
	uint16_t	dt_version;	/* structure version number */
	uint16_t	dt_status;	/* status code (only on "done" probe) */
	uint16_t	dt_lport;	/* local TCP port */
	uint16_t	dt_rport;	/* remote TCP port */
	uint64_t	dt_rqid;	/* unique request identifier */
	uint32_t	dt_laddr;	/* local IP address (as string) */
	uint32_t	dt_raddr;	/* remote IP address (as string) */
	uint32_t	dt_method;	/* requested HTTP method */
	uint32_t	dt_uri;		/* requested URI */
	uint32_t	dt_agent;	/* user agent header */
} dthttpd32_t;

inline int DT_VERS_1 = 1;
inline int DT_VERS = DT_VERS_1;

/*
 * This is the structure that's actually provided to DTrace probe consumers.
 */
typedef struct {
	uint64_t	rq_id;		/* unique request identifier */
	uint16_t	rq_status;	/* status code (only on "done" probe) */
	uint16_t	rq_lport;	/* local TCP port */
	uint16_t	rq_rport;	/* remote TCP port */
	string		rq_method;	/* requested method */
	string 		rq_uri;		/* requested URI */
	string 		rq_agent;	/* user agent string */
} httpd_rqinfo_t;

#pragma D binding "1.6.1" translator
translator conninfo_t <dthttpd_t *dp> {
	ci_local = copyinstr(
		(uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_laddr,
		    sizeof (((dthttpd32_t *)dp)->dt_laddr))));
	ci_remote = copyinstr(
		(uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_raddr,
		    sizeof (((dthttpd32_t *)dp)->dt_raddr))));
	ci_protocol = "ipv4";
};

#pragma D binding "1.6.1" translator
translator httpd_rqinfo_t <dthttpd_t *dp>
{
	rq_id = *(uint64_t *)copyin((uintptr_t)&dp->dt_rqid,
	    sizeof (dp->dt_rqid));
	rq_status = *(uint16_t *)copyin((uintptr_t)&dp->dt_status,
	    sizeof (dp->dt_status));
	rq_lport = *(uint16_t *)copyin((uintptr_t)&dp->dt_lport,
	    sizeof (dp->dt_lport));
	rq_rport = *(uint16_t *)copyin((uintptr_t)&dp->dt_rport,
	    sizeof (dp->dt_rport));
	rq_method = copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_method,
		    sizeof (uint32_t))));
	rq_uri = copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_uri,
		    sizeof (uint32_t))));
	rq_agent = copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_agent,
		    sizeof (uint32_t))));
};
