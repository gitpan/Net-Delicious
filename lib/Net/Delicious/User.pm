package Net::Delicious::User;
use strict;

# $Id: User.pm,v 1.1 2004/03/04 14:45:46 asc Exp $

=head1 NAME

Net::Delicious::User - OOP for del.icio.us user thingies

=head1 SYNOPSIS

  use Net::Delicious;
  my $del = Net::Delicious->new({...});

  foreach my $post ($del->recent_posts()) {

      my $user = $post->user();
      print $user->name()."\n";
  }

=head1 DESCRIPTION

OOP for del.icio.us user thingies.

=head1 NOTES

=over 4

=item *

This package overrides the perl builtin I<stringify> operator and returns the value of the object's I<name> method.

=item *

It isn't really expected that you will instantiate these
objects outside of I<Net::Delicious> itself.

=back

=cut

$Net::Delicious::User::VERSION = '0.1';

use overload q("") => sub { shift->name() };

=head1 PACKAGE METHODS

=cut

=head1 __PACKAGE__->new(\%args)

Returns a I<Net::Delicious::User> object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;

    my %self = map {
	$_ => $args->{ $_ }
    } qw ( name );

    return bless \%self, $pkg;    
}

=head1 OBJECT METHODS

=cut

=head2 $obj->name()

Returns an string.

=cut

sub name {
    my $self = shift;
    return $self->{name};
}

=head1 VERSION

0.1

=head1 DATE

$Date: 2004/03/04 14:45:46 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

L<Net::Delicious>

=head1 LICENSE

Copyright (c) 2004 Aaron Straup Cope. All rights reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
