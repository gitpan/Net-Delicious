# $Id: Build.PL,v 1.2 2004/12/12 22:42:48 asc Exp $

use strict;
use Module::Build;

my $build = Module::Build->new(module_name => 'Net::Delicious',
			       # dist_author
			       # dist_abstract
			       dist_version_from => 'lib/Net/Delicious.pm',
			       license           => 'perl',
			       requires => {
				   'LWP::UserAgent' => '',
				   'HTTP::Request'  => '',
				   'YAML'           => '>= 0.35',
				   'Log::Dispatch'  => '>= 2',
				   'XML::Simple'    => '>= 2',
				   'Time::HiRes'    => '>= 1.65',
				   'FileHandle'     => '>= 2',
				   'IO::AtomicFile' => '>= 2.1',
				   'File::Spec'     => '>= 0.8',
				   'Date::Parse'    => '>= 2.27'
				   
			       },
			       build_requires => {
				   'Test::Simple'              => '>= 0.47',
			       },
			       create_readme      => 1,
			       create_makefile_pl => 'passthrough');

$build->create_build_script();
