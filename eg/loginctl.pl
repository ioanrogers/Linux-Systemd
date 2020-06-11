#!/usr/bin/env perl

use v5.22;
use warnings;

use Linux::Systemd::Bus;
use Data::Printer;

my $bus = Linux::Systemd::Bus->new;
use DDP; p $bus;

my $res = $bus->call(
    'org.freedesktop.login1',         '/org/freedesktop/login1',
    'org.freedesktop.login1.Manager', 'ListSessions', 'a'
);

use DDP; p $res;
