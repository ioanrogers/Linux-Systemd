#!/usr/bin/env perl

use v5.16;
use warnings;

use Linux::Systemd::Bus;

my $bus = Linux::Systemd::Bus->new;

# # for my $name (@{$bus->list}) {
# #     say $name;
# # }
#
# # my $service = $bus->get_service('org.freedesktop.systemd1');
# # p $service
#
# my $hostname = $bus->get_property(
#     'org.freedesktop.hostname1', '/org/freedesktop/hostname1',
#     'org.freedesktop.hostname1', 'Hostname'
# );
# say "Hostname: $hostname";
#
# my $address =
#   $bus->get_property('org.bluez', '/org/bluez/hci0', 'org.bluez.Adapter1',
#     'Address');
# say "Bluetooth Adapter: $address";

# $bus->introspect('org.freedesktop.hostname1', '/org/freedesktop/hostname1');

use DDP;
my $service = $bus->get_service('org.freedesktop.hostname1', '/org/freedesktop/hostname1');
p $service;
p $service->interfaces;
my $interface = $service->get_interface('org.freedesktop.hostname1');
p $interface;
