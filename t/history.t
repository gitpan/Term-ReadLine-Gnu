# -*- perl -*-
#	history.t --- Term::ReadLine:GNU History Library Test Script
#
#	$Id: history.t,v 1.2 1998-03-26 23:49:26+09 hayashi Exp $
#
#	Copyright (c) 1998 Hiroo Hayashi.  All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/history.t'

BEGIN {print "1..78\n"; $n = 1}
END {print "not ok $n\n" unless $loaded;}

$^W = 1;			# perl -w
use strict;
use vars qw($loaded $n);
eval "use ExtUtils::testlib;" or eval "use lib './blib';";
use Term::ReadLine;
sub show_indices;

$loaded = 1;
print "ok $n\n"; $n++;

########################################################################
# test new method

my $t = new Term::ReadLine 'ReadLineTest';
print defined $t ? "ok $n\n" : "not ok $n\n"; $n++;

########################################################################
# test ReadLine method

my $OUT = $t->OUT || \*STDOUT;

if ($t->ReadLine eq 'Term::ReadLine::Gnu') {
    print "ok $n\n";
} else {
    print "not ok $n\n";
    print $OUT ("Package name should be \`Term::ReadLine::Gnu\', but it is \`",
		$t->ReadLine, "\'\n");
}
$n++;

########################################################################
# test Attribs method
use vars qw($attribs);

$attribs = $t->Attribs;
print defined $attribs ? "ok $n\n" : "not ok $n\n"; $n++;

########################################################################
# 2.3.1 Initializing History and State Management

# test using_history
# This is verbose since 'new' has already initialized the GNU history library.
$t->using_history;

# check the values of initialized variables
print $attribs->{history_base} == 1
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $attribs->{history_length} == 0
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $attribs->{max_input_history} == 0
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $attribs->{history_expansion_char} eq '!'
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $attribs->{history_subst_char} eq '^'
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $attribs->{history_comment_char} eq "\0"
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $attribs->{history_no_expand_chars} eq " \t\n\r="
    ? "ok $n\n" : "not ok $n\n"; $n++;
$^W = 0;			#  (char *)history_serch_delimiter_char == NULL
print $attribs->{history_search_delimiter_chars} eq ''
    ? "ok $n\n" : "not ok $n\n"; $n++;
$^W = 1;
print $attribs->{history_quotes_inhibit_expansion} == 0
    ? "ok $n\n" : "not ok $n\n"; $n++;

print "ok $n\n"; $n++;

########################################################################
# 2.3.2 History List Management

my @list_set;
# default value of `history_base' is 1
@list_set = qw(one two two three);
show_indices;

# test SetHistory(), GetHistory()
$t->SetHistory(@list_set);
print cmp_list(\@list_set, [$t->GetHistory]) ? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;

# test add_history()
$t->add_history('four');
push(@list_set, 'four');
print cmp_list(\@list_set, [$t->GetHistory]) ? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;

# test remove_history()
$t->remove_history(2);
splice(@list_set, 2, 1);
print cmp_list(\@list_set, [$t->GetHistory]) ? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;

# test replace_history_entry()
$t->replace_history_entry(3, 'daarn');
splice(@list_set, 3, 1, 'daarn');
print cmp_list(\@list_set, [$t->GetHistory]) ? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;

# stifle_history
print $t->history_is_stifled == 0 ? "ok $n\n" : "not ok $n\n"; $n++;
$t->stifle_history(3);
print($t->history_is_stifled == 1
      && $attribs->{history_length} == 3 && $attribs->{max_input_history} == 3
      ? "ok $n\n" : "not ok $n\n"); $n++;
#print "@{[$t->GetHistory]}\n";
show_indices;

# history_is_stifled()
$t->add_history('five');
print($t->history_is_stifled == 1 && $attribs->{history_length} == 3
      ? "ok $n\n" : "not ok $n\n"); $n++;
show_indices;

# unstifle_history()
$t->unstifle_history;
print($t->history_is_stifled == 0 && $attribs->{history_length} == 3
      ? "ok $n\n" : "not ok $n\n"); $n++;
#print "@{[$t->GetHistory]}\n";
show_indices;

# history_is_stifled()
$t->add_history('six');
print($t->history_is_stifled == 0 && $attribs->{history_length} == 4
      ? "ok $n\n" : "not ok $n\n"); $n++;
show_indices;

# clear_history()
$t->clear_history;
print ($attribs->{history_length} == 0 ? "ok $n\n" : "not ok $n\n"); $n++;
show_indices;

########################################################################
# 2.3.3 Information About the History List

$attribs->{history_base} = 0;
show_indices;
@list_set = qw(zero one two three four);
$t->stifle_history(4);
show_indices;
$t->SetHistory(@list_set);
show_indices;

