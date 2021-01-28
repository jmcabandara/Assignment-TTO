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
# Define variables for log module

logFileName="monitor-web-server.log"
logFile="/tmp/$logFileName"

echo
echo "### BEGIN SCRIPT ======================================================================== ###" >> $logFile
echo
# Define variables
taskName=""
package='nginx'

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)

workingDir=$(pwd .)
websiteDomain=""
websiteIP="51.15.146.27"
email="jmcabandara@gmail.com"	# Send mail in case of failure to.
tmpDir=$workingDir/cache	# Temporary dir

# FUNCTIONS #######################################################################################

check_web_server()
{
	echo "### Checking the web server status... =============================================== ###"
	echo
	if [ $(systemctl is-active $package) = active ]
	then
		echo
		echo "### Nginx already runing... ===================================================== ###"
		echo
		#sudo ps -aux | grep $package
		echo
		#sudo netstat -ntlap | grep $package
		echo
		sudo systemctl status $package
		echo
		exit 1
	else
		echo "### Nginx is dead... ============================================================ ###"
		echo
		sudo systemctl enable $package
		echo
		sudo systemctl start $package
		echo
			if [ $(systemctl is-active $package) = active ]
			then
				echo "### Nginx is started... ================================================= ###"
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

touch $logFile
echo "BEGIN SCRIPT INFO" >> $logFile
echo
echo -e "Date: $(date)" >> $logFile
echo -e "User: $(users)" >> $logFile
echo -e "" >> $logFile
echo


check_web_server 2 >> $logFile

	if [ $? -neq 0 ]
	then

	echo "Can't create a folder"
		
	exit
		
	fi

monitor_website $p 2

