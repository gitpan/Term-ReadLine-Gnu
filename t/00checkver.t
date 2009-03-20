# -*- perl -*-
#	00check.t - check versions
#
#	$Id: 00checkver.t,v 1.2 2009/02/27 14:16:14 hiroo Exp $
#
#	Copyright (c) 2009 Hiroo Hayashi.  All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.

BEGIN {
    print "1..3\n"; $n = 1;
    $ENV{PERL_RL} = 'Gnu';	# force to use Term::ReadLine::Gnu
}
END {
    unless ($loaded) {
	print "not ok 1\tfail to loading\n";
	warn "\nPlease report the output of \'perl Makefile.PL\'\n\n"; 
    }
}

$^W = 1;			# perl -w
use strict;
use vars qw($loaded $n);
eval "use ExtUtils::testlib;" or eval "use lib './blib';";
use Term::ReadLine;
use Term::ReadLine::Gnu;

$loaded = 1;
print "ok $n\tloading\n"; $n++;

my $t = new Term::ReadLine 'ReadLineTest';
print "ok $n\tnew\n"; $n++;

print "OS: $^O\nPerl version: $]\n";
$t->rl_call_function('display-readline-version');
print "ok $n\tdone\n"; $n++;

exit 0;

