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
         [ "out|o=s",    "Write result to that file", { default => "XOGMERGE.xml" } ],
         [ "verbose|v",  "Be verbose",                { default => 0 } ],
         [ "debug|d",    "Output debugging info",     { default => 0 } ],
        );
}

sub abstract { "merge several files" }

sub description {

        "This merge will merge Clarity project files.

You either specify the files to merge or by default it finds all files
of name 'YYMM_XX.xml' where YY=year, MM=month, XX is the source (TJ
for TaskJuggler, PS for Project Server and QA for QA tool).

";
}

sub validate_args {
        my ($self, $opt, $args) = @_;

        # no-op
}

sub find_local_project_files {
        my ($self, $opt, $args) = @_;

        # YYMM_XX.xml
        # where
        #       YY = year,
        #       MM = month,
        #       XX is the source
        # (TJ for TaskJuggler,
        #  PS for Project Server and
        #  QA for QA tool)

        my @files = grep { /\d{2}[01]\d_(TJ|PS|QA)\.xml/i } File::Find::Rule->file()->name( '????_??.*' )->in( "." );
        if ($opt->{verbose}) {
                say "Merge files:";
                say "  $_" foreach @files;
        }
        return \@files;
}

sub execute {
        my ($self, $opt, $args) = @_;

        print STDERR "opt:  ", Dumper($opt)  if $opt->{debug};
        print STDERR "args: ", Dumper($args) if $opt->{debug};

        my $out_file = $opt->{out} || 't/xog-out.xml';
        my $files    = scalar @$args ? $args : $self->find_local_project_files($opt, $args);

        my $merger = XOG::Merge->new
            (
             files    => $files,
             out_file => $out_file,
             verbose  => $opt->{verbose},
             debug    => $opt->{debug},
            );
        $merger->Main;
}

1;
