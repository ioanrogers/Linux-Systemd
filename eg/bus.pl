#!/usr/bin/env perl

use v5.22;
use warnings;
use Data::Printer;
use Linux::Systemd::Bus::System;

my $bus = Linux::Systemd::Bus::System->new;

# list all names on the bus
for my $name (@{$bus->list_names}) {
    say $name;
}

# get the system hostname
my $hostname = $bus->get_property(
    'string',                     'org.freedesktop.hostname1',
    '/org/freedesktop/hostname1', 'org.freedesktop.hostname1',
    'Hostname'
);
say "Hostname: $hostname";

# find the host's bluetooth address
my $address = $bus->get_property(
    'string',          'org.bluez',
    '/org/bluez/hci0', 'org.bluez.Adapter1',
    'Address'
);
say "Bluetooth Adapter: $address";

# get the unique machine id
say $bus->call(
    'org.freedesktop.hostname1', '/org/freedesktop/hostname1',
    'org.freedesktop.DBus.Peer', 'GetMachineId',
    's'
);
