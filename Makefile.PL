use ExtUtils::MakeMaker;
WriteMakefile(NAME=>"Net::Delicious",
	      ($[ >= 5.005) ?
	      (AUTHOR   => 'Aaron Straup Cope (cpan@aaronland.net)',
	       ABSTRACT => 'OOP for talking to the del.icio.us API') : (),
	      VERSION_FROM => "lib/Net/Delicious.pm",
	      'PREREQ_PM'    => {"LWP::UserAgent" => 0,
				 "HTTP::Request"  => 0,
				 "Log::Dispatch"  => 2,
				 "XML::Simple"    => 2,
				 "Test::More"     => 0,},
	     );
