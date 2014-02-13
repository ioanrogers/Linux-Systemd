#!/usr/bin/env perl

use v5.10.1;
use strict;
use warnings;
use Linux::Systemd::Journal::Write;
use Data::Printer;

my $jnl = Linux::Systemd::Journal::Write->new(
    id => 'blah',
);

#$jnl->print('flarg');
#$jnl->print(['Fuck %s', 'you'], 4);

my $data = {
    message => 'TESTING',
    abstract => 'XS wrapper around sd-journal',
    author => 'Ioan Rogers <ioanr@cpan.org>',
    dynamic_config => 0,
    generated_by => 'Dist::Zilla version 4.300037, CPAN::Meta::Converter version 2.132140',
};

$jnl->send($data);
