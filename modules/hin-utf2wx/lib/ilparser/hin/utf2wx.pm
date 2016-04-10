package ilparser::hin::wx2utf;
use Dir::Self;
use Data::Dumper;
use strict;
use warnings;

my %daemons = (
    "parser" => {
        "port" => "12004",
        "path" => "converter-indic",
        "args" => "--l hin --s utf --m --daemonize --port"
    }
);

sub call_daemon {
    my ($daemon_name, $input) = @_;
    my $port = $daemons{$daemon_name}{port};
    my ($socket, $client_socket);
    $socket = new IO::Socket::INET (
        PeerHost => '127.0.0.1',
        PeerPort => $port,
        Proto => 'tcp',
    ) or die "ERROR in Socket Creation : $!\n";
    $socket->send("$input\n");
    my $result = "";
    while (my $line = $socket->getline) {
        $result .= $line;
    }
    $socket->close();
    return $result;
}

sub run_daemons {
    my @daemon_names = @_;
    foreach my $daemon_name (@daemon_names) {
        my %daemon = %{$daemons{$daemon_name}};
        my $cmd = "$daemon{path} $daemon{args} $daemon{port} &";
        my $runfile = __DIR__ . "/run/${daemon_name}_$daemon{port}";
        system("flock -e -w 0.01 $runfile -c '$cmd'") == 0
            or warn "[" . __PACKAGE__ . "]: Port $daemon{port} maybe unavailable! $?\n";
    }
}

sub process {
    my %args = @_;
    utf8::encode($args{data});
    my $result = call_daemon("wx2utf", $args{data});
    utf8::decode($result);
    return $result;
}

run_daemons(("parser"));

1;
