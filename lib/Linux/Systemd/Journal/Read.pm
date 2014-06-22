package Linux::Systemd::Journal::Read;

# ABSTRACT: Read from systemd journals

# TODO make sure all text is utf8

use v5.10.1;
use Moo;
use Carp;
use XSLoader;
XSLoader::load;

sub BUILD {
    my $self = shift;
    return __open();
}

sub DEMOLISH { __close() }

=method c<get_usage>

Returns the number of bytes used by the open journal

=method C<seek_head>

Seek to the start of the open journal.

=method C<seek_head>

Seeks to the end of the open journal.

=method C<next>

Moves to the next record.

=method C<get_data($field)>

Returns the value of C<$field> from the current record.

See L<systemd.journal-fields(7)> for a list of well-known fields.

=method C<get_entry>

Returns a hashref of all the fields in the current entry.

This method is not a direct wrap of the journal API.

=method C<get_next_entry>

Moves the cursor to the next record and returns it.

This method is not a direct wrap of the journal API.

=cut

# TODO find out how to call other XS subs from XS and move this into Read.xs
sub get_next_entry {
    my $self = shift;

    if ($self->next) {
        return $self->get_entry;
    }

    return;
}

1;
