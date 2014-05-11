package Linux::Systemd::Journal::Write;

# ABSTRACT: XS wrapper around sd-journal

# TODO Helper script to generate message catalogs?
# http://www.freedesktop.org/wiki/Software/systemd/catalog/

# TODO make sure all text is utf8

use v5.10.1;
use Moo;
use Carp;
use XSLoader;
use Data::Printer;
XSLoader::load;

=attr C<app_id>

Will be used to set C<SYSLOG_IDENTIFIER>. Defaults to C<basename($0)>;

=cut

has app_id => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        require File::Basename;
        return File::Basename::basename($0);
    },
);

=attr C<priority>

Default log priority. See L</"Log Levels">

=cut

has priority => (is => 'ro', lazy => 1, default => 6);

=method C<print($msg, $pri?)>

$msg should be either a string. $pri is optional, and defaults to $self->priority

=cut

sub print {
    my ($self, $msg, $pri) = @_;
    $pri = $self->priority if !$pri;
    __sd_journal_print($pri, $msg);
    return 1;
}

=method C<send($msg_or_data, $data?)>

If there is one arg, it may be a simple string to log. Or, it could be a hashref
 or an arrayref. In this case, one of the keys sent MUST be 'message'.

If there are two args, the first must be the string to use as a message, the
second a hashref or arrayref. In this case, a key called message should not be
set.

Finally, C<send> can also be called with an array of key => values, one of which
must be message.

Keys will be uppercased.

=cut

sub send {
    my $self = shift;

    my $data;

    if (scalar @_ == 2 && !ref $_[0]) {
        my $ref = ref $_[1];
        if ($ref eq 'HASH') {
            $data = {%{$_[1]}};
        } elsif ($ref eq 'ARRAY') {
            $data = {@{$_[1]}};
        }
        $data->{message} = $_[0];
    } elsif (scalar @_ > 1) {
        $data = {@_};
    } else {
        my $ref = ref $_[0];
        if (!$ref) {
            $data->{message} = shift;
        } elsif ($ref eq 'HASH') {
            $data = shift;
        } elsif ($ref eq 'ARRAY') {
            $data = {@{$_[0]}};
        }
    }

    croak 'Invalid params' unless defined $data;

    # message is required
    if (!exists $data->{message} && !exists $data->{MESSAGE}) {
        croak 'Missing message param';
    }

    # XXX this isn't required by sd-journal
    if (!exists $data->{priority} && !exists $data->{PRIORITY}) {
        $data->{priority} = $self->priority;
    }

    if (!exists $data->{priority} && !exists $data->{PRIORITY}) {
        $data->{priority} = $self->priority;
    }

    if (!exists $data->{syslog_identifier}) {
        $data->{syslog_identifier} = $self->app_id;
    }

    my @caller = caller(0);

    # $data->{CODE_FUNC} = $caller[3];
    $data->{CODE_LINE} = $caller[2];
    $data->{CODE_FILE} = $caller[1];

    # flatten it out
    my @array = map { uc($_) . '=' . ($data->{$_} // 'undef') } keys $data;

    __sd_journal_send(\@array);

    return 1;
}

=method C<perror($msg)>

Logs the string of the current set C<errno>, prefixed with C<$msg>.

=cut

sub perror {
    __sd_journal_perror($_[1]);
    return 1;
}

1;

=head1 SYNOPSIS

  use Linux::Systemd::Journal::Write;

  my $jnl = Linux::Systemd::Journal::Write->new;

  # basic log messages
  $jnl->print('flarg');          # with default log level
  $jnl->print('Hello world', 4); # WARN level

  # add abitrary data to the log entry
  my %hash = (DAY_ONE => 'Monday', DAY_TWO => 'Tuesday', DAY_THREE => 'Wednesday');
  $jnl->send('Here is a message', \%hash); # add abitrary data to the log entry

  # will log "Failed to open file: No such file or directory" and ERRNO=2
  open my $fh, '<', 'nosuchfile'
    or $jnl->perror('Failed to open file');

=head1 DESCRIPTION

=head2 Log Levels

The log levels use by C<journald> and by L</priority> are the same as those
use by C<syslog>, so instead of using numeric priorities you can

  use Sys::Syslog ':macros';

giving you access to the C<LOG_*> L<"level constants"|Sys::Syslog/Levels>

=head1 SEE ALSO

=for :list
* L<Log::Journald>
At some point between me writing this module and getting around to releasing it,
another module was released to write the journal.
* L<systemd|http://www.freedesktop.org/wiki/Software/systemd/>
The main C<systemd> page.
* L<sd-journal(3)>
Man page of the C API
