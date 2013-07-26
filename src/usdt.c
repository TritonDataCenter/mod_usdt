/*
 * usdt.c: Apache module implementing a DTrace "httpd" provider
 */

#include <strings.h>

#include <httpd.h>
#include <http_protocol.h>
#include <http_config.h>
#include <apr_tables.h>

/*
 * Apache 2.4's attempted integration with DTrace broke all modules that were
 * using DTrace by #undef'ing _DTRACE_VERSION, even if you're building with
 * --enable-dtrace.  For that reason, we hardcode a #define of _DTRACE_VERSION
 * here.  This is truly awful -- it should not be necessary, and it's not our
 * business to assert what the system does or does not support, but we don't
 * have a lot of choice.
 */
#if AP_MODULE_MAGIC_AT_LEAST(20111130,0)
#ifndef _DTRACE_VERSION
#define	_DTRACE_VERSION 3
#endif
#endif

#include "httpd_provider_impl.h"
#include <httpd_provider.h>

static void dtp_register_hooks(apr_pool_t *);
static int dtp_request_start(request_rec *);
static int dtp_request_done(request_rec *);

module AP_MODULE_DECLARE_DATA usdt_module = {
	STANDARD20_MODULE_STUFF,
	NULL,				/* per-directory conf */
	NULL,				/* merge */
	NULL,				/* per-server conf */
	NULL,				/* merge */
	NULL,				/* commands */
	dtp_register_hooks,		/* hooks */
};

static void
dtp_register_hooks(apr_pool_t *pool)
{
	ap_hook_post_read_request(dtp_request_start, NULL, NULL,
	    APR_HOOK_FIRST);
	ap_hook_log_transaction(dtp_request_done, NULL, NULL,
	    APR_HOOK_LAST);
}

static void
dtp_request_fill(dthttpd_t *infop, request_rec *rqp)
{
	bzero(infop, sizeof (*infop));
	infop->dt_rqid = (uint64_t)(uintptr_t)rqp;
	infop->dt_laddr = rqp->connection->local_ip;
	infop->dt_lport = rqp->connection->local_addr->port;
#if AP_MODULE_MAGIC_AT_LEAST(20111130,0)
	infop->dt_raddr = rqp->connection->client_ip;
	infop->dt_rport = rqp->connection->client_addr->port;
#else
	infop->dt_raddr = rqp->connection->remote_ip;
	infop->dt_rport = rqp->connection->remote_addr->port;
#endif
	infop->dt_method = rqp->method;
	infop->dt_uri = rqp->unparsed_uri;
	infop->dt_agent = apr_table_get(rqp->headers_in, "user-agent");
}

static int
dtp_request_start(request_rec *rqp)
{
	dthttpd_t info;

	if (!HTTPD_REQUEST_START_ENABLED())
		return (OK);

	dtp_request_fill(&info, rqp);
	HTTPD_REQUEST_START(&info);
	return (OK);
}

static int
dtp_request_done(request_rec *rqp)
{
	dthttpd_t info;

	if (!HTTPD_REQUEST_DONE_ENABLED())
		return (OK);

	dtp_request_fill(&info, rqp);
	info.dt_status = rqp->status;

	HTTPD_REQUEST_DONE(&info);
	return (OK);
}
