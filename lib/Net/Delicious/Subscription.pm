package Net::Delicious::Subscription;
use strict;

# $Id: Subscription.pm,v 1.5 2005/04/05 15:56:50 asc Exp $

=head1 NAME

Net::Delicious::Subscription - OOP for del.icio.us subscription thingies

=head1 SYNOPSIS

  use Net::Delicious;
  my $del = Net::Delicious->new({...});

  foreach my $sub ($del->inbox_subscriptions()) {

      # $sub is a Net::Delicious::Subscription
      # object.

      print "$sub\n";
  }

=head1 DESCRIPTION

OOP for del.icio.us subscription thingies.

=head1 NOTES

=over 4

=item *

This package overrides the perl builtin I<stringify> operator and returns the value of the object's I<user> method.

=item *

It isn't really expected that you will instantiate these
objects outside of I<Net::Delicious> itself.

=back

=cut

$Net::Delicious::Subscription::VERSION = '0.1';

use overload q("") => sub { shift->user() };

use Net::Delicious::Constants qw (:uri);

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new(\%args)

Returns a new I<Net::Delicious::Subscription> object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;
    
    my %self = map { 
	$_ => $args->{ $_ };
    } qw ( user tag );

    return bless \%self, $pkg;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->user()

Returns a string.

=cut

sub user {
    my $self = shift;
    return $self->{user};
}

=head2 $obj->tag()

Returns a string.

=cut

sub tag {
    my $self = shift;
    return $self->{tag};
}

=head2 $obj->url()

Returns a string.

=cut

sub url {
    my $self = shift;
    return join("/",URI_DELICIOUS,$self->user(),$self->tag());
}

=head1 VERSION

0.1

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
