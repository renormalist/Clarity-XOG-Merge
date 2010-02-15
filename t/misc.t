use strict;
use warnings;

use XOG::Merge;
use Test::More;
use Test::Deep;

use File::ShareDir qw(module_dir);
use File::Temp qw(tempfile tempdir);

# ----- merge -----

my $srcdir = module_dir('XOG::Merge')."/testfiles";
my $tmpdir = tempdir( CLEANUP => 1 );
my $out_file = "$tmpdir/tmp_OUTFILE.xml";
my $merger = XOG::Merge->new (
                              files => ["$srcdir/QA.xml", "$srcdir/PS.xml", "$srcdir/TJ.xml"],
                              out_file => $out_file
                             );
$merger->Main;

# ----- evaluate result -----
my $counter_Resource          = 0;
my $counter_Project           = 0;
my $counter_CustomInformation = 0;

my @projects = ();

sub cb_Resource {
        $counter_Resource++;
}

sub cb_Project {
        my ($t, $project) = @_;

        my $projectID = $project->att('projectID');
        my $name      = $project->att('name');

        $counter_Project++;
        push @projects, { projectID => $projectID,
                          name      => $name };
}

sub cb_CustomInformation {
        $counter_CustomInformation++;
}

my $twig= XML::Twig->new ( twig_handlers => {
                                             Project           => \&cb_Project,
                                             Resource          => \&cb_Resource,
                                             CustomInformation => \&cb_CustomInformation,
                                            },
                         );
$twig->parsefile( $out_file );
is($counter_Resource, 14, "count result Resource elements");

my @expected_projects = (
                         { projectID => "PRJ-300330",
                           name      => "KRAM Testing"
                         },
                         { projectID => "PRJ-200220",
                           name      => "Turbo Basic"
                         },
                         { projectID => "PRJ-100224",
                           name      => "Eidolon"
                         },
                         { projectID => "PRJ-100222",
                           name      => "International Karate"
                         },
                         { projectID => "PRJ-100223",
                           name      => "Birne"
                         },
                        );

is($counter_Project, 5, "count result Project elements");
cmp_bag(\@projects, \@expected_projects, "expected project elements");

is($counter_CustomInformation, $counter_Project, "have as many CustomInformation as Project elements");

done_testing();
