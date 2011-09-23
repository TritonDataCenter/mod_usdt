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
	@ = quantize(timestamp - self->start);
	self->start = 0;
}
