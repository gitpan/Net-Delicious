package Net::Delicious;
use strict;

# $Id: Delicious.pm,v 1.14 2004/03/06 05:14:28 asc Exp $

=head1 NAME

Net::Delicious - OOP for the del.icio.us API

=head1 SYNOPSIS

  use Net::Delicious;
  use Log::Dispatch::Screen;

  my $del = Net::Delicious->new({user=>"foo",
				 pswd=>"bar"});

  foreach my $p ($del->recent_posts()) {
      print $p->description()."\n";
  } 

=head1 DESCRIPTION

OOP for the del.icio.us API

=cut

$Net::Delicious::VERSION = '0.4';

use HTTP::Request;
use LWP::UserAgent;

use XML::Simple;

use Log::Dispatch;
use YAML;

use Net::Delicious::Constants qw (:api :response :uri);

=head1 PACKAGE METHODS

=cut

=head2 __PACKAGE__->new(\%args)

Valid arguments are :

=over 4

=item * B<user> 

String. I<required>

Your del.icio.us username.

=item * B<pswd>

String. I<required>

Your del.icio.us password.

=item * B<debug>

Boolean.

Add a I<Log::Dispatch::Screen> dispatcher to log debug 
(and higher) notices. Notices will be printed to STDERR.

=back

Returns a Net::Delicious object. Woot!

=cut

sub new {
    my $pkg  = shift;
    my $args = shift;

    #

    my $self = {__user => $args->{user},
		__pswd => $args->{pswd}};

    bless $self, $pkg;

    #

    if ($args->{debug}) {
	require Log::Dispatch::Screen;
	$self->logger()->add(Log::Dispatch::Screen->new(name      => "debug",
							min_level => "debug",
							stderr    => 1));
    }

    #

    return $self;
}

=head1 OBJECT METHODS

=cut

=head2 $obj->add_post(\%args)

Makes a post to del.icio.us.

Valid arguments are :

=over 4

=item * B<url>

String. I<required>

Url for post

=item * B<description>

String.

Description for post.

=item * B<extended>

String.

Extended for post.

=item * B<tags>

String.

Space-delimited list of tags.

=item * B<dt>

String.

Datestamp for post, format "CCYY-MM-DDThh:mm:ssZ"

=back

Returns true or false.

=cut

sub add_post {
    my $self = shift;
    my $args = shift;

    if (! $args->{url}) {
	$self->logger()->error("you must define a URL");
	return 0;
    }

    #

    my @params = ("url","description","extended","tags","dt");

    my $req    = $self->_buildrequest(API_POSTSADD,$args,@params);
    my $res    = $self->_sendrequest($req);

    #

    return $self->_isdone($res);
}

=head2 $obj->posts_per_date(\%args)

Get a list of dates with the number of posts at each date.

Valid arguments are :

=over 4

=item * B<tag>

String.

Filter by this tag.

=back

Returns a list of I<Net::Delicious::Date> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

=cut

sub posts_per_date {
    my $self = shift;
    my $args = shift;

    my @params = ("tag");

    my $req = $self->_buildrequest(API_POSTSPERDATE,$args,@params);
    my $res = $self->_sendrequest($req);

    if (! $res) {
	return undef;
    }

    my $dates = $self->_getresults($res,"date");
    return $self->_buildresults("Date",$dates);
}

=head2 $obj->recent_posts(\%args)

Get a list of most recent posts, possibly filtered by tag.

Valid arguments are :

=over 4

=item * B<tag>

String.

Filter by this tag.

=item * B<count>

Int.

Number of items to retrieve (defaults to 15)

=back

Returns a list of I<Net::Delicious::Post> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

=cut

sub recent_posts {
   my $self = shift;
   my $args = shift;

   my @params = ("tag","count");

   my $req = $self->_buildrequest(API_POSTSFORUSER_RECENT,
				  $args,
				  @params);

   my $res = $self->_sendrequest($req);

   if (! $res) {
       return undef;
   }

   my $posts = $self->_getresults($res,"post");
   return $self->_buildresults("Post",$posts);
}

=head2 $obj->posts(\%args)

Get a list of posts on a given date, filtered by tag. If no 
date is supplied, most recent date will be used.

Valid arguments are :

=over 4

=item * B<tag>

String.

Filter by this tag.

=item * B<dt>

String.

Filter by this date.

=back

Returns a list of I<Net::Delicious::Post> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

=cut

