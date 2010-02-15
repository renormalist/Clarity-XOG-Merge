package XOG::Command::merge;

use 5.010;
use strict;
use warnings;

use XOG -command;
use XOG::Merge;

use Data::Dumper;
use File::Find::Rule;

sub opt_spec
{
        (
         [ "out|o=s",    "Write result to that file", { default => "XOGMERGE.out" } ],
         [ "verbose|v",  "Be verbose",                { default => 0 } ],
         [ "debug|d",    "Output debugging info",     { default => 0 } ],
        );
}

sub abstract { "merge several files" }

sub validate_args {
        my ($self, $opt, $args) = @_;

}

sub wanted_project_file {
        
}

sub find_local_project_files {
        # YYMM_XX.xml
        # where
        #       YY = year,
        #       MM = month,
        #       XX is the source
        # (TJ for TaskJuggler,
        #  PS for Project Server and
        #  QA for QA tool)

        my @files = File::Find::Rule->file()->name( '*.xml' )->in( "." );
        return;#('t/QA.xml', 't/PS.xml', 't/TJ.xml');
}

sub execute {
        my ($self, $opt, $args) = @_;

        print STDERR "opt:  ", Dumper($opt)  if $opt->{debug};
        print STDERR "args: ", Dumper($args) if $opt->{debug};

        my $out_file = $opt->{out} || 't/xog-out.xml';
        my @files    = @$args || $self->find_local_project_files;

        my $merger = XOG::Merge->new
            (
             files    => \@files,
             out_file => $out_file,
             verbose  => $opt->{verbose},
             debug    => $opt->{debug},
            );
        $merger->Main;
}

1;
