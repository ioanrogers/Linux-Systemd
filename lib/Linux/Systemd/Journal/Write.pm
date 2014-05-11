package Linux::Systemd::Journal::Write;
$Linux::Systemd::Journal::Write::VERSION = '0.001';
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


has app_id => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        require File::Basename;
        return File::Basename::basename($0);
    },
);


has priority => (is => 'ro', lazy => 1, default => 6);


sub print {
    my ($self, $msg, $pri) = @_;
    $pri = $self->priority if !$pri;
    __sd_journal_print($pri, $msg);
    return 1;
}


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


sub perror {
    __sd_journal_perror($_[1]);
    return 1;
}

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Ioan Rogers

=head1 NAME

Linux::Systemd::Journal::Write - XS wrapper around sd-journal

=head1 VERSION

version 0.001

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

=head1 ATTRIBUTES

=head2 C<app_id>

Will be used to set C<SYSLOG_IDENTIFIER>. Defaults to basename($0);

=head2 C<priority>

Default log priority

=head1 METHODS

=head2 C<print($msg, $pri)>

$msg should be either a string. $pri is optional, and defaults to $self->priority

=head2 C<send($msg_or_data, $data?)>

If there is one arg, it may be a simple string to log. Or, it could be a hashref
 or an arrayref. In this case, one of the keys sent MUST be 'message'.

If there are two args, the first must be the string to use as a message, the
second a hashref or arrayref. In this case, a key called message should not be
set.

Finally, C<send> can also be called with an array of key => values, one of which
must be message.

Keys will be uppercased.

=head2 C<perror($msg)>

Logs the string of the current set C<errno>, prefixed with C<$msg>.

=head1 BUGS AND LIMITATIONS

You can make new bug reports, and view existing ones, through the
web interface at L<https://github.com/ioanrogers/Linux-Systemd-Journal/issues>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<https://metacpan.org/module/Linux::Systemd::Journal/>.

=head1 SOURCE

The development version is on github at L<http://github.com/ioanrogers/Linux-Systemd-Journal>
and may be cloned from L<git://github.com/ioanrogers/Linux-Systemd-Journal.git>

=head1 AUTHOR

Ioan Rogers <ioanr@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Ioan Rogers.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut
