/*
 * dtprovider.c: Apache module implementing a DTrace "http" provider
 */

#include <httpd.h>
#include <http_protocol.h>
#include <http_config.h>

static void dtp_register_hooks(apr_pool_t *);
static int dtp_request_start(request_rec *);
static int dtp_request_done(request_rec *);

module AP_MODULE_DECLARE_DATA dtprovider_module = {
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

static int
dtp_request_start(request_rec *rqp)
{
	return (DECLINED);
}

static int
dtp_request_done(request_rec *rqp)
{
	return (DECLINED);
}
