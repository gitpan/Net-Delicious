package Net::Delicious::Tag;
use strict;

# $Id: Tag.pm,v 1.7 2005/04/05 15:56:50 asc Exp $

=head1 NAME

Net::Delicious::Tag - OOP for del.icio.us tag thingies

=head1 SYNOPSIS

  use Net::Delicious;
  my $del = Net::Delicious->new({...});

  foreach my $tag ($del->tags()) {

      # $tag is a Net::Delicious::Tag 
      # object.

      print "$tag\n";
  }

=head1 DESCRIPTION

OOP for del.icio.us tag thingies.

=head1 NOTES

=over 4

=item *

This package overrides the perl builtin I<stringify> operator and returns the value of the object's I<tag> method.

=item *

It isn't really expected that you will instantiate these
objects outside of I<Net::Delicious> itself.

=back

=cut

$Net::Delicious::Tag::VERSION = '0.2';

use overload q("") => sub { shift->tag() };

=head1 PACKAGE METHODS

=cut

=head1 __PACKAGE__->new(\%args)

Returns a I<Net::Delicious::Tag> object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;

    my %self = map {
	$_ => $args->{ $_ }
    } qw ( tag count );

    return bless \%self, $pkg; 
}

=head1 OBJECT METHODS

=cut

=head2 $obj->count()

Returns an int.

=cut

sub count {
    my $self = shift;
    return $self->{count};
}

=head2 $obj->tag()

Returns an string.

=cut

sub tag {
    my $self = shift;
    return $self->{tag};
}

=head1 VERSION

0.2

=head1 DATE

$Date: 2005/04/05 15:56:50 $

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
