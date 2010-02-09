package XOG::Merge::Command::merge;

use XOG::Merge -command;
use Data::Dumper;

use 5.010;
use strict;
use warnings;

sub opt_spec {
        return (
                [ "out|o",  "Write result to that file" ],
               );
}

sub validate_args {
        my ($self, $opt, $args) = @_;

        # no args allowed but options!
        $self->usage_error("No args allowed") if @$args;
}

sub execute {
        say STDERR "Affe!";
}

sub run {
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
