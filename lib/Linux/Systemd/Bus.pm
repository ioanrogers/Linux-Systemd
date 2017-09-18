package Linux::Systemd::Bus;

# ABSTRACT: Systemd Bus API

use v5.16;
use strictures 2;
use XSLoader;
use Moo;
use namespace::clean;

XSLoader::load;

sub BUILD {
    _get_system_bus();

    return;
}

sub list {

    # my $self = shift;
    return _list();
}

1;

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

https://www.freedesktop.org/software/systemd/man/sd-bus.html
