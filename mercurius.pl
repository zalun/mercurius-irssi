use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '0.0.1';
%IRSSI = (
	name => 'mercurius',
	authors => 'Piotr Zalewa',
	contact => 'https://piotr.zalewa.info/contact/',
	url => 'https://piotr.zalewa.info/',
	description => 'Send mentiones to mercurius notification server.',
	license => 'MIT',
	changed => '$Date: 2015-11-16 12:00:00 +0500 (Tue, 16 Nov 2015) $'
);

#	AUTHORS
#
# Linking to Mercurius by Piotr Zalewa
#
# Modified version by James Shubin:
# https://ttboj.wordpress.com/
#
# Modified from the Thorsten Leemhuis <fedora@leemhuis.info> version:
# http://www.leemhuis.info/files/fnotify/fnotify
#
# In parts based on knotify.pl 0.1.1 by Hugo Haas:
# http://larve.net/people/hugo/2005/01/knotify.pl
#
# Which is based on osd.pl 0.3.3 by Jeroen Coekaerts, Koenraad Heijlen:
# http://www.irssi.org/scripts/scripts/osd.pl
#
# Other parts based on notify.pl from Luke Macken:
# http://fedora.feedjack.org/user/918/

my $token;
my $enabled;

# register settings
Irssi::settings_add_str("mercurius", "mercurius_token", "");
Irssi::settings_add_bool("mercurius", "mercurius_enabled", 0);
Irssi::settings_add_host("mercurius", "mercurius_host", 'http://localhost:4000');

#
#   reload settings after change
#
sub reload_settings {
	$token = Irssi::settings_get_str('mercurius_token');
	$enabled = Irssi::settings_get_bool('mercurius_enabled');
	$host = Irssi::settings_get_str('mercurius_host');
	if (not $enabled) {
		print 'Mercurius notifications are stopped.';
	}
}


#
#   set the mercurius host
#
sub set_host {
	my ($host) = @_;
	if (not $host) {
		print 'No host provided';
		return;
	}
	Irssi::settings_set_str('mercurius_host', $host);
	Irssi::signal_emit('setup changed');
	print 'Mercurius host set to ' . $host . '. Use /SAVE command to make it permanent.';
}

#
#   check if token is registered, if so - set it
#
sub set_token {
	my ($token) = @_;
	if (not $token) {
		print 'No token provided';
		return;
	}
	my $valid = 0;
	# validate token
	# send notification
	# if 404 token is invalid
	# XXX assume it's valid
	Irssi::settings_set_str('mercurius_token', $token);
	Irssi::settings_set_bool('mercurius_enabled', 1);
	Irssi::signal_emit('setup changed');
	print 'Mercurius token set. Use /SAVE command to make it permanent.';
}

#
#	stop sending notifications
#
sub stop {
	Irssi::settings_set_bool('mercurius_enabled', 0);
	Irssi::signal_emit('setup changed');
}

#
#	restart sending notifications
#
sub start {
	if (not $enabled) {
		Irssi::settings_set_bool('mercurius_enabled', 1);
		# send a message saying that sending notifications is restored
		Irssi::signal_emit('setup changed');
		print 'Mercurius restarted';
	}
}

#
#	catch private messages
#
sub priv_msg {
	if ($enabled) {
		my ($server, $msg, $nick, $address, $target) = @_;
		#filewrite($nick . ' ' . $msg);
		#my $test = Dumper($server);
		my $network = $server->{tag};
		send_notification('' . $network . ' ' . $nick . ' ' . $msg);
	}
}

#
#	catch 'hilight's
#
sub hilight {
	if ($enabled) {
		my ($dest, $text, $stripped) = @_;
		if ($dest->{level} & MSGLEVEL_HILIGHT) {
			#filewrite($dest->{target} . ' ' . $stripped);
			#my $test = Dumper($dest);
			my $server = $dest->{server};
			my $network = $server->{tag};
			send_notification($network . ' ' . $dest->{target} . ' ' . $stripped);
		}
	}
}

#
#	write to file
#
sub send_notification {
	if ($enabled) {
		my ($text) = @_;
		# FIXME: there is probably a better way to get the irssi-dir...
		open(FILE, ">>$ENV{HOME}/.irssi/fnotify");
		print FILE $token . ' --- ' . $text . "\n";
		close(FILE);
	}
}

#
#	manage commands
#	/mercurius command attribute list
#
my $commands="set_token set_host start stop";
sub command {
	my ($argument_string, $server_obj, $window_item_obj) = @_;
	my ($command_name, @arguments) = split(' ', $argument_string);
	if (index($commands, $command_name) == -1) {
		print "Mercurius ERROR: No such method: " . $command_name;
		return;
	}
	my $command = \&$command_name;
	&$command(@arguments);
}

reload_settings();

#
#	irssi signals
#
Irssi::signal_add_last("message private", "priv_msg");
Irssi::signal_add_last("print text", "hilight");
Irssi::signal_add('setup changed', "reload_settings");

#
#	bind main command
#
Irssi::command_bind('mercurius', 'command');
