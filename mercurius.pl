use strict;
use HTTP::Tiny;
use vars qw($VERSION %IRSSI);
use JSON::PP;

my $json = JSON::PP->new->allow_nonref;

use Irssi;
$VERSION = '0.0.1';
%IRSSI = (
	name => 'mercurius',
	authors => 'Piotr Zalewa, Marco Castelluccio',
	contact => 'zalun@mozilla.com',
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
my $host;
my $intense;
# check if message was already sent
# reset every time window is changed
my $priv_notified;

# register settings
Irssi::settings_add_str("mercurius", "mercurius_token", "");
Irssi::settings_add_bool("mercurius", "mercurius_enabled", 0);
Irssi::settings_add_str("mercurius", "mercurius_host", 'https://mozcurius.herokuapp.com');
Irssi::settings_add_int("mercurius", "mercurius_intense", 0);

#
#   reload settings after change
#
sub reload_settings {
	$token = Irssi::settings_get_str('mercurius_token');
	$enabled = Irssi::settings_get_bool('mercurius_enabled');
	$host = Irssi::settings_get_str('mercurius_host');
	$intense = Irssi::settings_get_int('mercurius_intense');
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
	Irssi::settings_set_str('mercurius_token', $token);
	Irssi::settings_set_bool('mercurius_enabled', 1);
	Irssi::signal_emit('setup changed');
	my $response = notify('Registered to receive notifications');
	if ($response->{success}) {
		print 'Mercurius token set. Use /SAVE command to make it permanent.';
	} else {
		# if 404 token is invalid
		print 'Mercurius token is INVALID.';
	}
}

#
#	set intensity
#	0 - notify about only first message from active window
#	1 - notify about every message
#
sub set_intense {
	my ($value) = @_;
	Irssi::settings_set_int('mercurius_intense', $value);
	Irssi::signal_emit('setup changed');
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
	} else {
		print 'Mercurius is already enabled';
	}
}

#
#	resets the $priv_notified every time window is changed
#
sub reset_counter {
	$priv_notified = 0;
}

#
#	catch private messages
#
sub priv_msg {
	if ($enabled) {
		my ($server, $msg, $nick, $address) = @_;
		my @winitems = Irssi::active_win()->items();
		my $win = @winitems[0];
		# check if current window is the private message 
		my $in_active_private = ($win->{type} eq 'QUERY' and $win->{name} eq $nick)? 1 : 0; 
		# if so show only the first message depending on intense setting
		if ($in_active_private and not $intense and $priv_notified) {
			return;
		}
		$priv_notified = 1;
		notify($nick . ': ' . $msg);
	}
}

#
#	catch 'hilight's
#
sub hilight {
	if ($enabled) {
		my ($dest, $text, $stripped) = @_;
		if ($dest->{level} & MSGLEVEL_HILIGHT) {
			notify($dest->{target} . ' ' . $stripped);
		}
	}
}

#
#	send notification
#
sub notify {
	if ($enabled) {
		my ($text) = @_;
		my $url = $host . '/notify';
		my $http = HTTP::Tiny->new();
		my $data = encode_json {
			"token" => $token,
			"client" => "IRSSI",
		    "payload" => {
				"title" => "IRSSI", 
				"body" => $text
			}
		};
		print "DEBUG: " . $url . "\n" . $data;
		my $response = $http->request('POST', $url, {
				content => $data,
				headers => {"Content-Type" => "application/json"}
			}
		);
		if (not $response->{success}) {
			print 'Mercurius notify failed. Status: ' . $response->{status};
		}
		return $response;
	}
}

#
#	manage commands
#	/mercurius command attribute list
#
my $commands="set_token set_host start stop set_intense";
sub command {
	my ($argument_string, $server, $window) = @_;
	my ($command_name, @arguments) = split(' ', $argument_string);
	if (not $command_name or index($commands, $command_name) == -1) {
		print 'Mercurius ERROR: No such method: "' . $command_name . '"';
		return;
	}
	my $command = \&$command_name;
	&$command(@arguments, $server, $window);
}

reload_settings();

#
#	irssi signals
#
Irssi::signal_add_last("message private", "priv_msg");
Irssi::signal_add_last("print text", "hilight");
Irssi::signal_add('setup changed', "reload_settings");
Irssi::signal_add('window changed', "reset_counter");

#
#	bind main command
#
Irssi::command_bind('mercurius', 'command');
