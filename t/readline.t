# -*- perl -*-
#	readline.t - Test script for Term::ReadLine:GNU
#
#	$Id: readline.t 475 2014-12-13 03:20:00Z hayashi $
#
#	Copyright (c) 1996 Hiroo Hayashi.  All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/readline.t'

BEGIN {
    print "1..140\n"; $n = 1;
    $ENV{PERL_RL} = 'Gnu';	# force to use Term::ReadLine::Gnu
    $ENV{LANG} = 'C';
}
END {print "not ok 1\tfail to loading\n" unless $loaded;}

# 'define @ARGV' is deprecated
my $verbose = scalar @ARGV && ($ARGV[0] eq 'verbose');

use strict;
use warnings;
use vars qw($loaded $n);
eval "use ExtUtils::testlib;" or eval "use lib './blib';";
use Term::ReadLine;
use Term::ReadLine::Gnu qw(ISKMAP ISMACR ISFUNC RL_STATE_INITIALIZED);

print "# Testing Term::ReadLine::Gnu version $Term::ReadLine::Gnu::VERSION\n";

$loaded = 1;
print "ok 1\tloading\n"; $n++;


# Perl-5.005 and later has Test.pm, but I define this here to support
# older version.
# MEMO: Since version TRL-1.10 Perl 5.7.0 has been required. So Test.pm
#       can be used now.
my $res;
my $ok = 1;
sub ok {
    my $what = shift || '';

    if ($res) {
	print "ok $n\t$what\n";
    } else {
	print "not ok $n\t$what";
	print @_ ? "\t@_\n" : "\n";
	$ok = 0;
    }
    $n++;
}

########################################################################
# test new method

# stop reading ~/.inputrc not to change the default key-bindings.
$ENV{'INPUTRC'} = '/dev/null';
# These tty setting affects GNU Readline key-bindings.
# Set the standard bindings before rl_initialize() being called.
# comment out since check_default_keybind_and_fix() takes care.
# system('stty erase  ^?') == 0 or warn "stty erase failed: $?";
# system('stty kill   ^u') == 0 or warn "stty kill failed: $?";
# system('stty lnext  ^v') == 0 or warn "stty lnext failed: $?";
# system('stty werase ^w') == 0 or warn "stty werase failed: $?";

my $t = new Term::ReadLine 'ReadLineTest';
$res =  defined $t; ok('new');

my $OUT;
if ($verbose) {
    $OUT = $t->OUT;
} else {
    open(NULL, '>/dev/null') or die "cannot open \`/dev/null\': $!\n";
    $OUT = \*NULL;
    $t->Attribs->{outstream} = \*NULL;
}

########################################################################
# test ReadLine method

$res = $t->ReadLine eq 'Term::ReadLine::Gnu';
ok('ReadLine method',
   "\tPackage name should be \`Term::ReadLine::Gnu\', but it is \`",
   $t->ReadLine, "\'\n");

########################################################################
# test Features method

my %features = %{ $t->Features };
$res = %features;
ok('Features method',"\tNo additional features present.\n");

########################################################################
# test Attribs method

my $a = $t->Attribs;
$res = defined $a; ok('Attrib method');

########################################################################
print "# 2.3 Readline Variables\n";

my ($maj, $min) = $a->{library_version} =~ /(\d+)\.(\d+)/;
my $version = $a->{readline_version};
if ($a->{library_version} eq '6.1') {
    # rl_readline_version returns 0x0600.  The bug is fixed GNU Readline 6.1-p2
    print "ok $n # skipped because GNU Readline Library 6.1 may return wrong value.\n";
    $n++;
} else {
    $res = ($version == 0x100 * $maj + $min); ok('readline_version');
}

# Version 2.0 and before are NOT supported.
$res = $version > 0x0200; ok('rl_version');

# check the values of initialized variables
$res = $a->{line_buffer} eq '';			ok;
$res = $a->{point} == 0;			ok;
$res = $a->{end} == 0;				ok;
$res = $a->{mark} == 0;				ok;
$res = $a->{done} == 0;				ok;

$res = $a->{num_chars_to_read} == 0;		ok('num_chars_to_read');
$res = $a->{pending_input} == 0;		ok('pending_input');
$res = $a->{dispatching} == 0;			ok('dispatching');

$res = $a->{erase_empty_line} == 0;		ok;
$res = ! defined($a->{prompt});			ok;
$res = $a->{display_prompt} eq "";		ok('display_prompt');
$res = $a->{already_prompted} == 0;		ok('already_prompted');
# library_version and readline_version are tested above.
$res = $a->{gnu_readline_p} == 1;		ok('gnu_readline_p');

if ($version < 0x0402) {
    # defined but left assgined as NULL
    $res = ! defined($a->{terminal_name});	ok;
} else {
    $res = $a->{terminal_name} eq $ENV{TERM};	ok;
}
$res = $a->{readline_name} eq 'ReadLineTest';	ok('readline_name');

# rl_instream and rl_outstream are tested below.
$res = $a->{prefer_env_winsize} == 0;		ok('prefer_envwin_size');
$res = ! defined($a->{last_func});		ok;

