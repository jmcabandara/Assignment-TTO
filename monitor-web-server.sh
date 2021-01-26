
#!/bin/bash -e
#
# Copyright 2014-2018 Chaminda Aruna Bandara J. M
#
# ----------------------------------------------------------------------------
# Script for Install Nginx on Ubuntu 20.04.1 LTS
# ----------------------------------------------------------------------------
# Revision Date:	20.01.2021
# Version:			0.4
#
## Prerequisites
# - Makesure internet availability
# - Execute with root privileges
### BEGIN SCRIPT INFO
echo
echo "### BEGIN SCRIPT ======================================================================== ###"
echo
# Define variables
taskName='check-web-server'
package='nginx'

logFileName="$taskName.log"
logFile="/tmp/$logFileName"

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)


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

# END OF FUNCTIONS ################################################################################

touch $logFile
echo "BEGIN SCRIPT INFO" >> $logFile
echo
echo -e "Date:	$(date)" >> $logFile
echo -e "User:	$(users)" >> $logFile
echo -e "" >> $logFile
echo

check_web_server

