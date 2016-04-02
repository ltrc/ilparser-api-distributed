package ilparser::hin::tokenizer;
use strict;
use warnings;
use Dir::Self;
use Data::Dumper;

my %daemons = (
    "tokenizer" => {
        "path" => "ind-tokz",
        "args" => "--l hin --s --daemonize --port",
        "port" => "12001"
    }
);

sub process {
    my %args = @_;
    utf8::encode($args{data});
    my $sentences = call_daemon("tokenizer", $args{data});
    open INFILE, '<', \$sentences or die $!;
    my $result = "";
    my $ctr = 0;
    while (my $line = <INFILE>) {
        $ctr ++;
        $result .= "<Sentence id=\"$ctr\">\n";
        my @words = split ' ', $line;
        foreach my $index (0..$#words) {
            $result .= $index + 1 . "\t$words[$index]\tunk\n";
        }
        $result .= "</Sentence>";
    }
    close INFILE;
    utf8::decode($result);
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

run_daemons(("tokenizer"));

1;
