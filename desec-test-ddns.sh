#!/bin/sh
#
# Copyright (c)2025 by fiwswe
# Permission granted to freely use for any purpose without any warranties.
# License: MIT (https://opensource.org/license/mit)
#
# Written for and tested on OpenBSD 7.6.
#
# Example crontab(5) entry for running this script every 5 minutes:
# */5	*	*	*	*	/home/username/test/desec/desec-test-ddns.sh >/dev/null
#
#
# Test script to update a DDNS hostname at deSEC e.V. with changing IPs.
# The object is to watch for HTTP errors and log all relevant data.
#
# WARNING: The log file will contain private secrets such as the authorization token!
#

# Adjust the following two lines to match your domain and deSEC account:
DDNS_HOST='ddns-test.example.com'	# <= User setting, please change
DESEC_TOKEN='CHANGE_ME'				# <= User setting, please change

API_URL='https://update.dedyn.io?'
AUTH_HEADER="Authorization: Token ${DESEC_TOKEN}"
IPv4_ADDR='198.51.100.'
IPv6_ADDR='2001:db8::198:51:100:'
DELAY=70

# Note: The following paths are correct for OpenBSD 7.6. Adjust if needed for other platforms.
DATE_CMD='/bin/date'
BASENAME_CMD='/usr/bin/basename'
AWK_CMD='/usr/bin/awk'
DIG_CMD='/usr/bin/dig'
JOT_CMD='/usr/bin/jot'
CURL_CMD='/usr/local/bin/curl'	# This needs to be installed using `pkg_add curl`

# Assuming this file has a name ending in .sh the log file will have the same name with
# the extension .log:
LOGFILE="$(${BASENAME_CMD} ${0} 'sh')log"

LOOKUP_IP_CMD="${DIG_CMD} @ns1.desec.io. +short ${DDNS_HOST}"

# Choose a random number from 1 to 254 for appending as the last segment of the IP addresses:
LAST_IP_SEG="$(${JOT_CMD} -r 1 1 254)"
NEW_IPv4="${IPv4_ADDR}${LAST_IP_SEG}"
NEW_IPv6="${IPv6_ADDR}${LAST_IP_SEG}"
URL="${API_URL}hostname=${DDNS_HOST}&myipv4=${NEW_IPv4}&myipv6=${NEW_IPv6}"

cd "$(dirname $0)"	# The log file goes in the the same directory as this script.

echo "### $(${DATE_CMD} '+%F %T%z'): $(${BASENAME_CMD} $0)" >> "$LOGFILE"
echo "# URL: $URL" >> "$LOGFILE"

##
## Uncomment one of the following lines to test IPv6/IPv4 and HTTP/1.1 vs. HTTP/2:
##

# Assuming your host has IPv6 connectivity this uses IPv6 and HTTP/1.1:
#$CURL_CMD --url "$URL" --header "$AUTH_HEADER" --silent -v --http1.1 >> "$LOGFILE" 2>&1

# Assuming your host has IPv6 connectivity this uses IPv6 and HTTP/2:
$CURL_CMD --url "$URL" --header "$AUTH_HEADER" --silent -v >> "$LOGFILE" 2>&1

# Assuming your host has IPv4 connectivity this uses IPv4 and HTTP/1.1:
#$CURL_CMD --url "$URL" --header "$AUTH_HEADER" --silent -v --http1.1 --ipv4 >> "$LOGFILE" 2>&1

# Assuming your host has IPv4 connectivity this uses IPv4 and HTTP/2:
#$CURL_CMD --url "$URL" --header "$AUTH_HEADER" --silent -v --ipv4 >> "$LOGFILE" 2>&1

##

RES="$?"
echo "\n" >> "$LOGFILE"
echo "## Result: ${RES}" >> "$LOGFILE"
if [ $RES -eq 0 ];then
	sleep $DELAY	# Wait for propagation of the changes before checking the values.
	echo "## ${DELAY} seconds later…" >> "$LOGFILE"
	echo "## IPv4: $(${LOOKUP_IP_CMD} a)" >> "$LOGFILE"
	echo "## IPv6: $(${LOOKUP_IP_CMD} aaaa)" >> "$LOGFILE"
fi
echo "### Done.\n" >> "$LOGFILE"


# Local Variables:
# tab-width: 4
# End:

#
#	EOF.
#