sub posts {
    my $self = shift;
    my $args = shift;

    #

    my @params = ("tag","dt");
    
    my $req = $self->_buildrequest(API_POSTSFORUSER,
				   $args,
				   @params);
    
    my $res = $self->_sendrequest($req);
    
    if (! $res) {
	return undef;
    }
    
    #

    my $posts = $self->_getresults($res,"post");
    return $self->_buildresults("Post",$posts);
}

=head2 $obj->tags()

Returns a list of tags.

=cut

sub tags {
    my $self = shift;

    my $req = $self->_buildrequest(API_TAGSFORUSER);
    my $res = $self->_sendrequest($req);

    if (! $res) {
	return undef;
    }

    #

    my $tags = $self->_getresults($res,"tag");
    return $self->_buildresults("Tag",$tags);
}

=head2 $obj->rename_tag(\%args)

Renames tags across all posts.

Valid arguments are :

=over 4

=item * B<old>

String. I<required>

Old tag

=item * B<new>

String. I<required>

New tag

=back

Returns true or false.

=cut

sub rename_tag {
    my $self = shift;
    my $args = shift;

    #

    foreach my $el ("old","new") {
	if (! exists($args->{$el})) {
	    $self->logger()->error("you must define a '$el' element");
	    return 0;
	}
    }

    #

    my @params = ("old","new");
    
    my $req = $self->_buildrequest(API_TAGSRENAME,
				  $args,
				  @params);
    
    my $res = $self->_sendrequest($req);
    
    #

    return $self->_isdone($res);
}

=head2 $obj->inbox_for_date(\%args)

Get a list of inbox entries.

Valid arguments are :

=over 4

=item * B<dt>

String.

Filter by this date

=back

Returns a list of I<Net::Delicious::Post> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

=cut

sub inbox_for_date {
    my $self = shift;
    my $args = shift;
    
    if (! $args->{dt}) {
	$self->logger()->error("you must define a 'dt' parameter");
	return 0;
    }

    #

    my @params = ("dt");
    
    my $req = $self->_buildrequest(API_INBOXFORDATE,
				  $args,
				  @params);
    
    my $res = $self->_sendrequest($req);

    if (! $res) {
	return undef;
    }

    my $posts = $self->_getresults($res,"post");
    return $self->_buildresults("Post",$posts);
}

=head2 $obj->inbox_dates()

Get a list of dates containing inbox entries.

Returns a list of I<Net::Delicious::Date> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

I<This may be updated to return a Net::Delicious::Inbox
object.>

=cut

sub inbox_dates {
    my $self = shift;

    my $req = $self->_buildrequest(API_INBOXDATES);
    my $res = $self->_sendrequest($req);

    if (! $res) {
	return undef;
    }

    my $dates = $self->_getresults($res,"date");

    # Return an "Inbox" object ?
    return $self->_buildresults("Date",$dates);
}

=head2 $obj->inbox_subscriptions()

Get a list of your subscriptions.

Returns a list of I<Net::Delicious::Subscription> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

=cut

sub inbox_subscriptions {
    my $self = shift;

    my $req = $self->_buildrequest(API_INBOXSUBS);
    my $res = $self->_sendrequest($req);

    if (! $res) {
	return undef;
    }

    my $subs = $self->_getresults($res,"sub");
    return $self->_buildresults("Subscription",$subs);
}

=head2 $obj->add_inbox_subscription(\%args)

Adds a subscription.

Valid arguments are :

=over 4

=item * B<user>

String. I<required>

Username.

=item * B<tag>

String.

Tag - leave blank for all posts

=back

Returns true or false.

=cut

sub add_inbox_subscription {
    my $self = shift;
    my $args = shift;
    
    if (! $args->{user}) {
	$self->logger()->error("you must define a 'user' parameter");
	return 0;
    }

    my @params = ("user","tag");

    my $req = $self->_buildrequest(API_INBOXADDSUB,$args,@params);
    my $res = $self->_sendrequest($req);

    # Temporary hack since all this API call
    # returns in an "<ok />" without an XML 
    # declaration...

    return ($res) ? 1 : 0;
}

=head2 $obj->remove_inbox_subscription(\%args)

Valid arguments are :

=over 4

=item * B<user>

String. I<required>

Username.

=item * B<tag>

String.

Tag - leave blank for all posts

=back

Returns true or false.

=cut

sub remove_inbox_subscription {
    my $self = shift;
    my $args = shift;
    
    if (! $args->{user}) {
	$self->logger()->error("you must define a 'user' parameter");
	return 0;
    }

    my @params = ("user","tag");

    my $req = $self->_buildrequest(API_INBOXUNSUB,$args,@params);
    my $res = $self->_sendrequest($req);

    # Temporary hack since all this API call
    # returns in an "<ok />" without an XML 
    # declaration...

    return ($res) ? 1 : 0;
}

