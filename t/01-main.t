use Test::More;
use Linux::Systemd::Journal::Write;

my $jnl = new_ok 'Linux::Systemd::Journal::Write' => [id => 'test'];

ok $jnl->print('flarg'), 'print string';
ok $jnl->print('Hello world', 4), 'print with priority';

ok $jnl->perror('An error was set'), 'perror';

my $hashref = {
    message        => 'Test send a hashref',
    abstract       => 'XS wrapper around sd-journal',
    author         => 'Ioan Rogers <ioanr@cpan.org>',
    dynamic_config => 0,
};

ok $jnl->send($hashref), 'send a hashref';

my $arrayref = [
    message        => 'Test send an arrayref',
    abstract       => 'XS wrapper around sd-journal',
    author         => 'Ioan Rogers <ioanr@cpan.org>',
    dynamic_config => 0,
];
ok $jnl->send($arrayref), 'send an arrayref';

my $arrayref = [
    message        => 'Test send an arrayref',
    abstract       => 'XS wrapper around sd-journal',
    author         => 'Ioan Rogers <ioanr@cpan.org>',
    dynamic_config => 0,
];
ok $jnl->send(
    message        => 'Test send an array',
    abstract       => 'XS wrapper around sd-journal',
    author         => 'Ioan Rogers <ioanr@cpan.org>',
    dynamic_config => 0,
  ),
  'send an array';

ok $jnl->send('I am a string'), 'send a string';

done_testing;
