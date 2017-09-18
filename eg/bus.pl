#!/usr/bin/env perl

use v5.16;
use warnings;

use Linux::Systemd::Bus;

my $bus = Linux::Systemd::Bus->new;

for my $name (@{$bus->list}) {
    say $name;
}
