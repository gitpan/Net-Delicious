use strict;
use ExtUtils::MakeMaker;

# $Id: Makefile.PL,v 1.4 2004/09/16 21:43:21 asc Exp $

WriteMakefile(NAME=>"Net::Delicious",
	      ($[ >= 5.005) ?
	      (AUTHOR   => 'Aaron Straup Cope (cpan@aaronland.net)',
	       ABSTRACT => 'OOP for talking to the del.icio.us API') : (),
	      VERSION_FROM => "lib/Net/Delicious.pm",
	      'PREREQ_PM'    => {"LWP::UserAgent" => 0,
				 "HTTP::Request"  => 0,
				 "YAML"           => 0,
				 "Log::Dispatch"  => 2,
				 "XML::Simple"    => 2,
				 "Time::HiRes"    => 0,
				 "Test::More"     => 0,},
	     );