$res = ! defined($a->{startup_hook});		ok('startup_hook');
$res = ! defined($a->{pre_input_hook});		ok;
$res = ! defined($a->{event_hook});		ok;
$res = ! defined($a->{getc_function});		ok;
$res = ! defined($a->{signal_event_hook});	ok; # not tested!!!
$res = ! defined($a->{input_available_hook});	ok;
$res = ! defined($a->{redisplay_function});	ok;
$res = ! defined($a->{prep_term_function});	ok; # not tested!!!
$res = ! defined($a->{deprep_term_function});	ok; # not tested!!!

# not defined here
$res = ! defined($a->{executing_keymap});	ok('executing_keymap');
# anonymous keymap
$res = defined($a->{binding_keymap});		ok('binding_keymap');

$res = ! defined($a->{executing_macro});	ok('executing_macro');
$res = $a->{executing_key} == 0;		ok('executing_key');

if ($version < 0x0603) {
    $res = ! defined($a->{executing_keyseq});	ok('executing_keyseq');
} else {
    $res = defined($a->{executing_keyseq});	ok('executing_keyseq');
}
$res = $a->{key_sequence_length} == 0;		ok('key_sequence_length');

$res = ($a->{readline_state} == RL_STATE_INITIALIZED);
    ok('readline_state');
$res = $a->{explicit_arg} == 0;			ok('explicit_arg');
$res = $a->{numeric_arg} == 1;			ok('numeric_arg');
$res = $a->{editing_mode} == 1;			ok('editing_mode');


########################################################################
print "# 2.4 Readline Convenience Functions\n";

########################################################################
# define some custom functions

sub reverse_line {		# reverse a whole line
    my($count, $key) = @_;	# ignored in this sample function
    
    $t->modifying(0, $a->{end}); # save undo information
    $a->{line_buffer} = reverse $a->{line_buffer};
}

# From the GNU Readline Library Manual
# Invert the case of the COUNT following characters.
sub invert_case_line {
    my($count, $key) = @_;

    my $start = $a->{point};
    return 0 if ($start >= $a->{end});

    # Find the end of the range to modify.
    my $end = $start + $count;

    # Force it to be within range.
    if ($end > $a->{end}) {
	$end = $a->{end};
    } elsif ($end < 0) {
	$end = 0;
    }

    return 0 if $start == $end;

    if ($start > $end) {
	my $temp = $start;
	$start = $end;
	$end = $temp;
    }

    # Tell readline that we are modifying the line, so it will save
    # undo information.
    $t->modifying($start, $end);

    # I'm happy with Perl :-)
    substr($a->{line_buffer}, $start, $end-$start) =~ tr/a-zA-Z/A-Za-z/;

    # Move point to on top of the last character changed.
    $a->{point} = $count < 0 ? $start : $end - 1;
    return 0;
}

########################################################################
print "# 2.4.1 Naming a Function\n";

my ($func, $type);

# test add_defun
$res = (! defined($t->named_function('reverse-line'))
	&& ! defined($t->named_function('invert-case-line'))
	&& defined($t->named_function('operate-and-get-next'))
	&& defined($t->named_function('display-readline-version'))
	&& defined($t->named_function('change-ornaments')));
ok('add_defun');

($func, $type) = $t->function_of_keyseq("\ct");
$res = $type == ISFUNC && $t->get_function_name($func) eq 'transpose-chars';
ok;

$t->add_defun('reverse-line',		  \&reverse_line, ord "\ct");
$t->add_defun('invert-case-line',	  \&invert_case_line);

$res = (defined($t->named_function('reverse-line'))
	&& defined($t->named_function('invert-case-line'))
	&& defined($t->named_function('operate-and-get-next'))
	&& defined($t->named_function('display-readline-version'))
	&& defined($t->named_function('change-ornaments')));
ok;

($func, $type) = $t->function_of_keyseq("\ct");
$res = $type == ISFUNC && $t->get_function_name($func) eq 'reverse-line';
ok;

########################################################################
print "# 2.4.2 Selecting a Keymap\n";

# test rl_make_bare_keymap, rl_copy_keymap, rl_make_keymap, rl_discard_keymap
my $baremap = $t->make_bare_keymap;
$t->bind_key(ord "a", 'abort', $baremap);
my $copymap = $t->copy_keymap($baremap);
$t->bind_key(ord "b", 'abort', $baremap);
my $normmap = $t->make_keymap;

$res = (($t->get_function_name(($t->function_of_keyseq('a', $baremap))[0])
	 eq 'abort')
	&& ($t->get_function_name(($t->function_of_keyseq('b', $baremap))[0])
	    eq 'abort')
	&& ($t->get_function_name(($t->function_of_keyseq('a', $copymap))[0])
	    eq 'abort')
	&& ! defined($t->function_of_keyseq('b', $copymap))
	&& ($t->get_function_name(($t->function_of_keyseq('a', $normmap))[0])
	    eq 'self-insert'));
ok('bind_key');

$t->discard_keymap($baremap);
$t->discard_keymap($copymap);
$t->discard_keymap($normmap);

# test rl_get_keymap, rl_set_keymap, rl_get_keymap_by_name, rl_get_keymap_name
$res = $t->get_keymap_name($t->get_keymap) eq 'emacs';
ok;

