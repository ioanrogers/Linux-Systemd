package Linux::Systemd::Bus::Session;

# ABSTRACT: Talk to the session DBus with systemd

use v5.22;
use Moo;
use namespace::autoclean;

extends 'Linux::Systemd::Bus';

sub BUILD {
    Linux::Systemd::Bus::_get_session_bus();
    return;
}

1;
