# $Id: Delicious.pm,v 1.32 2005/04/06 04:58:22 asc Exp $

package Net::Delicious;
use strict;

$Net::Delicious::VERSION = '0.93';

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

use Net::Delicious::Constants qw (:api :pause :response :uri);

use HTTP::Request;
use LWP::UserAgent;

use XML::Simple;

use Log::Dispatch;
use YAML;

use Time::HiRes;

# All this, just to keep track
# of update/all_posts stuff...

use IO::AtomicFile;
use FileHandle;
use File::Temp;
use File::Spec;
use Date::Parse;
use English;

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

=item * B<updates>

String.

The path to a directory where the timestamp for the last
update to your bookmarks can be recorded. This is used by
the I<all_posts> method to prevent abusive requests.

Default is the current user's home directory, followed by
a temporary directory as determined by File::Temp.

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

    my $self = {__user   => $args->{user},
		__pswd   => $args->{pswd},

		# flags for throttling
		__wait   => 0,
		__paused => 0,
	    };

    # flags for recording last updates

    if ($args->{'updates'}) {
	$self->{'__updates'} = $args->{'__updates'};
    }

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

=head2 $obj->delete_post(\%args)

Delete a post from del.icio.us.

Valid arguments are :

=over 4

=item * B<url>

String. I<required>

=back

Returns true or false.

=cut

sub delete_post {
    my $self = shift;
    my $args = shift;

    if (! $args->{url}) {
	$self->logger()->error("you must define a URL");
	return 0;
    }

    #

    my @params = ("url");

    my $req    = $self->_buildrequest(API_POSTSDELETE,$args,@params);
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
	return (wantarray) ? () : undef;
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

Number of posts to return. Default is 20; maximum is 100

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
       return (wantarray) ? () : undef;
   }

   my $posts = $self->_getresults($res,"post");
   return $self->_buildresults("Post",$posts);
}

=head2 $obj->all_posts()

Returns a list of I<Net::Delicious::Post> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

If no posts have been added between calls to this method,
it will return an empty list (or undef if called in a scalar
context.)

=cut

sub all_posts {
   my $self = shift;

   if (! $self->_is_updated()) {
       $self->logger()->info("posts have not changed since last call");
       return (wantarray) ? () : undef;       
   }

   my $req = $self->_buildrequest(API_POSTSFORUSER_ALL);
   my $res = $self->_sendrequest($req);

   if (! $res) {
       return (wantarray) ? () : undef;
   }

   my $posts = $self->_getresults($res,"post");
   return $self->_buildresults("Post",$posts);
}

=head2 $obj->update()

Returns return the time of the last update formatted as 
a W3CDTF string.

=cut