=head2 $obj->logger()

Returns a Log::Dispatch object.

=cut

sub logger {
    my $self = shift;

    if (ref($self->{'__logger'}) ne "Log::Dispatch") {
	my $log = Log::Dispatch->new();
	$self->{'__logger'} = $log;
    }

    return $self->{'__logger'};    
}

sub _buildrequest {
    my $self   = shift;
    my $meth   = shift;
    my $args   = shift;

    # @params are assumed to anything
    # that's left in @_

    my $uri = join("/",URI_API,$meth);

    my $get = &_getargs($args,@_);
    my $req = HTTP::Request->new(GET=>&_buildurl($uri,$get));

    $self->_authorize($req);

    $self->logger()->debug($req->as_string());
    return $req;
}

sub _sendrequest {
    my $self = shift;
    my $req  = shift;

    my $res = $self->_ua()->request($req);
    $self->logger()->debug($res->as_string());

    #

    if ($res->code() ne 200) {
	$self->logger()->error(join(":",$res->code(),$res->message()));
	return undef;
    }

    if ($res->content() =~ /^<html/) {
	$self->logger()->error("erp. returned HTML - this is wrong");
	return undef;
    }

    #

    my $xml = undef;

    eval { 
	$xml = XMLin($res->content());
    };

    $self->logger()->debug(Dump($xml));

    if ($@) {
	$self->logger()->error($@);
	return undef;
    }

    if ($xml eq RESPONSE_ERROR) {
	$self->logger()->error($xml);
	return undef;
    }

    $self->logger()->debug($xml);
    return $xml;
}

sub _authorize {
    my $self = shift;
    my $req  = shift;
    $req->authorization_basic($self->{'__user'},$self->{'__pswd'});
}

sub _ua {
    my $self = shift;

    if (ref($self->{'__ua'}) ne "LWP::UserAgent") {
	my $ua = LWP::UserAgent->new();
	$ua->agent(__PACKAGE__);

	$self->{'__ua'} = $ua;
    }

    return $self->{'__ua'};
}

sub _getargs {
    my $args = shift;

    my @get = map { 
	"$_=$args->{$_}";
    } grep {
	exists($args->{$_}) && $args->{$_}
    } @_;

    return \@get;
}

sub _buildurl {
    my $url  = shift;
    my $args = shift;

    if (ref($args) ne "ARRAY") {
	return $url;
    }

    elsif (! scalar(@$args)) {
	return $url;
    }

    else {
	return join("?",$url,join("&",@$args));
    }
}

sub _getresults {
    my $self = shift;
    my $data = shift;
    my $key  = shift;

    if (! exists($data->{$key})) {
	return [];
    }

    elsif (ref($data->{ $key }) eq "ARRAY") {
	return $data->{ $key };
    }

    else {
	return [ $data->{ $key } ];
    }
}

sub _buildresults {
    my $self    = shift;
    my $type    = shift;
    my $results = shift;

    $type =~ s/:://g;

    my $fclass = join("::",__PACKAGE__,$type);
    eval "require $fclass";

    if ($@) {
	$self->logger()->error($@);
	return undef;
    }

    if (wantarray) {
	return map { 
	    $fclass->new($_);
	} @$results;
    }

    #

    require Net::Delicious::Iterator;
    return Net::Delicious::Iterator->new($fclass,
					 $results);    
}

sub _isdone {
    my $self = shift;
    my $res  = shift;

    if (! $res) {
	return 0;
    }

    elsif ($res eq RESPONSE_DONE) {
	return 1;
    }

    elsif ((ref($res) eq "HASH") &&
	(exists($res->{code})) &&
	($res->{code} eq RESPONSE_DONE)) {

	return 1;
    }

    else {
	$self->logger()->error("Unknown data structure returned.");
	return 0;
    }
}

=head1 ERRORS

Errors are logged via the object's I<logger> method which returns
a I<Log::Dispatch> object. If you want to get at the errors it is
up to you to provide it with a dispatcher.

=head1 VERSION

0.4

=head1 DATE 

$Date: 2004/03/06 05:14:28 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

http://del.icio.us/doc/api

=head1 NOTES

The version number (0.4) reflects the fact the del.icio.us API
still has a great big "I am a moving target" disclaimer around
its neck.

This package implements the API in its entirety as of I<DATE>.

=head1 LICENSE

Copyright (c) 2004, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
