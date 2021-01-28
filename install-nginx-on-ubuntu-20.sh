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
### BEGIN SCRIPT
clear
# Define variables
logDate="Date: $(date)"
logUser="User: $(users)"

taskName='install-Nginx'
package='nginx'

logFileName="$taskName.log"
logFile="/tmp/$logFileName"

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)

################################################################
install_nginx=0

LOGS=/tmp/instnginxlogs
LOG=$LOGS/default.log

if [ ! -d $LOGS ]; then
	mkdir $LOGS
else
	rm -rf $LOGS/*.*
fi

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

install_nginx()
{
LOG=$LOGS/install_nginx.log
echo "$logUser" >> $LOG
	# Install Nginx
	log_echo ""
	log_echo "### Check if the Nginx already installed... ============================================ ###"
	log_echo ""
	sleep 1
	
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $package|grep "already installed")
	log_echo ""
	if [ "" = "$PKG_OK" ]
	then
		sudo apt-get update 1>> $LOG 2>&1
		log_echo ""
		log_echo "No $package. Setting up $package."
		log_echo ""
		sudo apt-get --yes install $package 1>> $LOG 2>&1
		log_echo ""
	else
		log_echo ""
		log_echo "### $package: $PKG_OK... ======================================================== ###"
		log_echo ""
	fi

	# Finally, Start Nginx
	log_echo ""
	log_echo "### Check if the Nginx status... ==================================================== ###"
	log_echo ""
	if [ $(systemctl is-active nginx) = active ]
	then
		log_echo ""
		log_echo "### Nginx already runing... ===================================================== ###"
		log_echo ""
		#sudo ps -aux | grep $package
		log_echo ""
		#sudo netstat -ntlap | grep $package
		log_echo ""
		sudo systemctl status $package  1>> $LOG 2>&1
		log_echo ""
		log_echo "### Exit the installer... ======================================================= ###"
		exit 1
	else
		sudo systemctl enable $package  1>> $LOG 2>&1
		log_echo ""
		sudo systemctl start $package  1>> $LOG 2>&1
		log_echo ""
		sudo systemctl status $package
		log_echo ""
		sudo ps -aux | grep $package
		log_echo ""
		sudo netstat -ntlap | grep $package
	fi

	log_echo ""
	log_echo "### Installing Nginx is completed... ================================================ ###"
	log_echo ""
}

# END OF FUNCTIONS ################################################################################

echo
echo "---------------------------------------------------------------------------------------------"
echo "					Install Nginx on Ubuntu 20.04.1 LTS										   "
echo "---------------------------------------------------------------------------------------------"
echo
echo -e "You are going to install Nginx Server !!!"
echo
echo -e "Make sure you have internet connection to install package. If don't, please setup it."
echo
echo
echo -e "Press key enter"
read presskey
log_echo ""
# Get user feedback to continue
echo "Do you want to continue ? (y/n)"
read -e answer

# Check the user feedback and execute the dicition accordingly
if [ "$answer" == n ] ; then
	exit
else
	if [ "$INSTALL_NGINX" = "0" ]; then
		install_nginx
	fi
fi
