package XOG::Command::merge;

use 5.010;
use strict;
use warnings;

use XOG -command;
use XOG::Merge;

use Data::Dumper;

sub opt_spec
{
        (
         [ "out|o=s",  "Write result to that file", { default => "XOGMERGE.out" } ],
        );
}

sub abstract { "merge several files" }

sub validate_args {
        my ($self, $opt, $args) = @_;

        # no args allowed but options!
        $self->usage_error("No args allowed") if @$args;
}

sub execute {
        my ($self, $opt, $args) = @_;

        print STDERR "opt:  ", Dumper($opt);
        print STDERR "args: ", Dumper($args);

        my $out_file = $opt->{out} || 't/xog-out.xml';
        my $files    = $args || ['t/QA.xml', 't/PS.xml', 't/TJ.xml'];

        my $merger = XOG::Merge->new
            (
             files    => $files,
             out_file => $out_file
            );
        $merger->Main;
}

1;
