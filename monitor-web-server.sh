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
else
	rm -rf $LOGS/*.*
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
	echo "" >> $LOG
	echo $(date) >> $LOG
	echo $1
	echo $1 >> $LOG
}

check_web_server()
{
LOG=$LOGS/check_web_server.log
log_echo $logUser
log_echo "### Checking the web server status... =================================================== ###"
log_echo ""
if [ $(systemctl is-active $package) = active ]
	then
		log_echo ""
		log_echo "### Nginx already runing... ===================================================== ###"
		log_echo ""
		#sudo ps -aux | grep $package
		log_echo ""
		#sudo netstat -ntlap | grep $package
		log_echo ""
		sudo systemctl status $package 1>> $LOG 2>&1
		log_echo ""
	else
		log_echo "### Nginx is dead... ============================================================ ###"
		log_echo ""
		# sudo systemctl enable $package
		log_echo ""
		sudo systemctl start $package 1>> $LOG 2>&1
		log_echo ""
			if [ $(systemctl is-active $package) = active ]
			then
				log_echo "### Nginx is started... ================================================= ###"
			fi
		log_echo ""
		sudo systemctl status $package
		log_echo ""
		#sudo ps -aux | grep $package
		log_echo ""
		sudo netstat -ntlap | grep $package  1>> $LOG 2>&1
	fi
	log_echo ""
}

monitor_website()
{
QUIET="false"
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
			rm -f $tmpDir/$filename 1>> $LOG 2>&1
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

echo "" > $tmpDir/$filename
}

# END OF FUNCTIONS ################################################################################
log_echo ""
log_echo "### BEGIN SCRIPT ======================================================================== ###"
log_echo ""
if [ "$CHECK_WEB_SERVER" = "0" ]; then
	check_web_server
fi
log_echo ""
monitor_website $p 1
log_echo ""
log_echo "### You may find the logs at: $LOGS ..................................................... ###"
log_echo ""