# history_list()
#	history_list() routine emulates history_list() function in
#	GNU Readline Library.
splice(@list_set, 0, 1);
print cmp_list(\@list_set, [$t->history_list])
    ? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;

# at first where_history() returns 0
print $t->where_history == 0		? "ok $n\n" : "not ok $n\n"; $n++;

# current_history()
#   history_base + 0 = 1
print $t->current_history eq 'one'	? "ok $n\n" : "not ok $n\n"; $n++;

# history_total_bytes()
print $t->history_total_bytes == 15	? "ok $n\n" : "not ok $n\n"; $n++;

########################################################################
# 2.3.4 Moving Around the History List

# history_set_pos()
$t->history_set_pos(2);
print $t->where_history == 2		? "ok $n\n" : "not ok $n\n"; $n++;
#   history_base + 2 = 3
print $t->current_history eq 'three'	? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;

$t->history_set_pos(10000);	# should be ingored
print $t->where_history == 2		? "ok $n\n" : "not ok $n\n"; $n++;

# previous_history()
print $t->previous_history eq 'two'	? "ok $n\n" : "not ok $n\n"; $n++;
print $t->where_history == 1		? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;
print $t->previous_history eq 'one'	? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;
$^W = 0;			# returns NULL
print $t->previous_history eq ''	? "ok $n\n" : "not ok $n\n"; $n++;
$^W = 1;
show_indices;

# next_history()
print $t->next_history eq 'two'		? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;
print $t->next_history eq 'three'	? "ok $n\n" : "not ok $n\n"; $n++;
show_indices; 
print $t->next_history eq 'four'	? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;
$^W = 0;			# returns NULL
print $t->next_history eq ''		? "ok $n\n" : "not ok $n\n"; $n++;
$^W = 1;
print $t->where_history == 4		? "ok $n\n" : "not ok $n\n"; $n++;
show_indices;


########################################################################
# 2.3.5 Searching the History List

@list_set = ('red yellow', 'green red', 'yellow blue', 'green blue');
$t->SetHistory(@list_set);

$t->history_set_pos(1);
#show_indices;

# history_search()
print($t->history_search('red',    -1) ==  6 && $t->where_history == 1
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search('blue',   -1) == -1 && $t->where_history == 1
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search('yellow', -1) ==  4 && $t->where_history == 0
      ? "ok $n\n" : "not ok $n\n"); $n++;

print($t->history_search('red',     1) ==  0 && $t->where_history == 0
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search('blue',    1) ==  7 && $t->where_history == 2
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search('red',     1) == -1 && $t->where_history == 2
      ? "ok $n\n" : "not ok $n\n"); $n++;

print($t->history_search('red')        ==  6 && $t->where_history == 1
      ? "ok $n\n" : "not ok $n\n"); $n++;

# history_search_prefix()
print($t->history_search_prefix('red',  -1) ==  0
      && $t->where_history == 0 ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_prefix('green', 1) ==  0
      && $t->where_history == 1 ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_prefix('red',   1) == -1
      && $t->where_history == 1 ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_prefix('red')      ==  0
      && $t->where_history == 0 ? "ok $n\n" : "not ok $n\n"); $n++;

# history_search_pos()
$t->history_set_pos(3);
print($t->history_search_pos('red',    -1, 1) ==  1
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('red',    -1, 3) ==  1
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('black',  -1, 3) == -1
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('yellow', -1)    ==  2
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('green')         ==  3
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('yellow',  1, 1) ==  2
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('yellow',  1)    == -1
      ? "ok $n\n" : "not ok $n\n"); $n++;
print($t->history_search_pos('red',     1, 2) == -1
      ? "ok $n\n" : "not ok $n\n"); $n++;

########################################################################
# 2.3.6 Managing the History File

$t->stifle_history(undef);
my $hfile = '.history_test';
my @list_write = $t->GetHistory();
$t->WriteHistory($hfile) || warn "error at write_history: $!\n";

$t->SetHistory();		# clear history list
print ! $t->GetHistory ? "ok $n\n" : "not ok $n\n"; $n++;

$t->ReadHistory($hfile) || warn "error at read_history: $!\n";
print cmp_list(\@list_write, [$t->GetHistory]) ? "ok $n\n" : "not ok $n\n";
$n++;

@list_write = qw(0 1 2 3 4);
$t->SetHistory(@list_write);
# write_history()
! $t->write_history($hfile) || warn "error at write_history: $!\n";
$t->SetHistory();		# clear history list
# read_history()
! $t->read_history($hfile) || warn "error at read_history: $!\n";
print cmp_list(\@list_write, [$t->GetHistory]) ? "ok $n\n" : "not ok $n\n";
$n++;

# read_history() with range
! $t->read_history($hfile, 1, 3) || warn "error at read_history: $!\n";
print cmp_list([0,1,2,3,4,1,2], [$t->GetHistory])
    ? "ok $n\n" : "not ok $n\n"; $n++;
