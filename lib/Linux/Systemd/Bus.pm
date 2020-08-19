package Linux::Systemd::Bus;

# ABSTRACT: Systemd Bus API

use v5.22;
use strictures 2;
use XSLoader;
use Moo;
use namespace::clean;

XSLoader::load;

sub BUILD {
    _get_system_bus();

    return;
}
sub get_property {
    my ($self, $service_name, $path, $interface, $property) = @_;
    return _get_property_string($service_name, $path, $interface, $property);
}

sub call {

    my ($self, $service, $path, $interface, $method, $return_type, @args) = @_;

    if (!$return_type || $return_type eq 'void') {
        return _call_method_returning_void($service, $path, $interface, $method);
    } elsif ($return_type eq 's') {
        return _call_method_returning_string($service, $path, $interface, $method);
    } elsif ($return_type eq 'a') {
        return _call_method_returning_array($service, $path, $interface, $method);
    }

    # die "Could not handle $method_name";

}

# sub call {
#     use DDP; p @_;
#     my ($self, $service, $interface, $method_name, @args) = @_;
#
#     my $method = $interface->{_definition}->{method}->{$method_name};
#
#     if (!$method) {
#         die 'No such method on interface';
#     }
#
#     if (!@{$method} || $method->[-1]->{direction} ne 'out') {
#         return _call_method_no_return(
#             $service->name,
#             $service->path,
#             $interface->name,
#             $method_name
#         );
#     }
#
#     if ($method->[-1]->{type} eq 's') {
#
#         return _call_method_for_string(
#             $service->name,
#             $service->path,
#             $interface->name,
#             $method_name
#         );
#     }
#
#     die "Could not handle $method_name";
#
# }

1;

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

https://www.freedesktop.org/software/systemd/man/sd-bus.html
