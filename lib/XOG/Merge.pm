use MooseX::Declare;

use 5.010;

class XOG::Merge {

        use XML::Twig;
        use Data::Dumper;

        has files                => ( is => "rw", isa => "ArrayRef", default => sub {[]}, auto_deref => 1 );
        has projectids           => ( is => "rw", isa => "HashRef",  default => sub {{}} );
        has cur_file             => ( is => "rw" );
        has out_file             => ( is => "rw", default => "OUTFILE.xml" );

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

        method add_project_to_final ($el)
        {
                #$el->set_pretty_print( 'indented');     # \n before tags not part of mixed content
                $el->print(\*XOGMERGEOUT);
        }

        method prepare_output
        {
                open XOGMERGEOUT, ">", $self->out_file
                    or die "Cannot open out file ".$self->out_file.": $!";
                print XOGMERGEOUT TEMPLATE_HEADER;
        }

        method finish_output
        {
                print XOGMERGEOUT TEMPLATE_FOOTER;
                close XOGMERGEOUT;
        }

        method pass2_merge
        {
                $self->prepare_output;
                for (my $i=0; $i<1000_000; $i++)
                {
                        # prepare project
                        my $el = XML::Twig::Elt->new("Project");
                        $el->set_att("projectID", "PRJ-".(100_000+$i));
                        $el->set_att("name", "project$i");
                        $self->add_project_to_final($el);
                }
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

