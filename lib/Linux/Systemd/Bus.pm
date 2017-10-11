package Linux::Systemd::Bus;

# ABSTRACT: Systemd Bus API

use v5.16;
use strictures 2;
use Linux::Systemd::Bus::Service;
use XML::LibXML;
use XSLoader;
use Moo;
use namespace::clean;

XSLoader::load;

sub BUILD {
    _get_system_bus();

    return;
}

sub list {
    return _list();
}

sub get_service {
    my ($self, $service_name, $path) = @_;

    my $service = Linux::Systemd::Bus::Service->new(
        _bus => $self,
        name => $service_name,
        path => $path,
    );

    return $service;
}

sub get_property {
    my ($self, $service_name, $path, $interface, $property) = @_;
    return _get_property_string($service_name, $path, $interface, $property);
}

1;

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

https://www.freedesktop.org/software/systemd/man/sd-bus.html
