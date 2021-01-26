#!/bin/bash
#
# Copyright 2020-2020 Chaminda Aruna Bandara J. M
#
# -------------------------------------------------------------------------------------------------
# Backing up Web Server - Ubuntu 20.04.1 LTS
# -------------------------------------------------------------------------------------------------
# Revision Date:	25.01.2021
# Version:			0.03
#
## Prerequisites
# -Nothing
#
### BEGIN SCRIPT INFO
echo
clear
echo
echo "---------------------------------------------------------------------------------------------"
echo "			  Backing up Web Server - Ubuntu 20.04.1 LTS								       "
echo "---------------------------------------------------------------------------------------------"
echo
echo -e "You are going to Backing up Web Server !!!"
echo
#
# Define variables
project="assignment"
taskName="backing-up-$project"

logFileName="$taskName.log"
logFile="/tmp/$logFileName"

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)

backupFile=$dateTime.tar.bz2
backupPath="/backup/$dateTime"
backup="/backup/$backupFile"

contentPath="/var/www/html"
configPath="/etc/nginx/nginx.conf"
logPath="/var/log/nginx"

touch $LogFile
echo "BEGIN SCRIPT INFO" >> $LogFile
echo
echo "Date:	$DATE" >> $LogFile
echo "User:	$USERS" >> $LogFile

# FUNCTIONS #######################################################################################

collect_content()
{
cp -r $logPath $backupPath
cp $configPath $backupPath
}

collect_logs()
{
cp -r $errorLog $backupLog
}

compress_files()
{
echo
echo "### Compressing all files... ============================================================= ###"
echo
tar -cvjf $backup /backup/$backupPath
}
# END OF FUNCTIONS ################################################################################


if [ ! -d $backupPath ] ; then
		sudo mkdir -p $backupPath
fi

echo
echo "### Creating backing up directories ===================================================== ###"
echo

collect_content

collect_logs

compress_files

sleep 1
echo "### Backup is successfully completed ... ================================================ ###"
echo

