package ilparser::common::computehead;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/computehead/API";
use lib __DIR__ . "/computehead/src";
use strict;
use warnings;
use computehead;

sub process {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    computehead(\$data);
    select(STDOUT);
    return $result;
}

1;
