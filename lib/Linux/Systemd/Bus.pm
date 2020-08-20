package Linux::Systemd::Bus;

# ABSTRACT: Systemd Bus API

use v5.22;
use strictures 2;
use XSLoader;
use Moo;
use namespace::clean;

XSLoader::load;

sub get_property {
    my ($self, $type, @args) = @_;

    if ($type eq 'int64') {
        return _get_property_int64(@args);
    } elsif ($type eq 'string') {
        return _get_property_string(@args);
    }

    die "Unhandled propery type: $type";
}

sub call {

    my ($self, $service, $path, $interface, $method, $return_type, @args) = @_;

    if (!$return_type || $return_type eq 'void') {
        return _call_method_returning_void($service, $path, $interface,
            $method);
    } elsif ($return_type eq 's') {
        return _call_method_returning_string($service, $path, $interface,
            $method);
    } elsif ($return_type eq 'a') {
        return _call_method_returning_array($service, $path, $interface,
            $method);
    }

    # die "Could not handle $method_name";
}

1;

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

https://www.freedesktop.org/software/systemd/man/sd-bus.html
