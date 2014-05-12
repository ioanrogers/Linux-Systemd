#!/usr/bin/env perl

use v5.10.1;
use strict;
use warnings;
use Data::Printer;
use Linux::Systemd::Journal::Read;

my $jnl = Linux::Systemd::Journal::Read->new;

my $bytes = $jnl->get_usage;
say "Journal size: $bytes bytes";

$jnl->seek_head;
$jnl->next;

say 'MESSAGE: ' . $jnl->get_data('MESSAGE');
say '_EXE: ' . $jnl->get_data('_EXE');

$jnl->next;
my $entry = $jnl->get_entry;
p $entry;
