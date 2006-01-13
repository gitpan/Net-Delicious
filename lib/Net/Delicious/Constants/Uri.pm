package Net::Delicious::Constants::Uri;
use strict;

# $Id: Uri.pm,v 1.7 2006/01/13 17:09:11 asc Exp $
$Net::Delicious::Constants::Uri::VERSION = '0.96';

use URI;

=head1 NAME

Net::Delicious::Constants::Uri - constant variables for del.icio.us URIs

=head1 SYNOPSIS

 use Net::Delicious::Constants qw (:uri)

=head1 DESCRIPTION

Constant variables for del.icio.us URIs.
cut

=head1 CONSTANTS

=cut

=head2 URI_DELICIOUS

String.

=cut

use constant URI_DELICIOUS => URI->new("http://del.icio.us");

=head2 URI_API

String.

=cut

use constant URI_API => URI->new_abs("api/", URI_DELICIOUS); 

BEGIN {
  use vars qw (@EXPORT_OK);

  @EXPORT_OK = qw (URI_DELICIOUS
		   URI_API);
}

=head1 VERSION

0.96

=head1 DATE

$Date: 2006/01/13 17:09:11 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

L<Net::Delicious>

L<Net::Delicious::Constants>

=head1 LICENSE

Copyright (c) 2004-2006 Aaron Straup Cope. All rights reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