$t->set_keymap('vi');
$res = $t->get_keymap_name($t->get_keymap) eq 'vi';
ok;

# equivalent to $t->set_keymap('emacs');
$t->set_keymap($t->get_keymap_by_name('emacs'));
$res = $t->get_keymap_name($t->get_keymap) eq 'emacs';
ok;

########################################################################
print "# 2.4.3 Binding Keys\n";

#print $t->get_keymap_name($a->{executing_keymap}), "\n";
#print $t->get_keymap_name($a->{binding_keymap}), "\n";

# test rl_bind_key (rl_bind_key_in_map), rl_bind_key_if_unbound!!!,
# rl_bind_keyseq!!!, rl_set_key, rl_bind_keyseq_if_unbound!!!, 
# rl_generic_bind, rl_parse_and_bind

# define subroutine to use again later
my ($helpmap, $mymacro);
sub bind_my_function {
    $t->bind_key(ord "\ct", 'reverse-line');
    $t->bind_key(ord "\cv", 'display-readline-version', 'emacs-ctlx');
    $t->parse_and_bind('"\C-xv": display-readline-version');
    $t->bind_key(ord "c", 'invert-case-line', 'emacs-meta');
    if ($version >= 0x0402) {
	# rl_set_key in introduced by GRL 4.2
	$t->set_key("\eo", 'change-ornaments');
    } else {
	$t->bind_key(ord "o", 'change-ornaments', 'emacs-meta');
    }
    $t->bind_key(ord "^", 'history-expand-line', 'emacs-meta');
    
    # make an original map
    $helpmap = $t->make_bare_keymap();
    $t->bind_key(ord "f", 'dump-functions', $helpmap);
    $t->generic_bind(ISKMAP, "\e?", $helpmap);
    $t->bind_key(ord "v", 'dump-variables', $helpmap);
    # 'dump-macros' is documented but not defined by GNU Readline 2.1
    $t->generic_bind(ISFUNC, "\e?m", 'dump-macros') if $version > 0x0201;
    
    # bind a macro
    $mymacro = "\ca[insert text from the beginning of line]";
    $t->generic_bind(ISMACR, "\e?i", $mymacro);
}

bind_my_function;		# do bind

{
    my ($fn, $ty);
    # check keymap binding
    ($fn, $ty) = $t->function_of_keyseq("\cX");
    $res = $t->get_keymap_name($fn) eq 'emacs-ctlx' && $ty == ISKMAP;
    ok('keymap binding');

    # check macro binding
    ($fn, $ty) = $t->function_of_keyseq("\e?i");
    $res = $fn eq $mymacro && $ty == ISMACR;
    ok('macro binding');
}

# check function binding
$res = (is_boundp("\cT", 'reverse-line')
	&& is_boundp("\cX\cV", 'display-readline-version')
	&& is_boundp("\cXv",   'display-readline-version')
	&& is_boundp("\ec",    'invert-case-line')
	&& is_boundp("\eo",    'change-ornaments')
	&& is_boundp("\e^",    'history-expand-line')
	&& is_boundp("\e?f",   'dump-functions')
	&& is_boundp("\e?v",   'dump-variables')
	&& ($version <= 0x0201 or is_boundp("\e?m",   'dump-macros')));
ok('function binding');

# test rl_read_init_file
$res = $t->read_init_file('t/inputrc') == 0;
ok('rl_read_init_file');

$res = (is_boundp("a", 'abort')
	&& is_boundp("b", 'abort')
	&& is_boundp("c", 'self-insert'));
ok;

# resume
$t->bind_key(ord "a", 'self-insert');
$t->bind_key(ord "b", 'self-insert');
$res = (is_boundp("a", 'self-insert')
	&& is_boundp("b", 'self-insert'));
ok;

# test rl_unbind_key (rl_unbind_key_in_map),
#      rl_unbind_command (rl_unbind_command_in_map),
#      rl_unbind_function (rl_unbind_function_in_map)
$t->unbind_key(ord "\ct");	# reverse-line
$t->unbind_key(ord "f", $helpmap); # dump-function
$t->unbind_key(ord "v", 'emacs-ctlx'); # display-readline-version
if ($version > 0x0201) {
    $t->unbind_command_in_map('display-readline-version', 'emacs-ctlx');
    $t->unbind_function_in_map($t->named_function('dump-variables'), $helpmap);
} else {
    $t->unbind_key(ord "\cV", 'emacs-ctlx');
    $t->unbind_key(ord "v", $helpmap);
}

my @keyseqs = ($t->invoking_keyseqs('reverse-line'),
	       $t->invoking_keyseqs('dump-functions'),
	       $t->invoking_keyseqs('display-readline-version'),
	       $t->invoking_keyseqs('dump-variables'));
$res = scalar @keyseqs == 0; ok('unbind_key',"@keyseqs");

if ($version >= 0x0402) {
    $t->add_funmap_entry('foo_bar', 'reverse-line');
# This does not work.  We need `equal' in Lisp.
#    $res = ($t->named_function('reverse-line')
#	    == $t->named_function('foo_bar'));
    $res = defined $t->named_function('foo_bar');
    ok('add_funmap_entry');
} else {
    print "ok $n # skipped because GNU Readline Library is older than 4.2.\n";
    $n++;
}
########################################################################
print "# 2.4.4 Associating Function Names and Bindings\n";

