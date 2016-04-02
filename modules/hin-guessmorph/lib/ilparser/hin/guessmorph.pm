package ilparser::hin::guessmorph;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/guessmorph/API";
use lib __DIR__ . "/guessmorph/src";
use strict;
use warnings;
use guessmorph;

sub process {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    guessmorph(\$data);
    select(STDOUT);
    return $result;
}

1;
