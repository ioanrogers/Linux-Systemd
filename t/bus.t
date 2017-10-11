use v5.16;
use Test2::V0;

use Linux::Systemd::Bus;

my $bus = Linux::Systemd::Bus->new;

ok my $list = $bus->list, 'got something from list()';
ref_ok $list, 'ARRAY', '...is an array';

ok my $hostname = $bus->get_property(
    'org.freedesktop.hostname1', '/org/freedesktop/hostname1',
    'org.freedesktop.hostname1', 'Hostname'
), 'asked for hostname';

diag "Hostname: $hostname";

ok my $address =
  $bus->get_property('org.bluez', '/org/bluez/hci0', 'org.bluez.Adapter1',
    'Address'), 'got adapter address';
diag "Bluetooth Adapter: $address";

ok my $service = $bus->get_service('org.freedesktop.hostname1', '/org/freedesktop/hostname1');
use DDP;
p $service;

done_testing;
