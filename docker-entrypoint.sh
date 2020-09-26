#!/bin/sh
# vim: set noet :

set -eu

##############################################################################
# Default Variables
##############################################################################

if [ -z "${TZ:-}" ]; then
	TZ="UTC"
fi

if [ -z "${ABUILDER_UID:-}" ]; then
	ABUILDER_UID=1000
fi
if [ -z "${ABUILDER_GID:-}" ]; then
	ABUILDER_GID=1000
fi

##############################################################################
# Check Variables
##############################################################################

if echo "${ABUILDER_UID}" | grep -Eqsv '^[0-9]+$'; then
	echo "ABUILDER_UID: '${ABUILDER_UID}'"
	echo 'Please numric value: ABUILDER_UID'
	exit 1
fi
if [ "${ABUILDER_UID}" -le 0 ]; then
	echo "ABUILDER_UID: '${ABUILDER_UID}'"
	echo 'Please 0 or more: ABUILDER_UID'
	exit 1
fi
if [ "${ABUILDER_UID}" -ge 60000 ]; then
	echo "ABUILDER_UID: '${ABUILDER_UID}'"
	echo 'Please 60000 or less: ABUILDER_UID'
	exit 1
fi

if echo "${ABUILDER_GID}" | grep -Eqsv '^[0-9]+$'; then
	echo "ABUILDER_GID: '${ABUILDER_GID}'"
	echo 'Please numric value: ABUILDER_GID'
	exit 1
fi
if [ "${ABUILDER_GID}" -le 0 ]; then
	echo "ABUILDER_GID: '${ABUILDER_GID}'"
	echo 'Please 0 or more: ABUILDER_GID'
	exit 1
fi
if [ "${ABUILDER_GID}" -ge 60000 ]; then
	echo "ABUILDER_GID: '${ABUILDER_GID}'"
	echo 'Please 60000 or less: ABUILDER_GID'
	exit 1
fi

if [ ! -f "/usr/share/zoneinfo/${TZ}" ]; then
	echo "TZ: '${TZ}'"
	echo 'Not Found Timezone: TZ'
	exit 1
fi

##############################################################################
# Set Timezone
##############################################################################

ln -fs "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
echo "${TZ}" > "/etc/timezone"

##############################################################################
# Clear User/Group
##############################################################################

if getent passwd | awk -F ':' -- '{print $1}' | grep -Eqs '^abuilder$'; then
	deluser 'abuilder'
fi
if getent passwd | awk -F ':' -- '{print $3}' | grep -Eqs "^${ABUILDER_UID}$"; then
	deluser "${ABUILDER_UID}"
fi
if getent group | awk -F ':' -- '{print $1}' | grep -Eqs '^abuilder$'; then
	delgroup 'abuilder'
fi
if getent group | awk -F ':' -- '{print $3}' | grep -Eqs "^${ABUILDER_GID}$"; then
	delgroup "${ABUILDER_GID}"
fi

##############################################################################
# Reset Group
##############################################################################

addgroup -g "${ABUILDER_GID}" 'abuilder'

##############################################################################
# Reset User
##############################################################################

adduser -h '/home/abuilder' \
	-g 'abuilder,,,' \
	-s '/usr/sbin/nologin' \
	-G 'abuilder' \
	-D \
	-H \
	-u "${ABUILDER_UID}" \
	'abuilder'

addgroup 'abuilder' 'abuild'

##############################################################################
# Initialization
##############################################################################

echo '%abuilder ALL=(ALL:ALL) NOPASSWD: ALL' > '/etc/sudoers.d/abuilder'

if [ ! -d '/abuild' ]; then
	mkdir -p '/abuild'
	chown -R 'abuilder:abuilder' '/abuild'
fi

if [ ! -d '/home/abuilder' ]; then
	mkdir -p '/home/abuilder'
	ln -s '/abuild' '/home/abuilder/.abuild'
	chown -R 'abuilder:abuilder' '/home/abuilder'
fi

##############################################################################
# Running
##############################################################################

if [ "$1" = 'abuild' ]; then
	apk update
	cd '/home/abuilder'
	exec su-exec 'abuilder:abuilder' "$@"
else
	exec "$@"
fi
