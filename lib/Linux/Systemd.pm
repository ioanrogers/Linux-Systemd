package Linux::Systemd;

use v5.16;

# ABSTRACT: Bindings for C<systemd> APIs

1;

=head1 DESCRIPTION

The following C<systemd> components are wrapped to some to degree.

=head2 Journal

To log to the journal, see L<Linux::Systemd::Journal::Write>.

To read from the journal, see L<Linux::Systemd::Journal::Read>.

=head2 Daemon

To report status and use service watchdogs, see L<Linux::Systemd::Daemon>.
