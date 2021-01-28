#!/bin/bash -e
#
# Copyright 2014-2018 Chaminda Aruna Bandara J. M
#
# ----------------------------------------------------------------------------
# Script for Monitor Web Server on Ubuntu 20.04.1 LTS
# ----------------------------------------------------------------------------
# Revision Date:	20.01.2021
# Version:			0.4
#
## Prerequisites
# - Makesure internet availability
# - Execute with root privileges
### BEGIN SCRIPT INFO
#
# Define variables
logDate="Date: $(date)"
logUser="User: $(users)"

taskName=""
package='nginx'

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)

workingDir=$(pwd .)
websiteDomain=""
websiteIP="51.15.146.27"
email="jmcabandara@gmail.com"	# Send mail in case of failure to.
tmpDir=$workingDir/cache	# Temporary dir

################################################################
CHECK_WEB_SERVER=0

LOGS=/tmp/monlogs

if [ ! -d $LOGS ]; then
	mkdir $LOGS
fi

LOG=$LOGS/default.log

# FUNCTIONS #######################################################################################

##########################
#Logs and runs a command
##########################
log_run()
{
	COMMAND=$1
	echo $COMMAND >> $LOG
	$COMMAND 1>> $LOG 2>&1
}

##########################
#Echoes and logs a message
##########################
log_echo()
{
	echo $1
	echo $1 >> $LOG
}

check_web_server()
{
LOG=$LOGS/check_web_server.log
log_echo "### Checking the web server status... =============================================== ###"
echo
if [ $(systemctl is-active $package) = active ]
	then
		echo
		log_echo "### Nginx already runing... ===================================================== ###"
		echo
		#sudo ps -aux | grep $package
		echo
		#sudo netstat -ntlap | grep $package
		echo
		sudo systemctl status $package
		echo
		exit 1
	else
		log_echo "### Nginx is dead... ============================================================ ###"
		echo
		sudo systemctl enable $package
		echo
		sudo systemctl start $package
		echo
			if [ $(systemctl is-active $package) = active ]
			then
				log_echo "### Nginx is started... ================================================= ###"
			fi
		echo
		sudo systemctl status $package
		echo
		#sudo ps -aux | grep $package
		echo
		#sudo netstat -ntlap | grep $package
	fi
	echo
}

monitor_website()
{
  response=$(curl -L --write-out %{http_code} --silent --output /dev/null $1)
  filename=$( echo $1 | cut -f1 -d"/" )
	if [ "$QUIET" = false ] ; then 
		echo -n "$p "
	fi

	if [ $response -eq 200 ] ; then
		# website working
		if [ "$QUIET" = false ] ; then
			echo -n "$response "
			echo -e "\e[32m[ok]\e[0m"
		fi
		# remove .temp file if exist 
		if [ -f $tmpDir/$filename ]; then 
			rm -f $tmpDir/$filename
		fi
	else
	# website down
	if [ "$QUIET" = false ] ; then 
		echo -n "$response "
		echo -e "\e[31m[DOWN]\e[0m"
	fi
	if [ ! -f $tmpDir/$filename ]; then
			send_email
			fi
	fi
}

send_email()
{
while read e; do
	# using mailx command
	echo "$p WEBSITE DOWN" | mailx -s "$1 WEBSITE DOWN ( $response )" $e
	# using mail command
	#mail -s "$p WEBSITE DOWN" "$EMAIL"
done < $email

echo > $tmpDir/$filename
}

# END OF FUNCTIONS ################################################################################
echo
log_echo "### BEGIN SCRIPT ======================================================================== ###"
echo
if [ "$CHECK_WEB_SERVER" = "0" ]; then
	check_web_server
fi
echo
monitor_website $p 2
echo
log_echo "### You may find the logs at: $LOGS ..................................................... ###"
echo
