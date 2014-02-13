package Linux::Systemd::Journal::Write;

# ABSTRACT: XS wrapper around sd-journal

# TODO Helper script to generate message catalogs?
# http://www.freedesktop.org/wiki/Software/systemd/catalog/

# TODO pass the CODE_* values to systemd so it doesn't mark everything
# as coming from Write.xs

use v5.10.1;
use Moo;
use Carp;
use XSLoader;
use Data::Printer;
XSLoader::load;

has app_id => (is => 'ro', lazy => 1);
has priority => (is => 'ro', lazy => 1, default => 6);

=method C<print($msg, $pri)>

$msg should be either a string or an arrayref suitable for use with L<sprintf>
$pri is optional, and defaults to $self->priority

=cut
sub print {
    if (scalar @_ > 3) {
        confess 'Too many args. Did you forget to use an arrayref?';
    }

    my ($self, $msg, $pri) = @_;

    # TODO I'd prefer to not use an arrayref
    if (ref $msg eq 'ARRAY') {
        $msg = sprintf shift $msg, @$msg;
    }

    say "Trying to send [$msg]";
    $pri = $self->priority if !$pri;
    my $ret = _my_sd_journal_print($pri, $msg);
    confess "Error sending message: $!" if $ret;

    return;
}

=method C<send($data)>

$data must be a hashref. Keys will be uppercased.

=cut

sub send {
    my ($self, $data) = @_;
    # TODO send($msg, $data);
    # TODO $data can also be an arrayref or an array (and maybe a string?)

    # message is required
    if (!exists $data->{message} && !exists $data->{MESSAGE}) {
        confess "Missing message param";
    }

    # XXX this isn't required by sd-journal
    if (!exists $data->{priority} && !exists $data->{PRIORITY}) {
        $data->{priority} = $self->priority;
    }

    # flatten it out
    my @array = map { uc($_) . '=' . $data->{$_} } keys $data;

    if (_my_sd_journal_send(\@array) != 0) {
        confess "Error sending message: $!";
    }

    return;
}

1;