bind_my_function;		# do bind

# rl_named_function, get_function_name, rl_function_of_keyseq,
# rl_invoking_keyseqs, and rl_add_funmap_entry, are tested above.
# rl_function_dumper!!!, rl_list_funmap_names!!!, rl_funmap_names!!!

# test rl_invoking_keyseqs
@keyseqs = $t->invoking_keyseqs('abort', 'emacs-ctlx');
$res = "\\C-g" eq "@keyseqs";
ok('invoking_keyseqs');

########################################################################
print "# 2.4.5 Allowing Undoing\n";
# rl_begin_undo_group!!!, rl_end_undo_group!!!, rl_add_undo!!!,
# rl_free_undo_list!!!, rl_do_undo!!!, rl_modifying

########################################################################
print "# 2.4.6 Redisplay\n";
# rl_redisplay!!!, rl_forced_update_display, rl_on_new_line!!!,
# rl_on_new_line_with_prompt!!!, rl_reset_line_state!!!, rl_crlf!!!,
# rl_show_char!!!,
# rl_message, rl_clear_message, rl_save_prompt, rl_restore_prompt:
#   see Gnu/XS.pm:change_ornaments()
# rl_expand_prompt!!!, rl_set_prompt!!!

########################################################################
print "# 2.4.7 Modifying Text\n";
# rl_insert_text!!!, rl_delete_text!!!, rl_copy_text!!!, rl_kill_text!!!,
# rl_push_macro_input!!!

########################################################################
print "# 2.4.8 Character Input\n";
# rl_read_key!!!, rl_getc, rl_stuff_char!!!, rl_execute_next!!!,
# rl_clear_pending_input!!!, rl_set_keyboard_input_timeout!!!

########################################################################
print "# 2.4.9 Terminal Management\n";
# rl_prep_terminal!!!, rl_deprep_terminal!!!,
# rl_tty_set_default_bindings!!!, rl_tty_unset_default_bindings!!!,
# rl_reset_terminal!!!

########################################################################
print "# 2.4.10 Utility Functions\n";
# rl_save_state!!!, rl_restore_state!!!, rl_replace_line!!!,
# rl_initialize, rl_ding!!!, rl_alphabetic!!!,
# rl_display_match_list

########################################################################
print "# 2.4.11 Miscellaneous Functions\n";
# rl_macro_bind!!!, rl_macro_dumpter!!!,
# rl_variable_bind!!!, rl_variable_value!!!, rl_variable_dumper!!!
# rl_set_paren_blink_timeout!!!, rl_get_termcap!!!, rl_clear_history!!!

########################################################################
print "# 2.4.12 Alternate Interface\n";
# tested in callback.t
# rl_callback_handler_install, rl_callback_read_char,
# rl_callback_handler_remove,

########################################################################
print "# 2.5 Readline Signal Handling\n";
$res = $a->{catch_signals} == 1;		ok('catch_signals');
$res = $a->{catch_sigwinch} == 1;		ok('catch_sigwinch');
$res = $a->{change_environment} == 1;		ok('change_environment');

# rl_cleanup_after_signal!!!, rl_free_line_state!!!,
# rl_reset_after_signal!!!, rl_echo_signal_char!!!, rl_resize_terminal!!!,

# rl_set_screen_size, rl_get_screen_size
if ($version >= 0x0402) {
    my ($rowsav, $colsav) =  $t->get_screen_size;
    $t->set_screen_size(60, 132);
    my ($row, $col) =  $t->get_screen_size;
    # col=131 on a terminal which does not support auto-wrap function
    $res = ($row == 60 && ($col == 132 || $col == 131));
    ok('set/get_screen_size');
    $t->set_screen_size($rowsav, $colsav);
} else {
    print "ok $n # skipped because GNU Readline Library is older than 4.2.\n";
    $n++;
}

# rl_reset_screen_size!!!, rl_set_signals!!!, rl_clear_signals!!!

########################################################################
print "# 2.6 Custom Completers\n";
print "# 2.6.1 How Completing Works\n";
print "# 2.6.2 Completion Functions\n";
# rl_complete_internal!!!, rl_completion_mode!!!, rl_completion_matches,
# rl_filename_completion_function, rl_username_completion_function,
# list_completion_function

print "# 2.6.3 Completion Variables\n";
$res = ! defined $a->{completion_entry_function};	ok;
$res = ! defined $a->{attempted_completion_function};	ok;
$res = ! defined $a->{filename_quoting_function};	ok;
$res = ! defined $a->{filename_dequoting_function};	ok;
$res = ! defined $a->{char_is_quoted_p};		ok('char_is_quoted_p');
$res = ! defined $a->{ignore_some_completions_function};ok;
$res = ! defined $a->{directory_completions_hook};	ok;
$res = ! defined $a->{directory_rewrite_hook};		ok;
$res = ! defined $a->{filename_stat_hook};		ok;
$res = ! defined $a->{filename_rewrite_hook};		ok;
$res = ! defined $a->{completions_display_matches_hook};ok;

