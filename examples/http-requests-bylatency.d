#!/usr/sbin/dtrace -s

#pragma D option quiet

BEGIN
{
	printf("Tracing.  Hit CTRL-C to stop.\n");
}

httpd*:::request-start
{
	self->start = timestamp;
}

httpd*:::request-done
{
	@["microseconds"] = quantize((timestamp - self->start) / 1000);
	self->start = 0;
}
