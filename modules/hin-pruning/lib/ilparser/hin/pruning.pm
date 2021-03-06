package ilparser::hin::pruning;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/pruning/API";
use lib __DIR__ . "/pruning/src";
use strict;
use warnings;
use prune;

sub process {
    my %par = @_;
    my $data = $par{'data'};
    my $result;
    my $db_file = __DIR__ . "/pruning/mapping.dat";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    prune($db_file, \$data);
    select(STDOUT);
    return $result;
}

1;
