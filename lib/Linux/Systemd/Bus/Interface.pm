package Linux::Systemd::Bus::Interface;

# ABSTRACT: DBUS Service Interface

use v5.16;
use strictures 2;
use namespace::clean;
use Moo;

has _service => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has name => (
    is       => 'ro',
    required => 1,
);

has method => (is => 'ro',);

has _definition => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub call {
    my ($self, $method, @args) = @_;
    use DDP;
    p @args;
    return $self->_service->_bus->call($self->_service, $self, $method);
}

sub get {
    my $self = shift;

    return $self->_service->_bus->get_property($self->_service->name,
        $self->_service->path, $self->name, $_[0],);
}

1;
