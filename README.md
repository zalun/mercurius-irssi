# IRSSI client of mercurius server

Sends notifications to Mercurius [1] server when mentioned in channel.

[1] https://github.com/marco-c/mercurius

## Install

* Copy `mercurius.pl` into `~/.irssi/scripts`
* Link the script to make it run on start `ln -fs ~/.irssi/script/mercurius.pl ~/.irssi/scripts/autorun/mercurius.pl`
* Run Irssi (or, if already running `/script load mercurius`
* Open Mercurius site and get the token
* In Irssi run a command `/mercurius set_token TOKEN` (a notification should appear)


## Usage

### /mercurius set_token SOMETOKEN
sends a notification *Mercurius token set. Use /SAVE command to make it permanent.*
if response status == 200 sets a `mercurius_token` variable in IRSSI and `mercurius_enabled` which enables notification sending
else prints that there was an error

### /mercurius set_host SOMEHOST
sets the `mercurius_host` to SOMEHOST. No trailing slash is allowed.

### /mercurius stop
sets `mercurius_enabled` to false

### /mercurius start
sets `mercurius_enabled` to true

### /mercurius set_intense 0/1
switches the intense mode (default 0)
With intense mode on all of the notifications are sent.
Otherwise (default) if user is in active private window only the first message from that window will send a notification.

### on mention or private message
sends a notification to the mercurius server if `mercurius_enabled` is true
