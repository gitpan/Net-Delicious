# $Id: Object.pm,v 1.4 2005/12/30 17:51:39 asc Exp $
use strict;

package Net::Delicious::Object;
$Net::Delicious::Object::VERSION = '0.95';

=head1 NAME 

Net::Delicious::Object - base class for Net::Delicious thingies

=head1 SYNOPSIS

 package Net::Delicious::TunaBlaster;
 use base qw (Net::Delicious::Object);

=head1 DESCRIPTION

Base class for Net::Delicious thingies. You should never access this
package directly.

=cut

sub new {
        my $pkg  = shift;
        my $args = shift;
        
        my %self = $pkg->_mk_hash($args);
        return bless \%self, $pkg;
}

sub as_hashref {
        my $self = shift;
        return {$self->_mk_hash()};
}

sub _mk_hash {
        my $pkg = shift;
        my $src = (ref($pkg)) ? $pkg : shift;

        my @props = $pkg->_properties();
        my %hash  = ();

        foreach my $p (@props) {
                $hash{$p} = $src->{$p};
        }
        
        return %hash;
}

=head1 VERSION

0.95

=head1 DATE

$Date: 2005/12/30 17:51:39 $

=head1 AUTHOR

Aaron Straup Cope E<lt>ascope@cpan.orgE<gt>

=head1 LICENSE

Copyright (c) 2004-2005 Aaron Straup Cope. All rights reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
