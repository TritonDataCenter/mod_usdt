#!/usr/sbin/dtrace -s

#pragma D option quiet

BEGIN
{
	printf("%6s %10s  %3s %16s%6s %16s%6s  %6s %s\n", "time", "latency",
	    "sta", "local", "", "remote", "", "method", "uri");
	script_start = timestamp;
}

httpd*:::request-start
{
	self->start = timestamp;
}

httpd*:::request-done
{
	printf("%2d.%03d %8dus  %3d %16s:%-5d %16s:%-5d  %-6s %s\n",
	    (timestamp - script_start) / 1000 / 1000 / 1000,
	    ((timestamp - script_start) / 1000 / 1000) % 1000,
	    (timestamp - self->start) / 1000, args[1]->rq_status,
	    args[0]->ci_local, args[1]->rq_lport, args[0]->ci_remote,
	    args[1]->rq_rport, args[1]->rq_method, args[1]->rq_uri);
	self->start = 0;
}
