package Net::Delicious::Constants::Api;
use strict;

# $Id: Api.pm,v 1.9 2005/04/05 15:56:50 asc Exp $

=head1 NAME

Net::Delicious::Constants::Api - constant variables for del.icio.us API calls

=head1 SYNOPSIS

 use Net::Delicious::Constants qw (:api)

=head1 DESCRIPTION

Constant variables for del.icio.us API calls.

=cut

$Net::Delicious::Constants::Api::VERSION = '0.4';

use constant LOCAL_API_POSTS   => "posts";
use constant LOCAL_API_TAGS    => "tags";
use constant LOCAL_API_BUNDLES => "tags/bundles";
use constant LOCAL_API_INBOX   => "inbox";

=head1 CONSTANTS

=cut

=head2 API_POSTSPERDATE

String.

=cut

use constant API_POSTSPERDATE => join("/",LOCAL_API_POSTS,"dates");

=head2 API_POSTSPERDATE

String.

=cut

use constant API_POSTSFORUSER => join("/",LOCAL_API_POSTS,"get");

=head2 API_POSTSPERDATE

String.

=cut

=head2 API_POSTSFORUSER_UPDATE

String.

=cut

use constant API_POSTSFORUSER_UPDATE => join("/",LOCAL_API_POSTS,"update");

use constant API_POSTSFORUSER_RECENT => join("/",LOCAL_API_POSTS,"recent");
use constant API_POSTSFORUSER_ALL    => join("/",LOCAL_API_POSTS,"all");

=head2 API_POSTSPERDATE

String.

=cut

use constant API_POSTSADD    => join("/",LOCAL_API_POSTS,"add");

use constant API_POSTSDELETE => join("/",LOCAL_API_POSTS,"delete");

=head2 API_TAGSFORUSER

String.

=cut

use constant API_TAGSFORUSER => join("/",LOCAL_API_TAGS,"get");

=head2 API_TAGSRENAME

String.

=cut

use constant API_TAGSRENAME => join("/",LOCAL_API_TAGS,"rename");

=head2 API_INBOXDATES

String.

=cut

use constant API_INBOXDATES => join("/",LOCAL_API_INBOX,"dates");

=head2 API_INBOXSUBS

String.

=cut

use constant API_INBOXSUBS => join("/",LOCAL_API_INBOX,"subs");

=head2 API_INBOXFORDATE

String.

=cut

use constant API_INBOXFORDATE => join("/",LOCAL_API_INBOX,"get");

=head2 API_INBOXADDSUB

String.

=cut

use constant API_INBOXADDSUB => join("/",LOCAL_API_INBOX,"sub");

=head2 API_INBOXUNSUB

String.

=cut

use constant API_INBOXUNSUB => join("/",LOCAL_API_INBOX,"unsub");

use constant API_BUNDLES_ALL => join("/",LOCAL_API_BUNDLES,"all");

use constant API_BUNDLES_SET => join("/",LOCAL_API_BUNDLES,"set");

use constant API_BUNDLES_DELETE => join("/",LOCAL_API_BUNDLES,"delete");

BEGIN {
    use vars qw (@EXPORT_OK);

    @EXPORT_OK = qw (API_POSTSPERDATE
		     API_POSTSFORUSER
		     API_POSTSFORUSER_RECENT
		     API_POSTSFORUSER_ALL
		     API_POSTSFORUSER_UPDATE

		     API_POSTSADD
		     API_POSTSDELETE

		     API_TAGSFORUSER
		     API_TAGSRENAME
	
		     API_BUNDLES_ALL
		     API_BUNDLES_SET
		     API_BUNDLES_DELETE

		     API_INBOXDATES
		     API_INBOXSUBS
		     API_INBOXFORDATE
		     API_INBOXADDSUB
		     API_INBOXUNSUB);
}


=head1 VERSION

0.4

=head1 DATE

$Date: 2005/04/05 15:56:50 $

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
