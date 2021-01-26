
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
clear
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
echo
sleep 1
# Script run preperation
# User input

echo "### BEGIN SCRIPT ======================================================================== ###"

# Define variables
taskName='install-Nginx'
package='nginx'

logFileName="$taskName.log"
logFile="/tmp/$logFileName"

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)

# FUNCTIONS #######################################################################################

install_nginx()
{
	# 01. If Nginx is running, collect user input before continue installing Nginx
	echo
	echo "### Check if the Nginx already installed or runing... =============================== ###"

	# 02. Update the server
	echo
	echo "==================== Update the server ===================================================";
	echo
	sleep 1;
	sudo apt-get update

	# 03. Install Nginx
	echo
	echo "### Check if the Nginx already installed... ============================================ ###"
	sleep 1
	
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $package|grep "already installed")
	
	if [ "" = "$PKG_OK" ]
	then
		echo "No $package. Setting up $package."
		sudo apt-get --yes install $package
	else
		echo "### $package: $PKG_OK... ======================================================== ###"
	fi

	# 04. Finally, Start Nginx
	echo
	echo "### Check if the Nginx already runing... ============================================ ###"
	
	if [ $(systemctl is-active sshd) = active ]
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
		echo "### Exit the installer... ======================================================= ###"
		exit 1
	else
		sudo systemctl enable $package
		echo
		sudo systemctl start $package
		echo
		sudo systemctl status $package
		echo
		#sudo ps -aux | grep $package
		echo
		#sudo netstat -ntlap | grep $package
	fi

	echo
	echo "### Installing Nginx is completed... ================================================ ###"
}


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

# END OF FUNCTIONS ################################################################################

touch $logFile
echo "BEGIN SCRIPT INFO" >> $logFile
echo
echo -e "Date:\t$(date)" >> $logFile
echo -e "User:\t$(users)" >> $logFile
echo -e "" >> $logFile
echo

# Get user feedback to continue
echo "Do you want to continue ? (y/n)"
read -e answer

# Check the user feedback and execute the dicition accordingly
if [ "$answer" == n ] ; then
exit
else
install_nginx
fi

