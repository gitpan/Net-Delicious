package Net::Delicious::Date;
use strict;

# $Id: Date.pm,v 1.5 2005/04/05 15:56:50 asc Exp $

=head1 NAME

Net::Delicious::Date - OOP for del.icio.us date thingies

=head1 SYNOPSIS

  use Net::Delicious;
  my $del = Net::Delicious->new({...});

  foreach my $dt ($del->post_per_date({...})) {

      # $dt is a Net::Delicious::Date
      # object.

      print "$dt\n";
  }

=head1 DESCRIPTION

OOP for del.icio.us date thingies.

=head1 NOTES

=over 4

=item *

This package overrides the perl builtin I<stringify> operator and returns the value of the object's I<count> method.

=item *

It isn't really expected that you will instantiate these
objects outside of I<Net::Delicious> itself.

=back

=cut

$Net::Delicious::Date::VERSION = '0.1';

use overload q("") => sub { shift->count() };

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new(\%args)

Returns a I<Net::Delicious::Date> object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;
    
    my %self = map {
	$_ => $args->{ $_ }
    } qw ( tag date count user );

    return bless \%self, $pkg;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->tag()

Returns a string.

=cut

sub tag {
    my $self = shift;
    return $self->{tag};
}

=head2 $obj->date()

Returns a date string, formatted I<YYYY-MM-DD>

=cut

sub date {
    my $self = shift;
    return $self->{date};
}

=head2 $obj->count()

Returns an int.

=cut

sub count {
    my $self = shift;
    return $self->{count};
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