sub update {
   my $self = shift;

   my $req = $self->_buildrequest(API_POSTSFORUSER_UPDATE);
   my $res = $self->_sendrequest($req);

   return ($res) ? $res->{time} : undef;
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
	return (wantarray) ? () : undef;
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
	return (wantarray) ? () : undef;
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

=head2 $obj->bundles()

Returns a list of I<Net::Delicious::Bundle> objects
when called in an array context.

Returns a I<Net::Delicious::Iterator> object when called
in a scalar context.

=cut

sub bundles {
    my $self = shift;

    my $req = $self->_buildrequest(API_BUNDLES_ALL);
    my $res = $self->_sendrequest($req);
     
    my $bundles = $self->_getresults($res,"bundle");
    $bundles    = $bundles->[0];

    if (ref($bundles) ne "HASH") {
	$self->logger()->error("failed to parse response");
	return undef;
    }

    # argh....

    my @data = ();

    if (exists($bundles->{name})) {
	@data = $bundles;
    }
    
    else {
	@data = map { 
	    {name=>$_,tags=>$bundles->{$_}->{'tags'} }
	} keys %$bundles;
    }

    #

    return $self->_buildresults("Bundle",\@data);
}

=head2 $obj->set_bundle(\%args)

Valid arguments are :

=over 4

=item * B<bundle> 

String. I<required>

The name of the bundle to set.

=item * B<tags>

String. I<required>

A space-separated list of tags.

=back

Returns true or false

=cut

sub set_bundle {
    my $self = shift;
    my $args = shift;

    my @params = ("bundle","tags");

    my $req = $self->_buildrequest(API_BUNDLES_SET,$args,@params);
    my $res = $self->_sendrequest($req);

    return $self->_isdone($res);
}

=head2 $obj->delete_bundle(\%args)

Valid arguments are :

=over 4

=item * B<bundle> 

String. I<required>

The name of the bundle to set

=back

Returns true or false

=cut

sub delete_bundle {
    my $self = shift;
    my $args = shift;

    my @params = ("bundle");

    my $req = $self->_buildrequest(API_BUNDLES_DELETE,$args,@params);
    my $res = $self->_sendrequest($req);

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
	return (wantarray) ? () : undef;
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
	return (wantarray) ? () : undef;
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
	return (wantarray) ? () : undef;
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

sub _read_update {
    my $self = shift;

    my $path = $self->_path_update();
    my $fh   = FileHandle->new($path);

    if (! $fh) {
	$self->logger()->error("unable to open '$path' for reading, $!");
	return 0;
    }

    my $time = $fh->getline();
    chomp $time;

    $fh->close();
    return $time;
}

sub _write_update {
    my $self = shift;
    my $time = shift;

    my $path = $self->_path_update();
    my $fh   = IO::AtomicFile->open($path,"w");

    if (! $fh) {
	$self->logger()->error("unable to open '$path' for writing, $!");
	return 0;
    }

    $fh->print($time);
    $fh->close();

    return 1;
}

sub _is_updated {
    my $self = shift;

    my $last    = $self->_read_update();
    my $current = $self->update();

    $self->_write_update($current);

    return ($last) ? (str2time($current) > str2time($last)) : 1;
}

sub _path_update {
    my $self = shift;
    
    my $root = undef;
    my $file = sprintf(".del.icio.us.%s",$self->{'__user'});;

    if (exists($self->{'__updates'})) {
	$root = $self->{'__updates'};
    }
    
    elsif (-d (getpwuid($EUID))[7]) {
	$root = (getpwuid($EUID))[7];
    }


    else {
	$root = File::Temp::tempdir();
	$self->{'__updates'} = $root;
    }

    return File::Spec->catfile($root,$file);
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

    # check to see if we need to take
    # breather (are we pounding or are
    # we not?)

    while (time < $self->{'__wait'}) {

	my $debug_msg = sprintf("trying not to beat up on service, pause for %.2f seconds\n",
				PAUSE_SECONDS_OK);

	$self->logger()->debug($debug_msg);
	sleep(PAUSE_SECONDS_OK);
    }

    # send request

    my $res = $self->_ua()->request($req);
    $self->logger()->debug($res->as_string());

    # check for 503 status

    if ($res->code() eq PAUSE_ONSTATUS) {

	# you are in a dark and twisty corridor
	# where all the errors look the same - 
	# just give up if we hit this ceiling

	$self->{'__paused'} ++;

	if ($self->{'__paused'} > PAUSE_MAXTRIES) {

	    my $errmsg = sprintf("service returned '%d' status %d times; exiting",
				 PAUSE_ONSTATUS,PAUSE_MAXTRIES);
	    
	    $self->logger()->error($errmsg);
	    return undef;
	}

	# check to see if the del.icio.us server
	# requests that we hold off for a set amount
	# of time - otherwise wait a little longer
	# than the last time

	my $retry_after = $res->header("Retry-After");
	my $debug_msg   = undef;

	if ($retry_after ) {
	    $debug_msg = sprintf("service unavailable, requested to retry in %d seconds",
				 $retry_after);
	} 

	else {
	    $retry_after = PAUSE_SECONDS_UNAVAILABLE * $self->{'__paused'};
	    $debug_msg = sprintf("service unavailable, pause for %.2f seconds",
				 $retry_after);
	}

	$self->logger()->debug($debug_msg);
	sleep($retry_after);

	# try, try again

	return $self->_sendrequest($req);
    }

    # (re) set internal timers

    $self->{'__wait'}   = time + PAUSE_SECONDS_OK;
    $self->{'__paused'} = 0;

    # check for any other HTTP 
    # errors

    if ($res->code() ne 200) {
	$self->logger()->error(join(":",$res->code(),$res->message()));
	return undef;
    }

    if ($res->content() =~ /^<html/) {
	$self->logger()->error("erp. returned HTML - this is wrong");
	return undef;
    }

    # munge munge munge

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
	$ua->agent(sprintf("%s, %s",__PACKAGE__,$Net::Delicious::VERSION));

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

    elsif ($res eq RESPONSE_OK) {
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

0.93

=head1 DATE 

$Date: 2005/04/06 04:58:22 $

=head1 AUTHOR

Aaron Straup Cope <ascope@cpan.org>

=head1 SEE ALSO

http://del.icio.us/doc/api

=head1 NOTES

The version number (0.9) reflects the fact the del.icio.us API
still has a great big "I am a moving target" disclaimer around
its neck.

This package implements the API in its entirety as of I<DATE>.

=head1 LICENSE

Copyright (c) 2004-2005, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;
