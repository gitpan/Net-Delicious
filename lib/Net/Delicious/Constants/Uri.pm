package Net::Delicious::Constants::Uri;
use strict;

# $Id: Uri.pm,v 1.6 2005/12/30 17:51:40 asc Exp $

=head1 NAME

Net::Delicious::Constants::Uri - constant variables for del.icio.us URIs

=head1 SYNOPSIS

 use Net::Delicious::Constants qw (:uri)

=head1 DESCRIPTION

Constant variables for del.icio.us URIs.

=cut

$Net::Delicious::Constants::Uri::VERSION = '0.95';

=head1 CONSTANTS

=cut

=head2 URI_DELICIOUS

String.

=cut

use constant URI_DELICIOUS => "http://del.icio.us";

=head2 URI_API

String.

=cut

use constant URI_API => join("/",URI_DELICIOUS,"api");

BEGIN {
  use vars qw (@EXPORT_OK);

  @EXPORT_OK = qw (URI_DELICIOUS
		   URI_API);
}

=head1 VERSION

0.95

=head1 DATE

$Date: 2005/12/30 17:51:40 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

L<Net::Delicious>

L<Net::Delicious::Constants>

=head1 LICENSE

Copyright (c) 2004-2005 Aaron Straup Cope. All rights reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