$res = ($a->{basic_word_break_characters}
	eq " \t\n\"\\'`\@\$><=;|&{(");			ok;
$res = $a->{basic_quote_characters} eq "\"'";		ok;
$res = ($a->{completer_word_break_characters}
	eq " \t\n\"\\'`\@\$><=;|&{(");			ok;
$res = ! defined $a->{completion_word_break_hook};	ok;
$res = ! defined $a->{completer_quote_characters};	ok;
$res = ! defined $a->{filename_quote_characters};	ok;
$res = ! defined $a->{special_prefixes};		ok('special_prefixes');

$res = $a->{completion_query_items} == 100;		ok;
$res = $a->{completion_append_character} eq " ";	ok;

$res = $a->{completion_suppress_append} == 0;		ok;
$res = $a->{completion_quote_character} eq "\0";	ok;
$res = $a->{completion_suppress_quote} == 0;		ok;
$res = $a->{completion_found_quote} == 0;		ok;
$res = $a->{completion_mark_symlink_dirs} == 0;		ok;

$res = $a->{ignore_completion_duplicates} == 1;		ok;
$res = $a->{filename_completion_desired} == 0;		ok;
$res = $a->{filename_quoting_desired} == 1;		ok;
$res = $a->{attempted_completion_over} == 0;		ok;
$res = $a->{sort_completion_matches} == 1;		ok;

$res = $a->{completion_type} == 0;			ok('completion_type');
$res = $a->{completion_invoking_key} eq "\0";		ok;
$res = $a->{inhibit_completion} == 0;			ok;


########################################################################

$t->parse_and_bind('set bell-style none'); # make readline quiet

my ($INSTR, $line);
# simulate key input by using a variable 'rl_getc_function'
$a->{getc_function} = sub {
    unless (length $INSTR) {
	print $OUT "Error: getc_function: insufficient string, \`\$INSTR\'.";
	undef $a->{getc_function};
	return 0;
    }
    my $c  = substr $INSTR, 0, 1; # the first char of $INSTR
    $INSTR = substr $INSTR, 1;	# rest of $INSTR
    return ord $c;
};

# This is required after GNU Readline Library 6.3.
$a->{input_available_hook} = sub {
    return 1;
};

# check some key binding used by following test
sub is_boundp {
    my ($seq, $fname) = @_;
    my ($fn, $type) = $t->function_of_keyseq($seq);
    if ($fn) {
	return ($t->get_function_name($fn) eq $fname
		&& $type == ISFUNC);
    } else {
	warn ("No function is bound for sequence \`", toprint($seq),
	      "\'.  \`$fname\' is expected,");
	return 0;
    }
}

sub check_default_keybind_and_fix {
    my ($seq, $fname) = @_;
    if (is_boundp($seq, $fname)) {
	print "ok $n\t$fname is bound to " . toprint($seq) . "\n";
    } else {
	# Try to fix the binding.  But tty setting seems have precedence.
	$t->set_key($seq, $fname);
	if (is_boundp($seq, $fname)) {
	    print "ok $n\tThe default keybinding for $fname was changed. Fixed.\n";
	    print "$fname is bound to " . toprint($seq) . "\n";
	} else {
	    print "not ok $n\t$fname cannot be bound to " . toprint($seq) . "\n";
	    $ok = 0;
	}
    }
    $n++;
}
check_default_keybind_and_fix("\cM", 'accept-line');
check_default_keybind_and_fix("\cF", 'forward-char');
check_default_keybind_and_fix("\cB", 'backward-char');
check_default_keybind_and_fix("\ef", 'forward-word');
check_default_keybind_and_fix("\eb", 'backward-word');
check_default_keybind_and_fix("\cE", 'end-of-line');
check_default_keybind_and_fix("\cA", 'beginning-of-line');
check_default_keybind_and_fix("\cH", 'backward-delete-char');
check_default_keybind_and_fix("\cD", 'delete-char');
check_default_keybind_and_fix("\cI", 'complete');

$INSTR = "abcdefgh\cM";
$line = $t->readline("self insert> ");
$res = $line eq 'abcdefgh'; ok('self insert', $line);

$INSTR = "\cAe\cFf\cBg\cEh\cH ij kl\eb\ebm\cDn\cM";
$line = $t->readline("cursor move> ", 'abcd'); # default string
$res = $line eq 'eagfbcd mnj kl'; ok('cursor move', $line);

# test reverse_line, display_readline_version, invert_case_line
$INSTR = "\cXvabcdefgh XYZ\e6\cB\e4\ec\cT\cM";
$line = $t->readline("custom commands> ");
$res = $line eq 'ZYx HGfedcba'; ok('custom commands', $line);

# test undo of reverse_line
$INSTR = "abcdefgh\cTi\c_\c_\cM";
$line = $t->readline("test undo> ");
$res = $line eq 'abcdefgh'; ok('undo', $line);

# test macro, change_ornaments
$INSTR = "1234\e?i\eoB\cM\cM";
$line = $t->readline("keyboard macro> ");
$res = $line eq "[insert text from the beginning of line]1234"; ok('macro', $line);
$INSTR = "\cM";
$line = $t->readline("bold face prompt> ");
$res = $line eq ''; ok('ornaments', $line);

