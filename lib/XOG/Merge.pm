use MooseX::Declare;

use 5.010;

class XOG::Merge {

        use XML::Twig;
        use Data::Dumper;

        has files                => ( is => "rw", isa => "ArrayRef", default => sub {[]}, auto_deref => 1 );
        has projectids           => ( is => "rw", isa => "HashRef",  default => sub {{}} );
        has buckets              => ( is => "rw" );
        has cur_file             => ( is => "rw" );
        has cur_proj             => ( is => "rw" );
        has out_file             => ( is => "rw", default => "OUTFILE.xml" );
        has ALWAYSBUCKETS        => ( is => "rw", default => 1 );

        sub TEMPLATE_HEADER {
                q#
<!-- edited with Emacs 23 (http://emacswiki.org) by cris (na) -->
<!--XOG XML from CA is prj_projects_alloc_act_etc_read.  Emptied by Sunday School Teacher to act as template. -->
<NikuDataBus xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../xsd/nikuxog_project.xsd">
	<Header action="write" externalSource="NIKU" objectType="project" version="7.5.0" WE_ARE_TEMPLATE="YES"/>
	<Projects>
#
        }

        sub TEMPLATE_FOOTER {
                q#
	</Projects>
</NikuDataBus>
#
        }

        sub cb_Collect_Project
        {
                my ($t, $project) = @_;
                my $self = $t->{_self};

                my $projectID = $project->att('projectID');
                my $name      = $project->att('name');

                $self->projectids->{$projectID}{files}{$self->cur_file}++;
        }

        method prepare {
                # prepare temp dirs
                # open FINAL
        }

        method finish
        {
                # close FINAL;
                # cleanup temp dirs
        }

        method pass1_count
        {
                foreach my $f ($self->files) {
                        $self->cur_file( $f );
                        my $twig= XML::Twig->new
                            ( twig_handlers =>
                              { 'Projects/Project' => \&cb_Collect_Project } );
                        $twig->{_self} = $self;
                        $twig->parsefile( $f );
                }
        }

        method add_project_to_final ($project)
        {
                my $projectID = $project->att('projectID');
                my $name      = $project->att('name');

                # say STDERR "add_project_to_final: $projectID ($name)";
                $project->set_pretty_print( 'indented');     # \n before tags not part of mixed content
                $project->print(\*XOGMERGEOUT);
        }

        method add_project_to_bucket ($project)
        {
                my $projectID  = $project->att('projectID');
                my $bucketfile = "bucket-$projectID.tmp";

                $self->buckets->{$bucketfile} = 1;
                open XOGMERGEBUCKET, ">>", $bucketfile or die "Cannot open bucket file ".$bucketfile.": $!";
                $project->print(\*XOGMERGEBUCKET);
                close XOGMERGEBUCKET;
        }

        method prepare_output
        {
                open XOGMERGEOUT, ">", $self->out_file or die "Cannot open out file ".$self->out_file.": $!";
                print XOGMERGEOUT TEMPLATE_HEADER;
        }

        method clean_old_buckets {
                system ("rm -f bucket-*.tmp");
                $self->buckets({});
        }

        method finish_output
        {
                print XOGMERGEOUT TEMPLATE_FOOTER;
                close XOGMERGEOUT;
        }

        sub cb_Save_Project
        {
                my ($t, $project) = @_;
                my $self = $t->{_self};

                my $projectID = $project->att('projectID');
                my $name      = $project->att('name');

                #say STDERR "cb_Save_Project: $projectID ($name)";

                if ($self->ALWAYSBUCKETS or keys %{$self->projectids->{$projectID}{files}} > 1)
                {
                        # do this always (without surrounding if/else
                        # if single-org-projects rarely occur
                        $self->add_project_to_bucket($project);
                }
                else
                {
                        $self->add_project_to_final($project);
                }
        }

        sub cb_Open_Project
        {
                my ($t, $project) = @_;
                my $self = $t->{_self};

                # debug
                my $projectID = $project->att('projectID');
                my $name      = $project->att('name');
                # say STDERR "cb_Save_Project: $projectID ($name)";

                unless ($self->cur_proj) {
                        my $resources = XML::Twig::Elt->new('Resources');
                        $resources->paste( $resources );
                        $self->cur_proj( $project );
                }
        }

        sub cb_Save_Resource
        {
                my ($t, $resource) = @_;
                my $self = $t->{_self};

                my $resourceID = $resource->att('resourceID');
                # say STDERR "cb_Save_Resource: $resourceID";

                my $resources = $self->cur_proj->first_child('Resources');
                my $res = $resource->copy;
                $res->paste($resources);
                #say XOGMERGEOUT "\n*** XOGMERGEOUT-cb_Save_Resource: $resourceID";
                #$res->print(\*XOGMERGEOUT);
        }

        method fix_cur_file
        {
                my $f = $self->cur_file;
                system "echo '<Projects>' > xyz";
                system "cat $f >> xyz";
                system "echo '</Projects>' >> xyz";
                system "cat xyz > $f";
        }

        method add_buckets_to_final
        {
                # say STDERR "Find buckets...";
                foreach my $bucket (keys %{$self->buckets})
                {
                        # say STDERR "bucket: $bucket";
                        $self->cur_file( $bucket );
                        $self->fix_cur_file;
                        $self->cur_proj( undef );
                        my $twig= XML::Twig->new (
                                                  start_tag_handlers => { "Project"  => \&cb_Open_Project },
                                                  twig_handlers      => { "Resource" => \&cb_Save_Resource },
                                                 );
                        $twig->{_self} = $self;
                        $twig->parsefile( $bucket );
                        $self->add_project_to_final($self->cur_proj);
                        # WEITER
                }
        }

        method pass2_merge
        {
                $self->prepare_output;
                $self->clean_old_buckets;
                foreach my $f ($self->files)
                {
                        $self->cur_file( $f );
                        my $twig= XML::Twig->new (twig_handlers => { 'Projects/Project' => \&cb_Save_Project });
                        $twig->{_self} = $self;
                        $twig->parsefile( $f );
                }
                $self->add_buckets_to_final;
                $self->finish_output;
        }

        method Main
        {
                $self->prepare;
                $self->pass1_count;
                $self->pass2_merge;
                $self->finish();
                #print "\n"; # XXX: needed as long as it spits out output and confuses TAP
                # print Dumper($self->projectids);
        }

}

# help the CPAN indexer
package XOG::Merge;
our $VERSION = '0.01';

1; # End of XOG::Merge

__END__

=pod

=head1 NAME

XOG::Merge - Merge several Clarity XML Open Gateway files

=head1 SYNOPSIS

Merge several Clarity XOG ("XML Open Gateway") files into one

    use XOG::Merge;
    my $merger = XOG::Merge->new();
    # ...

=head1 AUTHOR

Steffen Schwigon, C<< <ss5 at renormalist.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xog-merge at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XOG-Merge>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XOG::Merge

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XOG-Merge>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XOG-Merge>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XOG-Merge>

=item * Search CPAN

L<http://search.cpan.org/dist/XOG-Merge/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2010 Sunday School Teacher, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

