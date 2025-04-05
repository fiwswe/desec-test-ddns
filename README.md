# desec-test-ddns
Test the [deSEC e.V.](https://desec.io) dynDNS [IP Update API](https://desec.readthedocs.io/en/latest/dyndns/update-api.html) with detailed logs

This script was written for [OpenBSD 7.6](https://openbsd.org/76.html). It uses curl(1) to call the deSEC [IP Update API](https://desec.readthedocs.io/en/latest/dyndns/update-api.html) and keeps a detailed log of the results. On other platforms some changes might be required.

**IMPORTANT:** This should only be used sparingly as it consumes resources at [deSEC e.V.](https://desec.io) without any benefit other than producing the log.

## What this script does
Each time this script is run it attempts to use the deSEC [IP Update API](https://desec.readthedocs.io/en/latest/dyndns/update-api.html) to set the `A` and `AAAA` records of the configured host to randomly varying fake (example) IPs. A detailed log is produced. It will contain details regarding name resolution, TLS and HTTP headers, as well as the HTTP response.

To keep things simple the log file will use the same basename and path as the script.

After the update attempt the script sleeps for an adjustable time (default 70 seconds) and then attempts to query the deSEC NS for the current values of the `A` and `AAAA` records. The result is also writen to the log.

## Setup
* Make sure curl(1) is installed from ports: `pkg_add curl`
* Before running the script adjust the `DDNS_HOST` and `DESEC_TOKEN` values to match your domain and deSEC account.
* Depending on what you want to test, leave exactly one of the lines containing the curl(1) command uncommented. You can choose between IPv4/IPv6 and HTTP/1.1 and HTTP/2 in any combination.
* Since the script contains secrets it is advisable to protect access to its source code. `chmod 700 desec-test-ddns.sh` might be what you want.
* The log will also contain secrets. So protecting it as follows may be indicated as well: `touch desec-test-ddns.log;chmod 600 desec-test-ddns.log`


## Running the script
Either run the script manually (without any parameters) or use e.g. cron(1) to run it at regular intervals. Don't forget to disable this later when the test is done.

For example, runing the script every 5 minutes would require a crontab(5) entry similar to this (adjust the path to match your setup):

`*/5	*	*	*	*	/home/username/test/desec/desec-test-ddns.sh >/dev/null`
