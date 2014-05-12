package Linux::Systemd::Journal::Read;

# ABSTRACT: Read from systemd journals

# TODO make sure all text is utf8

use v5.10.2;
use Moo;
use Carp;
use XSLoader;
XSLoader::load;

sub DEMOLISH {
    __close($_[0]->_j);
}

has _j => (
    is      => 'ro',
    lazy    => 1,
    default => sub { __open() },
);

=method c<get_usage>

Returns the number of bytes used by the open journal

=cut

sub get_usage {
    my $self = shift;
    return __get_usage($self->_j);
}

=method C<seek_head>

Seeks to the start of the open journal.

=cut

sub seek_head {
    my $self = shift;
    __seek_head($self->_j);
    return 1;
}

=method C<seek_head>

Seeks to the end of the open journal.

=cut

sub seek_tail {
    my $self = shift;
    __seek_tail($self->_j);
    return 1;
}

=method C<next>

Moves to the next record.

=cut

sub next {
    my $self = shift;
    __next($self->_j);
    return 1;
}

=method C<get_data($field)>

Returns the value of C<$field> from the current record.

See L<systemd.journal-fields(7)> for a list of well-known fields.

=cut

sub get_data {
    my ($self, $field) = @_;
    return __get_data($self->_j, $field);
}

=method C<get_entry>

Returns a hashref of all the fields in the current entry.

This method is not a direct wrap of the journal API.

=cut

sub get_entry {
    my $self = shift;
    return __get_entry($self->_j);
}

1;
