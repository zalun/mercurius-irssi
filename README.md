# IRSSI client of mercurius server

Sends notifications to Mercurius [1] server when mentioned in channel.

[1] https://github.com/marco-c/mercurius

## Usage

### /mercurius set_token SOMETOKEN
sends a notification "signed up for notifications in IRSSI"
if response status == 200 sets a *mercurius_token* variable in IRSSI and *mercurius_enabled* which enables notification sending
else prints that there was an error

### /mercurius set_host SOMEHOST
sets the *mercurius_host* to SOMEHOST

### /mercurius stop
sets *mercurius_enabled* to false

### /mercurius start
sets *mercurius_enabled* to true

### on mention or private message
sends a notification to the mercurius server if *mercurius_enabled* is true
