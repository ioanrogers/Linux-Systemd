package Linux::Systemd::Bus::System;

# ABSTRACT: Talk to the system DBus with systemd

use v5.22;
use Moo;
use namespace::autoclean;

extends 'Linux::Systemd::Bus';

sub BUILD {
    Linux::Systemd::Bus::_get_system_bus();
    return;
}

1;