# test operate_and_get_next
$INSTR = "one\cMtwo\cMthree\cM\cP\cP\cP\cO\cO\cO\cM";
$line = $t->readline("> ");	# one
$line = $t->readline("> ");	# two
$line = $t->readline("> ");	# three
$line = $t->readline("> ");
$res = $line eq 'one';	 ok('operate_and_get_next 1', $line);
$line = $t->readline("> ");
$res = $line eq 'two';	 ok('operate_and_get_next 2', $line);
$line = $t->readline("> ");
$res = $line eq 'three'; ok('operate_and_get_next 3', $line);
$line = $t->readline("> ");
$res = $line eq 'one';	 ok('operate_and_get_next 4', $line);

########################################################################
print "# test history expansion\n";

$t->ornaments(0);		# ornaments off

#print $OUT "\n# history expansion test\n# quit by EOF (\\C-d)\n";
$a->{do_expand} = 1;
$t->MinLine(4);

sub prompt {
    # equivalent with "$nline = $t->where_history + 1"
    my $nline = $a->{history_base} + $a->{history_length};
    "$nline> ";
}

$INSTR = "!1\cM";
$line = $t->readline(prompt);
$res = $line eq 'abcdefgh'; ok('history 1', $line);

$INSTR = "123\cM";		# too short
$line = $t->readline(prompt);
$INSTR = "!!\cM";
$line = $t->readline(prompt);
$res = $line eq 'abcdefgh'; ok('history 2', $line);

$INSTR = "1234\cM";
$line = $t->readline(prompt);
$INSTR = "!!\cM";
$line = $t->readline(prompt);
$res = $line eq '1234'; ok('history 3', $line);

########################################################################
print "# test custom completion function\n";

$t->parse_and_bind('set bell-style none'); # make readline quiet

$INSTR = "t/comp\cI\e*\cM";
$line = $t->readline("insert completion>");
# "a_b" < "README" on some kind of locale since strcoll() is used in
# the GNU Readline Library.
# Not all perl support setlocale.  My perl supports locale and I tried
#   use POSIX qw(locale_h); setlocale(LC_COLLATE, 'C');
# But it seems that it does not affect strcoll() linked to GNU
# Readline Library.
$res = $line eq 't/comptest/0123 t/comptest/012345 t/comptest/023456 t/comptest/README t/comptest/a_b '
    || $line eq 't/comptest/0123 t/comptest/012345 t/comptest/023456 t/comptest/a_b t/comptest/README '
    || $line eq 't/comptest/.svn t/comptest/0123 t/comptest/012345 t/comptest/023456 t/comptest/README t/comptest/a_b '
    || $line eq 't/comptest/.svn t/comptest/0123 t/comptest/012345 t/comptest/023456 t/comptest/a_b t/comptest/README ';
ok('insert completion', $line);

$INSTR = "t/comp\cIR\cI\cM";
$line = $t->readline("filename completion (default)>");
$res = $line eq 't/comptest/README '; ok('default completion', $line);

$a->{completion_entry_function} = $a->{'username_completion_function'};
my $user = getlogin || 'root';
$INSTR = "${user}\cI\cM";
$line = $t->readline("username completion>");
if ($line eq "${user} ") {
    print "ok $n\tusername completion\n"; $n++;
} elsif ($line eq ${user}) {
    print "ok $n\t# skipped.  It seems that there is no user whose name is '${user}' or there is a user whose name starts with '${user}'\n"; $n++;
} else {
    print "not ok $n\tusername completion\n"; $n++;
    $ok = 0;
}

$a->{completion_word} = [qw(a list of words for completion and another word)];
$a->{completion_entry_function} = $a->{'list_completion_function'};
print $OUT "given list is: a list of words for completion and another word\n";
$INSTR = "a\cI\cIn\cI\cIo\cI\cM";
$line = $t->readline("list completion>");
$res = $line eq 'another '; ok('list completion', $line);


$a->{completion_entry_function} = $a->{'filename_completion_function'};
$INSTR = "t/comp\cI\cI\cI0\cI\cI1\cI\cI\cM";
$line = $t->readline("filename completion>");
$res = $line eq 't/comptest/0123'; ok('filename completion', $line);
undef $a->{completion_entry_function};

# attempted_completion_function

$a->{attempted_completion_function} = sub { undef; };
$a->{completion_entry_function} = sub {};
$INSTR = "t/comp\cI\cM";
$line = $t->readline("null completion 1>");
$res = $line eq 't/comp'; ok('null completion 1', $line);

$a->{attempted_completion_function} = sub { (undef, undef); };
undef $a->{completion_entry_function};
$INSTR = "t/comp\cI\cM";
$line = $t->readline("null completion 2>");
$res = $line eq 't/comptest/'; ok('null completion 2', $line);

sub sample_completion {
    my ($text, $line, $start, $end) = @_;
    # If first word then username completion, else filename completion
    if (substr($line, 0, $start) =~ /^\s*$/) {
	return $t->completion_matches($text, $a->{'list_completion_function'});
    } else {
	return ();
    }
}

