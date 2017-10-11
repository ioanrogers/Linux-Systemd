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
    is => 'ro',
    required => 1,
);

has method => (
    is => 'ro',
);

has _definition => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

1;
