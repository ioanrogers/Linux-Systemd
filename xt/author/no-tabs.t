use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Linux/Systemd/Journal.pm',
    'lib/Linux/Systemd/Journal/Read.pm',
    'lib/Linux/Systemd/Journal/Write.pm',
    't/00-check-deps.t',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/01-write.t',
    't/02-read.t'
);

notabs_ok($_) foreach @files;
done_testing;