$a->{attempted_completion_function} = \&sample_completion;
print $OUT "given list is: a list of words for completion and another word\n";
$INSTR = "li\cIt/comp\cI\cI\cI0\cI\cI2\cI\cM";
$line = $t->readline("list & filename completion>");
$res = $line eq 'list t/comptest/023456 '; ok('list & file completion', $line);
undef $a->{attempted_completion_function};

# ignore_some_completions_function
$a->{ignore_some_completions_function} = sub {
    return (grep m|/$| || ! m|^(.*/)?[0-9]*$|, @_);
};
$INSTR = "t/co\cIRE\cI\cM";
$line = $t->readline("ignore_some_completion>");
$res = $line eq 't/comptest/README '; ok('ingore_some_completion', $line);
undef $a->{ignore_some_completions_function};

# char_is_quoted, filename_quoting_function, filename_dequoting_function

sub char_is_quoted ($$) {	# borrowed from bash-2.03:subst.c
    my ($string, $eindex) = @_;
    my ($i, $pass_next);

    for ($i = $pass_next = 0; $i <= $eindex; $i++) {
	my $c = substr($string, $i, 1);
	if ($pass_next) {
	    $pass_next = 0;
	    return 1 if ($i >= $eindex); # XXX was if (i >= eindex - 1)
	} elsif ($c eq '\'') {
	    $i = index($string, '\'', ++$i);
	    return 1 if ($i == -1 || $i >= $eindex);
#	} elsif ($c eq '"') {	# ignore double quote
	} elsif ($c eq '\\') {
	    $pass_next = 1;
	}
    }
    return 0;
}
$a->{char_is_quoted_p} = \&char_is_quoted;
$a->{filename_quoting_function} = sub {
    my ($text, $match_type, $quote_pointer) = @_;
    my $qc = $a->{filename_quote_characters};
    return $text if $quote_pointer;
    $text =~ s/[\Q${qc}\E]/\\$&/;
    return $text;
};
$a->{filename_dequoting_function} = sub {
    my ($text, $quote_char) = @_;
    $quote_char = chr $quote_char;
    $text =~ s/\\//g;
    return $text;
};

$a->{completer_quote_characters} = '\'';
$a->{filename_quote_characters} = ' _\'\\';

$INSTR = "t/comp\cIa\cI 't/comp\cIa\cI\cM";
$line = $t->readline("filename_quoting_function>");
$res = $line eq 't/comptest/a\\_b  \'t/comptest/a_b\' ';
ok('filename_quoting_function', $line);

$INSTR = "\'t/comp\cIa\\_\cI\cM";
$line = $t->readline("filename_dequoting_function>");
$res = $line eq '\'t/comptest/a_b\' ';
ok('filename_dequoting_function', $line);

undef $a->{char_is_quoted_p};
undef $a->{filename_quoting_function};
undef $a->{filename_dequoting_function};

# directory_completion_hook
$a->{directory_completion_hook} = sub {
    if ($_[0] eq 'comp/') {	# simple alias function
	$_[0] = 't/comptest/';
	return 1;
    } else {
	return 0;
    }
};

$INSTR = "comp/\cI\cM";
$line = $t->readline("directory_completion_hook>");
$res = $line eq 't/comptest/';
ok('directory_completion_hook', $line);
undef $a->{directory_completion_hook};

