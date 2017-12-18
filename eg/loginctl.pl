#!/usr/bin/env perl

use v5.16;
use warnings;

use Linux::Systemd::Bus;
use Data::Printer;

my $bus = Linux::Systemd::Bus->new;

my $res = $bus->call(
    'org.freedesktop.login1',         '/org/freedesktop/login1',
    'org.freedesktop.login1.Manager', 'ListSessions', 'a'
);

say $res;
use DDP; p $res;

say $bus->call(
    'org.freedesktop.login1',         '/org/freedesktop/login1',
    'org.freedesktop.login1.Manager', 'CanSuspend', 's'
);
