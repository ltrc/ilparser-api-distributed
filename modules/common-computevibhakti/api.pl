use strict;
use warnings;
use Data::Dumper;
use Graph::Directed;
use JSON;
use lib qw(lib);
use List::Util qw(reduce);
use Mojolicious::Lite;
use Mojo::Redis2;
use ilparser::common::computevibhakti;
use Mojo::Pg;

app->config(hypnotoad => {listen => ['http://*:80']});

my $pg = Mojo::Pg->new('postgresql://ddag:nlprocks@localhost/pipelines');

my $modulename = "common.computevibhakti";
helper redis => sub {
    state $r = Mojo::Redis2->new(url => "redis://redis:6379");
};

$pg->migrations->name('nlp')->from_string(<<EOF)->migrate;
-- 1 up
create unlogged table jobs (jobid text, modid text, module text, data text);
-- 1 down
drop table jobs;
EOF

my $bool = $pg->auto_migrate;
$pg      = $pg->auto_migrate($bool);

# If input is only from one module, put it in 'data',
# other wise remove the identifiers and ship 'em ;-)
sub process {
    my $hash = $_[0];
    my %newhash;
    if (keys %{$hash} == 1) {
        %newhash = (data => (%{$hash})[1]);
    } else {
        @newhash{ map { s/_[^_]*$//r } keys %{$hash} } = values %{$hash};
    }
    return ilparser::common::computevibhakti::process(%newhash);
}

sub genError {
    my $c = shift;
    my $error = shift;
    $c->render(json => to_json({Error => $error}), status => 400);
}

sub genDAGGraph {
    my %edges = %{$_[0]};
    my $g = Graph::Directed->new();
    foreach my $from (keys %edges) {
        foreach my $to (@{$edges{$from}}) {
            $g->add_edge($from, $to);
        }
    }
    return $g;
}

post '/pipeline' => sub {
    my $c = shift;
    my $ilparser_json = decode_json($c->req->body);
    my $ilparser_modid = $ilparser_json->{modid} || genError($c, "No ModuleID Specified!") && return;
    my $ilparser_jobid = $ilparser_json->{jobid} || genError($c, "No JobID Specified!") && return;
    my $ilparser_data = $ilparser_json->{data} || genError($c, "No Data Specified!") && return;
    my $ilparser_dag = genDAGGraph($ilparser_json->{edges});
    genError($c, "Edges not specified!") && return if (!$ilparser_dag);
    my $ilparser_module = $modulename . '_' . $ilparser_modid;
    my @ilparser_inputs = map {@$_[0]} $ilparser_dag->edges_to($ilparser_module);
    my $db = $pg->db;
    foreach (@ilparser_inputs) {
        utf8::encode($ilparser_data->{$_});
	$db->query('insert into jobs (jobid, modid, module, data) values (?, ?, ?, ?)', $ilparser_jobid, $ilparser_modid, $_, $ilparser_data->{$_}) if $ilparser_data->{$_};
    }
    my %content;
    my $results = $db->query('select * from jobs where jobid = (?) and modid = (?)', $ilparser_jobid, $ilparser_modid);
    while (my $next = $results->hash) {
        utf8::decode($next->{data});
        $content{$next->{module}} = $next->{data};
    }
    if (@ilparser_inputs == keys %content) {
        $c->render(json => "{Response: 'Processing...'}", status => 202);
        my $ilparser_output = process(\%content);
        $ilparser_data->{$ilparser_module} = $ilparser_output;
	%{$ilparser_data} = (%{$ilparser_data}, %content);
        my @tmp = $ilparser_dag->edges_from($ilparser_module);
        my @ilparser_next = map {@$_[1]} $ilparser_dag->edges_from($ilparser_module);
        if (@ilparser_next) {
            foreach (@ilparser_next) {
                my @module_info = split(/_([^_]+)$/, $_);
                my $next_module = $module_info[0];
                $ilparser_json->{modid} = $module_info[1];
                $c->ua->post("http://$next_module/pipeline" => json
                    => from_json(encode_json($ilparser_json), {utf8 => 1}) => sub {
                        my ($ua, $tx) = @_;
                        my $msg = $tx->error ? $tx->error->{message} : $tx->res->body;
                        $c->app->log->debug("[$ilparser_jobid]: $msg\n");
                    });
            }
        } else {
            $c->redis->publish($ilparser_jobid => encode_json($ilparser_json));
        }
    } else {
        $c->render(json => "{Response: 'Waiting for more inputs...'}", status => 202);
    }
};

app->start;
