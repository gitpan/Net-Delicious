# $Id: Subscription.pm,v 1.6 2005/12/17 19:04:14 asc Exp $
use strict;

package Net::Delicious::Subscription;
use base qw (Net::Delicious::Object);

$Net::Delicious::Subscription::VERSION = '0.94';

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

use overload q("") => sub { shift->user() };

use Net::Delicious::Constants qw (:uri);

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new(\%args)

Returns a new I<Net::Delicious::Subscription> object. Woot!

=cut

# Defined in Net::Delicious::Object

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

=head2 $obj->as_hashref()

Return the object as a hash ref safe for serializing and re-blessing.

=cut

# Defined in Net::Delicious::Object

sub _properties {
        my $pkg = shift;
        return qw ( user tag );
}

=head1 VERSION

0.94

=head1 DATE

$Date: 2005/12/17 19:04:14 $

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
