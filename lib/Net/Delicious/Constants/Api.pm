package Net::Delicious::Constants::Api;
use strict;

# $Id: Api.pm,v 1.5 2004/09/30 14:18:09 asc Exp $

=head1 NAME

Net::Delicious::Constants::Api - constant variables for del.icio.us API calls

=head1 SYNOPSIS

 use Net::Delicious::Constants qw (:api)

=head1 DESCRIPTION

Constant variables for del.icio.us API calls.

=cut

$Net::Delicious::Constants::Api::VERSION = '0.2';

use constant LOCAL_API_POSTS => "posts";
use constant LOCAL_API_TAGS  => "tags";
use constant LOCAL_API_INBOX => "inbox";

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

use constant API_POSTSFORUSER_RECENT => join("/",LOCAL_API_POSTS,"recent");
use constant API_POSTSFORUSER_ALL    => join("/",LOCAL_API_POSTS,"all");

=head2 API_POSTSPERDATE

String.

=cut

use constant API_POSTSADD => join("/",LOCAL_API_POSTS,"add");

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

BEGIN {
    use vars qw (@EXPORT_OK);

    @EXPORT_OK = qw (API_POSTSPERDATE
		     API_POSTSFORUSER
		     API_POSTSFORUSER_RECENT
		     API_POSTSFORUSER_ALL
		     API_POSTSADD
		     
		     API_TAGSFORUSER
		     API_TAGSRENAME
		     
		     API_INBOXDATES
		     API_INBOXSUBS
		     API_INBOXFORDATE
		     API_INBOXADDSUB
		     API_INBOXUNSUB);
}


=head1 VERSION

0.2

=head1 DATE

$Date: 2004/09/30 14:18:09 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

L<Net::Delicious>

L<Net::Delicious::Constants>

=head1 LICENSE

Copyright (c) 2004 Aaron Straup Cope. All rights reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
