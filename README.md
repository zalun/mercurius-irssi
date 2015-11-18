# IRSSI client of mercurius server

Sends notifications to Mercurius [1] server when mentioned in channel.

[1] https://github.com/marco-c/mercurius

## Usage

### /mercurius set_token SOMETOKEN
sends a notification "signed up for notifications in IRSSI"
if response status == 200 sets a MERCURIUS_TOKEN variable in IRSSI and MERCURIUS_ENABLED which enables notification sending
else prints that there was an error

### /mercurius set_host SOMEHOST
sets the Mercurius host to SOMEHOST

### /mercurius stop
sets MERCURIUS_ENABLED to false

### /mercurius start
sets MERCURIUS_ENABLED to true

### on mention or private message
sends a notification to the mercurius server if MERCURIUS_ENABLED is true
