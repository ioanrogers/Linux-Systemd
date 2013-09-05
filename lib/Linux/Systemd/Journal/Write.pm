package Linux::Systemd::Journal::Write;

# ABSTRACT: XS wrapper around sd-journal

use v5.10.1;
use Moo;
use Carp;
use XSLoader;

XSLoader::load;

sub print {
    my ($self, $msg) = @_;
    say "Trying to send [$msg]";
    $msg = "MESSAGE=$msg";

    my $ret = _lsj_print($msg);

    confess "Error sending message: $!" if $ret;

    return $ret;
}


1;