#print "@{[$t->GetHistory]}\n";
! $t->read_history($hfile, 2, -1) || warn "error at read_history: $!\n";
print cmp_list([0,1,2,3,4,1,2,2,3,4], [$t->GetHistory])
    ? "ok $n\n" : "not ok $n\n"; $n++;
#print "@{[$t->GetHistory]}\n";

# append_history()
! $t->append_history(5, $hfile) || warn "error at append_history: $!\n";
$t->SetHistory();		# clear history list
! $t->read_history($hfile) || warn "error at read_history: $!\n";
print cmp_list([0,1,2,3,4,1,2,2,3,4], [$t->GetHistory])
    ? "ok $n\n" : "not ok $n\n"; $n++;
#print "@{[$t->GetHistory]}\n";

# history_truncate_file()
$t->history_truncate_file($hfile, 6); # always returns 0
$t->SetHistory();		# clear history list
! $t->read_history($hfile) || warn "error at read_history: $!\n";
print cmp_list([4,1,2,2,3,4], [$t->GetHistory])
    ? "ok $n\n" : "not ok $n\n"; $n++;
#print "@{[$t->GetHistory]}\n";

########################################################################
# 2.3.7 History Expansion

my ($string, $ret, @ret, $exp, @exp);

@list_set = ('red yellow', 'blue red', 'yellow blue', 'green blue');
$t->SetHistory(@list_set);
$t->history_set_pos(2);

# history_expand()
#print "${\($t->history_expand('!!'))}";
# !! : last entry of the history list
print $t->history_expand('!!') eq 'green blue'
    ? "ok $n\n" : "not ok $n\n"; $n++;
print $t->history_expand('!yel') eq 'yellow blue'
    ? "ok $n\n" : "not ok $n\n"; $n++;

($ret, $string) = $t->history_expand('!red');
print $ret == 1 && $string eq 'red yellow' ? "ok $n\n" : "not ok $n\n"; $n++;

# get_history_event()
my ($text, $cindex);
$string = '!-2 !?red? "!blu" white';

($text, $cindex) = $t->get_history_event($string, 0);
print $cindex == 3 && $text eq 'yellow blue' ? "ok $n\n" : "not ok $n\n"; $n++;
#print "$cindex,$text\n";

($text, $cindex) = $t->get_history_event($string, 3);
print $cindex == 3 && ! defined $text ? "ok $n\n" : "not ok $n\n"; $n++;
#print "$cindex,$text\n";

($text, $cindex) = $t->get_history_event($string, 4);
print $cindex == 10 && $text eq 'blue red' ? "ok $n\n" : "not ok $n\n"; $n++;
#print "$cindex,$text\n";

($text, $cindex) = $t->get_history_event($string, 12, '"');
print $cindex == 16 && $text eq 'blue red' ? "ok $n\n" : "not ok $n\n"; $n++;
#print "$cindex,$text\n";


# history_tokenize(), history_arg_extract()

$string = 'foo   "double quoted"& \'single quoted\' (paren)';
# for history_tokenize()
@exp = ('foo', '"double quoted"', '&', '\'single quoted\'', '(', 'paren', ')');
# for history_arg_extract()
$exp = "@exp";

@ret = $t->history_tokenize($string);
print cmp_list(\@ret, \@exp) ? "ok $n\n" : "not ok $n\n"; $n++;

$ret = $t->history_arg_extract($string, 0, '$'); #') comments for font-lock;
print $ret eq $exp ? "ok $n\n" : "not ok $n\n"; $n++;
$ret = $t->history_arg_extract($string, 0);
print $ret eq $exp ? "ok $n\n" : "not ok $n\n"; $n++;
$ret = $t->history_arg_extract($string);
print $ret eq $exp ? "ok $n\n" : "not ok $n\n"; $n++;
$_ = $string;
$ret = $t->history_arg_extract;
print $ret eq $exp ? "ok $n\n" : "not ok $n\n"; $n++;

end_of_test:

exit 0;

########################################################################
# subroutines

sub cmp_list {
    ($a, $b) = @_;
    my @a = @$a;
    my @b = @$b;
    return undef if $#a ne $#b;
    for (0..$#a) {
	return undef if $a[$_] ne $b[$_];
    }
    return 1;
}

sub show_indices {
    return;
    printf("where_history: %d ",	$t->where_history);
#    printf("current_history(): %s ",	$t->current_history);
    printf("history_base: %d, ",	$attribs->{history_base});
    printf("history_length: %d, ",	$attribs->{history_length});
#    printf("max_input_history: %d ",	$attribs->{max_input_history});
#    printf("history_total_bytes: %d ",	$t->history_total_bytes);
    print "\n";
}
