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
log_echo ""
clear
log_echo ""
echo "---------------------------------------------------------------------------------------------"
echo "			  Backing up Web Server - Ubuntu 20.04.1 LTS								       "
echo "---------------------------------------------------------------------------------------------"
log_echo ""
echo -e "You are going to Backing up Web Server !!!"
log_echo ""
#
# Define variables
logDate="Date: $(date)"
logUser="User: $(user)"

project="assignment"
taskName="backing-up-$project"

dateTimeFull=$(date +%Y%m%d-%H%M%S)
dateTime=$(date +%Y%m%d-%H%M)

backupFile=$dateTime.tar.bz2
backupPath="/backup/$dateTime"
backup="/backup/$backupFile"

contentPath="/var/www/html"
configPath="/etc/nginx/nginx.conf"
logPath="/var/log/nginx"

################################################################
UPLOAD_TO_S3=0

LOGS=/tmp/bkplogs

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

collect_content()
{
cp -r $logPath $backupPath  1>> $LOG 2>&1
cp $configPath $backupPath  1>> $LOG 2>&1
}

collect_logs()
{
cp -r $errorLog $backupLog  1>> $LOG 2>&1
}

compress_files()
{
log_echo ""
echo "### Compressing all files... ============================================================= ###"
log_echo ""
tar -cvjf $backup /backup/$backupPath  1>> $LOG 2>&1
}
# END OF FUNCTIONS ################################################################################


if [ ! -d $backupPath ] ; then
		sudo mkdir -p $backupPath  1>> $LOG 2>&1
fi

log_echo ""
echo "### Creating backing up directories ===================================================== ###"
log_echo ""

collect_content

collect_logs

compress_files

sleep 1
echo "### Backup is successfully completed ... ================================================ ###"
###################################################################################################
log_echo ""
echo "---------------------------------------------------------------------------------------------"
echo "				Upload Backup - Ubuntu 20.04.1 LTS											   "
echo "---------------------------------------------------------------------------------------------"
log_echo ""
echo -e "You are going to Upload Backup to s3 Busket !!!"
log_echo ""

backupFile=$dateTime.tar.bz2
backupPath="/backup/$dateTime"
backup="/backup/$backupFile"

s3Bucket="s3:us-east-2:655308211718:accesspoint/nginx-web-server-backup"

# FUNCTIONS #######################################################################################

upload_to_s3()
{
if [ $? -ne 0 ] ; then
else
	s3cmd put -r $backup $s3Bucket/  1>> $LOG 2>&1
	rm -rf $backup  1>> $LOG 2>&1
fi
}

# END OF FUNCTIONS ################################################################################

log_echo ""
log_echo "### BEGIN SCRIPT ======================================================================== ###"
log_echo ""
if [ "$UPLOAD_TO_S3" = "0" ]; then
	upload_to_s3
fi
log_echo ""
log_echo "### You may find the logs at: $LOGS ..................................................... ###"
log_echo ""
