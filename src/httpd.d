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
	uint64_t	dt_rqid;	/* unique request identifier */
	uint16_t	dt_status;	/* status code (only on "done" probe) */
	uint16_t	dt_lport;	/* local TCP port */
	uint16_t	dt_rport;	/* remote TCP port */
	uint8_t		dt_pad1[34];	/* padding for fixed-length fields */
	uint64_t	dt_laddr;	/* local IP address (as string) */
	uint64_t	dt_raddr;	/* remote IP address (as string) */
	uint64_t	dt_method;	/* requested HTTP method */
	uint64_t	dt_uri;		/* requested URI */
	uint64_t	dt_agent;	/* user agent header */
	uint8_t		dt_pad2[32];	/* padding for word-size fields */
} dthttpd_t;

typedef struct {
	uint64_t	dt_rqid;	/* unique request identifier */
	uint16_t	dt_status;	/* status code (only on "done" probe) */
	uint16_t	dt_lport;	/* local TCP port */
	uint16_t	dt_rport;	/* remote TCP port */
	uint8_t		dt_pad1[34];	/* padding for fixed-length fields */
	uint32_t	dt_laddr;	/* local IP address (as string) */
	uint32_t	dt_raddr;	/* remote IP address (as string) */
	uint32_t	dt_method;	/* requested HTTP method */
	uint32_t	dt_uri;		/* requested URI */
	uint32_t	dt_agent;	/* user agent header */
	uint8_t		dt_pad2[32];	/* padding for word-size fields */
} dthttpd32_t;

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

/*
 * The input structures are laid out so that fixed-width fields are at the
 * front to simplify the following translators.  That's why we don't bother
 * checking curpsinfo->pr_dmodel for these fields.
 */
#pragma D binding "1.6.1" translator
translator conninfo_t < dthttpd_t *dp > {
	ci_local = curpsinfo->pr_dmodel == PR_MODEL_ILP32 ?
		copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_laddr,
		    sizeof (((dthttpd32_t *)dp)->dt_laddr)))) :
		copyinstr(*(uintptr_t *)copyin(
		    (uintptr_t)&dp->dt_laddr, sizeof (uint64_t)));
	ci_remote = curpsinfo->pr_dmodel == PR_MODEL_ILP32 ?
		copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_raddr,
		    sizeof (((dthttpd32_t *)dp)->dt_raddr)))) :
		copyinstr(*(uintptr_t *)copyin(
		    (uintptr_t)&dp->dt_raddr, sizeof (uint64_t)));
	ci_protocol = "ipv4";
};

#pragma D binding "1.6.1" translator
translator httpd_rqinfo_t < dthttpd_t *dp >
{
	rq_id = *(uint64_t *)copyin((uintptr_t)&dp->dt_rqid,
	    sizeof (dp->dt_rqid));
	rq_status = *(uint16_t *)copyin((uintptr_t)&dp->dt_status,
	    sizeof (dp->dt_status));
	rq_lport = *(uint16_t *)copyin((uintptr_t)&dp->dt_lport,
	    sizeof (dp->dt_lport));
	rq_rport = *(uint16_t *)copyin((uintptr_t)&dp->dt_rport,
	    sizeof (dp->dt_rport));
	rq_method = curpsinfo->pr_dmodel == PR_MODEL_ILP32 ?
		copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_method,
		    sizeof (uint32_t)))) :
		copyinstr(*(uintptr_t *)copyin(
		    (uintptr_t)&dp->dt_method, sizeof (uint64_t)));
	rq_uri = curpsinfo->pr_dmodel == PR_MODEL_ILP32 ?
		copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_uri,
		    sizeof (uint32_t)))) :
		copyinstr(*(uintptr_t *)copyin(
		    (uintptr_t)&dp->dt_uri, sizeof (uint64_t)));
	rq_agent = curpsinfo->pr_dmodel == PR_MODEL_ILP32 ?
		copyinstr((uintptr_t)(uint64_t)(*(uint32_t *)copyin(
		    (uintptr_t)&((dthttpd32_t *)dp)->dt_agent,
		    sizeof (uint32_t)))) :
		copyinstr(*(uintptr_t *)copyin(
		    (uintptr_t)&dp->dt_agent, sizeof (uint64_t)));
};
