package Net::Delicious::Post;
use strict;

# $Id: Post.pm,v 1.11 2004/10/08 14:12:30 asc Exp $

=head1 NAME

Net::Delicious::Post - OOP for del.icio.us post thingies

=head1 SYNOPSIS

  use Net::Delicious;
  my $del = Net::Delicious->new({...});

  foreach my $post ($del->recent_posts()) {

      # $post is a Net::Delicious::Post 
      # object.

      print "$post\n";
  }

=head1 DESCRIPTION

OOP for del.icio.us post thingies.

=head1 NOTES

=over 4

=item *

This package overrides the perl builtin I<stringify> operator and returns the value of the object's I<href> method.

=item *

It isn't really expected that you will instantiate these
objects outside of I<Net::Delicious> itself.

=back

=cut

$Net::Delicious::Post::VERSION = '0.5';

use Net::Delicious::User;
use overload q("") => sub { shift->href() };

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new(\%args)

Returns a I<Net::Delicious::Post> object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;
    
    my %self = map { 
	$_ => $args->{ $_ };
    } qw ( description extended href time parent);

    # this one seems to be the source of some
    # confusion - unclear whether it's me or
    # inconsistency in the API itself

    $self{ tags } = $args->{ tags } || $args->{ tag };

    #

    $self{ user } = Net::Delicious::User->new({name => $args->{user}});

    #

    return bless \%self, $pkg;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->description()

Returns a string.

=cut

sub description {
    my $self = shift;
    return $self->{description};
}

=head2 $obj->extended()

Returns a string.

=cut

sub extended {
    my $self = shift;
    return $self->{extended};
}

=head2 $obj->href()

Returns a string.

=cut

*url  = \&href;
*link = \&href;

sub href {
    my $self = shift;
    return $self->{href};
}

=head2 $obj->tag()

Deprecated - calls I<tags>

=cut

sub tag {
    return shift->tags();
}

=head2 $obj->tags()

Returns a string.

=cut

sub tags {
    my $self = shift;
    return $self->{tags};
}

=head2 $obj->user()

Returns a Net::Delicious::User object.

=cut

sub user {
    my $self = shift;
    return $self->{user};
}

=head2 $obj->time()

Returns a string, formatted I<YYYY-MM-DD>

=cut

sub time {
    my $self = shift;
    return $self->{time};
}

=head1 VERSION

0.5

=head1 DATE

$Date: 2004/10/08 14:12:30 $

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