# filename_list
my @m = $t->filename_list('t/comptest/01');
$res = $#m == 1;
ok('filename_list', $#m);

$t->parse_and_bind('set bell-style audible'); # resume to default style

########################################################################
print "# test rl_startup_hook, rl_pre_input_hook\n";

$a->{startup_hook} = sub { $a->{point} = 10; };
$INSTR = "insert\cM";
$line = $t->readline("rl_startup_hook test>", "cursor is, <- here");
$res = $line eq 'cursor is,insert <- here'; ok('startup_hook', $line);
$a->{startup_hook} = undef;

$a->{pre_input_hook} = sub { $a->{point} = 10; };
$INSTR = "insert\cM";
$line = $t->readline("rl_pre_input_hook test>", "cursor is, <- here");
if ($version >= 0x0400) {
    $res = $line eq 'cursor is,insert <- here'; ok('pre_input_hook', $line);
} else {
    print "ok $n # skipped because GNU Readline Library is older than 4.0.\n";
    $n++;
}
$a->{pre_input_hook} = undef;

#########################################################################
print "# test redisplay_function\n";
$a->{redisplay_function} = $a->{shadow_redisplay};
$INSTR = "\cX\cVThis is a password.\cM";
$line = $t->readline("password> ");
$res = $line eq 'This is a password.'; ok('redisplay_function', $line);
undef $a->{redisplay_function};

print "ok $n\n"; $n++;

#########################################################################
#print " test rl_display_match_list\n";

if ($version >= 0x0400) {
    my @match_list = @{$a->{completion_word}};
    $t->display_match_list(\@match_list);
    $t->parse_and_bind('set print-completions-horizontally on');
    $t->display_match_list(\@match_list);
    $t->parse_and_bind('set print-completions-horizontally off');
    print "ok $n\n"; $n++;
} else {
    print "ok $n # skipped because GNU Readline Library is older than 4.0.\n";
    $n++;
}

#########################################################################
print "# test rl_completion_display_matches_hook\n";

if ($version >= 0x0400) {
    # See 'eg/perlsh' for better example
    $a->{completion_display_matches_hook} = sub  {
	my($matches, $num_matches, $max_length) = @_;
	map { $_ = uc $_; }(@{$matches});
	$t->display_match_list($matches);
	$t->forced_update_display;
    };
    $t->parse_and_bind('set bell-style none'); # make readline quiet
    $INSTR = "Gnu.\cI\cI\cM";
    $t->readline("completion_display_matches_hook>");
    undef $a->{completion_display_matches_hook};
    print "ok $n\n"; $n++;
    $t->parse_and_bind('set bell-style audible'); # resume to default style
} else {
    print "ok $n # skipped because GNU Readline Library is older than 4.0.\n";
    $n++;
}

########################################################################
print "# test ornaments\n";

$INSTR = "\cM\cM\cM\cM\cM\cM\cM";
print $OUT "# ornaments test\n";
print $OUT "# Note: Some function may not work on your terminal.\n";
# Kterm seems to have a bug with 'ue' (End underlining) does not work\n";
$t->ornaments(1);	# equivalent to 'us,ue,md,me'
print $OUT "\n" unless defined $t->readline("default ornaments (underline)>");
# cf. man termcap(5)
$t->ornaments('so,me,,');
print $OUT "\n" unless defined $t->readline("standout>");
$t->ornaments('us,me,,');
print $OUT "\n" unless defined $t->readline("underlining>");
$t->ornaments('mb,me,,');
print $OUT "\n" unless defined $t->readline("blinking>");
$t->ornaments('md,me,,');
print $OUT "\n" unless defined $t->readline("bold>");
$t->ornaments('mr,me,,');
print $OUT "\n" unless defined $t->readline("reverse>");
# It seems that on some systems a visible bell cannot be redirected
# to /dev/null and confuses ExtUtils::Command:MM::test_harness().
$t->ornaments('vb,,,') if $verbose;
print $OUT "\n" unless defined $t->readline("visible bell>");
$t->ornaments(0);
print $OUT "# end of ornaments test\n";

print "ok $n\n"; $n++;

########################################################################
print "# end of non-interactive test\n";
unless ($verbose) {
    # Be quiet during CPAN Testers testing.
    print STDERR "ok\tTry \`$^X -Mblib t/readline.t verbose\', if you will.\n"
	if ($ok && !$ENV{AUTOMATED_TESTING});
    exit 0;
}
undef $a->{getc_function};
undef $a->{input_available_hook};

########################################################################
print "# interactive test\n";

########################################################################
# test redisplay_function

$a->{redisplay_function} = $a->{shadow_redisplay};
$line = $t->readline("password> ");
print "<$line>\n";
undef $a->{redisplay_function};

########################################################################
# test rl_getc_function and rl_getc()

sub uppercase {
#    my $FILE = $a->{instream};
#    return ord uc chr $t->getc($FILE);
    return ord uc chr $t->getc($a->{instream});
}

$a->{getc_function} = \&uppercase;
print $OUT "\n" unless defined $t->readline("convert to uppercase>");
undef $a->{getc_function};
undef $a->{input_available_hook};

########################################################################
# test event_hook

my $timer = 20;			# 20 x 0.1 = 2.0 sec timer
$a->{event_hook} = sub {
    if ($timer-- < 0) {
	$a->{done} = 1;
	undef $a->{event_hook};
    }
};
$line = $t->readline("input in 2 seconds> ");
undef $a->{event_hook};
print "<$line>\n";

########################################################################
# convert control charactors to printable charactors (ex. "\cx" -> '\C-x')
sub toprint {
    join('',
	 map{$_ eq "\e" ? '\M-': ord($_)<32 ? '\C-'.lc(chr(ord($_)+64)) : $_}
	 (split('', $_[0])));
}

my %TYPE = (0 => 'Function', 1 => 'Keymap', 2 => 'Macro');

print $OUT "\n# Try the following commands.\n";
foreach ("\co", "\ct", "\cx",
	 "\cx\cv", "\cxv", "\ec", "\e^",
	 "\e?f", "\e?v", "\e?m", "\e?i", "\eo") {
    my ($p, $type) = $t->function_of_keyseq($_);
    printf $OUT "%-9s: ", toprint($_);
    (print "\n", next) unless defined $type;
    printf $OUT "%-8s : ", $TYPE{$type};
    if    ($type == ISFUNC) { print $OUT ($t->get_function_name($p)); }
    elsif ($type == ISKMAP) { print $OUT ($t->get_keymap_name($p)); }
    elsif ($type == ISMACR) { print $OUT (toprint($p)); }
    else { print $OUT "Error: Illegal type value"; }
    print $OUT "\n";
}

print $OUT "\n# history expansion test\n# quit by EOF (\\C-d)\n";
$a->{do_expand} = 1;
while (defined($line = $t->readline(prompt))) {
    print $OUT "<<$line>>\n";
}
print $OUT "\n";
