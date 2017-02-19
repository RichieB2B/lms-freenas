#!/bin/sh

# This script is a modified version of:
# $FreeBSD: branches/RELENG_9_2_0/audio/squeezeboxserver/files/squeezeboxserver.in 302141 2012-08-05 23:19:36Z dougb $

# PROVIDE: lms
# REQUIRE: LOGIN
# KEYWORD: shutdown

# Add the following lines to /etc/rc.conf to enable lms on startup:
# lms_enable="YES"

# Optional configuration parameters:
# Directory where lms writes it's logs to.
# lms_logdir="/var/log/lms"
#
# Directory where lms stores it's cache files.
# lms_cachedir="/var/db/lms/cache"
#
# Directory where lms stores it's configuration.
# lms_prefsdir="/var/db/lms/prefs"
#
# Directory where lms stores the playlists. THIS NEEDS TO BE CONFIGURED THROUGH THE UI.
# lms_playlistdir="/var/db/lms/playlists"
#
# Additional parameters, e.g. "--noimage --novideo"
# lms_flags=""
#
# The charset lms uses.
# lms_charset="UTF-8"
#
# The LC_CTYPE envvar which is necessary to get rid of the warning
# """
# Your locale was detected as C, you may have problems with non-Latin filenames.
# Consider changing your LANG variable to the correct locale, i.e. en_US.utf8.
# """
# See https://forums.freenas.org/index.php?threads/logitech-media-server-for-freenas-9-2-1-1.19044/page-3#post-132872 
# lms_lc_ctype="en_US.UTF.8"

. /etc/rc.subr

name=lms
rcvar=lms_enable

pidfile=/var/run/${name}/${name}.pid
lms_user=lms
lms_group=lms

load_rc_config ${name}

: ${lms_enable="NO"}
: ${lms_logdir="/var/log/${name}"}
: ${lms_cachedir="/var/db/${name}/cache"}
: ${lms_prefsdir="/var/db/${name}/prefs"}
: ${lms_playlistdir="/var/db/${name}/playlists"}
: ${lms_flags=""}
: ${lms_charset="UTF-8"}
: ${lms_lc_ctype="en_US.UTF-8"}

command_interpreter=/usr/bin/perl
command=/usr/local/lms/slimserver.pl
command_args="\
--daemon \
--pidfile=${pidfile} \
--logdir=${lms_logdir} \
--cachedir=${lms_cachedir} \
--prefsdir=${lms_prefsdir} \
--charset=${lms_charset} \
${lms_flags}"

start_precmd="lms_start_precmd"
stop_postcmd="lms_stop_postcmd"

lms_start_precmd()
{
	export LC_CTYPE="${lms_lc_ctype}"

	if [ ! -d "${pidfile%/*}" ]; then	
		install -d -o ${lms_user} -g ${lms_group} ${pidfile%/*};
	fi

	if [ ! -d "${lms_logdir}" ]; then
		install -d -o ${lms_user} -g ${lms_group} "${lms_logdir}";
	fi

	if [ ! -d "${lms_cachedir}" ]; then
		install -d -o ${lms_user} -g ${lms_group} "${lms_cachedir}";
	fi

	if [ ! -d "${lms_prefsdir}" ]; then
		install -d -o ${lms_user} -g ${lms_group} "${lms_prefsdir}";
	fi

	if [ ! -d "${lms_playlistdir}" ]; then
		install -d -o ${lms_user} -g ${lms_group} "${lms_playlistdir}";
	fi
}

lms_stop_postcmd()
{
	pids=`pgrep -u ${lms_user}`
	if [ -n "${pids}" ]; then
		sleep 1
		kill $pids > /dev/null 2>&1
	fi
	pids=`pgrep -u ${lms_user}`
	if [ -n "${pids}" ]; then
		wait_for_pids $pids
	fi
}

run_rc_command "$1"

