use MooseX::Declare;

class XOG::Merge {

        use XML::Twig;
        use Data::Dumper;

        has files => ( is  => "rw", default => sub { [qw't/IM_write.xml'] } );

        sub Project
        {
                my( $t, $project) = @_;
        }

        sub AllocCurve
        {
                my( $t, $alloc)= @_;
                $alloc->erase;
        }

        method Main
        {
                my $twig= XML::Twig->new
                    ( twig_handlers => {
                                        'doc'            => \&doc,
                                        'Projects/Project' => \&Project,
                                        'AllocCurve'        => \&AllocCurve,
                                       }
                    );

                $twig->parsefile( $self->files->[0] ); # build the twig
                $twig->set_pretty_print( 'nice');     # \n before tags not part of mixed content
                $twig->print;
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

