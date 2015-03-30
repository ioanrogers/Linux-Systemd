package Linux::Systemd::Journal::Read;

# ABSTRACT: Read from systemd journals

# TODO make sure all text is utf8

use v5.10.2;
use Moo;
use Carp;
use XSLoader;
XSLoader::load;

sub DEMOLISH {
    __close();
}

sub BUILD {
    return __open();
}

=method c<get_usage>

Returns the number of bytes used by the open journal

=method C<seek_head>

Seeks to the start of the open journal.

=cut

sub seek_head {
    my $self = shift;
    __seek_head();
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
    __next();
    return 1;
}

=method C<get_data($field)>

Returns the value of C<$field> from the current record.

See L<systemd.journal-fields(7)> for a list of well-known fields.

=cut

sub get_data {
    my ($self, $field) = @_;
    return __get_data($field);
}

=method C<get_entry>

Returns a hashref of all the fields in the current entry.

This method is not a direct wrap of the journal API.

=cut

=method C<get_next_entry>

Convenience wrapper which calls L</next> before L</get_entry>

This method is not a direct wrap of the journal API.

=cut

sub get_next_entry {
    my $self = shift;

    if ($self->next) {
        return $self->get_entry;
    }

    return;
}

# TODO
# sd_journal_add_match(), sd_journal_add_disjunction() and sd_journal_add_conjunction(
# wrap these so we can specify a either a search string, like:
# match(PRIORITY=5 NOT SYSLOG_IDENTIFIER=KERNEL)
# or maybe something like...
# match(priority => 5, syslog_identifier => 'KERNEL')->not(something => idontwant)

sub _match {
    my $self = shift;

    # matches will be an array of [key, value] arrayrefs
    my @matches;

    if (scalar @_ == 1 && ref $_[0]) {

        my $ref = ref $_[0];
        if ($ref eq 'ARRAY') {

            # already an arrayref
            push @matches, $_[0];
        } elsif ($ref eq 'HASH') {

            # hashref, convert to array
            my @array = map { $_ => $_[0]->{$_} } keys %{$_[0]};
            push @matches, \@array;
        }
    } elsif (scalar @_ % 2 == 0) {
        say "even sized list";
        while (@_) {
            push @matches, [shift, shift];
        }
    }

    croak 'Invalid params' unless @matches;

    use Data::Printer;

    # $key = uc $key;
    foreach my $pair (@matches) {
        p $pair;
        __add_match(uc($pair->[0]) . "=" . $pair->[1]);
    }
}

=method C<match(field => value)>


=cut

sub match {
    my $self = shift;
    return $self->_match(@_);
}

=method C<match_and(field => value)>


=cut

sub match_and {
    my $self = shift;
    __match_and();
    return $self->_match(@_);
}

=method C<match_or(field => value)>


=cut

sub match_or {
    my $self = shift;
    __match_or();
    return $self->_match(@_);
}

=method C<flush_matches>

Clears the match filters.

=cut

1;
