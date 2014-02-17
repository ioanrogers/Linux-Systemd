#!/usr/bin/env perl

use v5.10.1;
use strict;
use warnings;
use Linux::Systemd::Journal::Write;

my $jnl = Linux::Systemd::Journal::Write->new;

$jnl->print('flarg');
$jnl->print('Hello world', 4);

my %hash = (1 => 'Monday', 2 => 'Tuesday', 3 => 'Wednesday');
$jnl->send('Here is a message', \%hash);
