package Linux::Systemd::Bus::Service;

# ABSTRACT: DBUS Service

use v5.16;
use strictures 2;
use namespace::clean;
use Moo;

has _bus => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has name => (
    is => 'ro',
    required => 1,
);

has path => (
    is => 'ro',
    required => 1,
);

has _definition => (
    is       => 'lazy',
);

sub _build__definition {
    my $self = shift;
    return $self->introspect;
}

sub _get_methods {
    my $interface_node = shift;

    my $method = {};
    for my $method_node ($interface_node->findnodes('method')) {
        my $method_name = $method_node->getAttribute('name');
        $method->{$method_name} = [];
        for my $arg_node ($method_node->findnodes('arg')) {
            my $arg = {
                type      => $arg_node->getAttribute('type'),
                direction => $arg_node->getAttribute('direction'),
            };

            $arg->{name} = $arg_node->getAttribute('name')
              if $arg_node->getAttribute('name');
            push @{$method->{$method_name}}, $arg;
        }
    }
    return $method;
}

sub _get_properties {
    my $interface_node = shift;
    my $p = {};
    for my $node ($interface_node->findnodes('property')) {

        my $name = $node->getAttribute('name');
        $p->{$name} = {
            type   => $node->getAttribute('type'),
            access => $node->getAttribute('access'),
        };

        for my $annotation_node ($node->findnodes('annotation')) {
            $p->{$name}->{annotations}->{$annotation_node->getAttribute('name')} =
              $annotation_node->getAttribute('value');

        }
    }

    return $p;
}

sub _get_signals {
    my $interface_node = shift;
    my $s = {};
    for my $node ($interface_node->findnodes('signal')) {
        my $name = $node->getAttribute('name');
        $s->{$name} = [];

        for my $arg_node ($node->findnodes('arg')) {
            my $arg = {
                type      => $arg_node->getAttribute('type'),
            };

            $arg->{name} = $arg_node->getAttribute('name')
              if $arg_node->getAttribute('name');

            push @{$s->{$name}}, $arg;
        }
    }

    return $s;
}

sub introspect {
    my $self = shift;

    my $dom = XML::LibXML->load_xml(
        load_ext_dtd => 0,
        string       => Linux::Systemd::Bus::_introspect($self->name, $self->path));

    my $interface;
    for my $interface_node ($dom->findnodes('/node/interface')) {

        my $interface_name = $interface_node->findvalue('@name');

        next unless $interface_name;

        $interface->{$interface_name} = {
            method   => _get_methods($interface_node),
            property => _get_properties($interface_node),
            signal   => _get_signals($interface_node),
        };
    }

    return $interface;
}

sub interfaces {
    my $self = shift;
    return [ sort keys %{$self->_definition} ];
}

sub get_interface {
    my ($self, $interface) = @_;

    die 'No such interface' unless $self->_definition->{$interface};

    require Linux::Systemd::Bus::Interface;


    return Linux::Systemd::Bus::Interface->new(
        _service => $self,
        _definition => $self->_definition->{$interface},
        name => $interface,
    );

}

1;
