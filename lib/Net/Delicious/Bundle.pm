# $Id: Bundle.pm,v 1.3 2005/04/06 04:58:22 asc Exp $
use strict;

=head1 NAME

Net::Delicious::Bundle - OOP for del.icio.us bundle thingies

=head1 SYNOPSIS

  use Net::Delicious;
  my $del = Net::Delicious->new({...});

  foreach my $bundle ($del->bundles()) {

      # $post is a Net::Delicious::Bundle 
      # object.

      print "$bundle\n";
  }

=head1 DESCRIPTION

OOP for del.icio.us bundle thingies.

=head1 NOTES

=over 4

=item *

This package overrides the perl builtin I<stringify> operator and
returns the value of the object's I<name> method.

=item *

It isn't really expected that you will instantiate these
objects outside of I<Net::Delicious> itself.

=back

=cut

package Net::Delicious::Bundle;

use overload q("") => sub { shift->name(); };

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new(\%args)

Returns a I<Net::Delicious::Bundle> object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;

    my %self = map {
	$_ => $args->{ $_ }
    } qw ( name tags );

    return bless \%self, $pkg;     
}

=head1 OBJECT METHODS

=cut

=head2 $obj->name()

Returns a string.

=cut

sub name {
    return shift->{name};
}

=head2 $obj->tags()

Returns a string.

=cut

sub tags {
    my $self = shift;
    my $tags = $self->{tags};

    if (! wantarray) {
	return $tags;
    }

    return split(" ",$tags);
}

=head1 VERSION

0.1

=head1 DATE

$Date: 2005/04/06 04:58:22 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

L<Net::Delicious>

=head1 LICENSE

Copyright (c) 2004-2005 Aaron Straup Cope. All rights reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
