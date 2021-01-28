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
#
# Define variables
logDate="Date: $(date)"
logUser="User: $(users)"

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
COLLECT_CONTENT=0
COLLECT_LOGS=0
COMPRESS_FILES=0

UPLOAD_TO_S3=0

LOGS=/tmp/bkplogs
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

collect_content()
{
LOG=$LOGS/collect_content.log
echo "$logUser" >> $LOG
cp -r $logPath $backupPath  1>> $LOG 2>&1
cp $configPath $backupPath  1>> $LOG 2>&1
}

collect_logs()
{
LOG=$LOGS/collect_logs.log
echo "$logUser" >> $LOG
cp -r $errorLog $backupLog  1>> $LOG 2>&1
}

compress_files()
{
LOG=$LOGS/compress_files.log
echo "$logUser" >> $LOG
log_echo ""
echo "### Compressing all files... ============================================================= ###"
log_echo ""
tar -cvjf $backup /backup/$backupPath  1>> $LOG 2>&1
}
# END OF FUNCTIONS ################################################################################

log_echo ""
clear
log_echo ""
echo "---------------------------------------------------------------------------------------------"
echo "			  Backing up Web Server - Ubuntu 20.04.1 LTS								       "
echo "---------------------------------------------------------------------------------------------"
log_echo ""
echo -e "You are going to Backing up Web Server !!!"
log_echo ""

if [ ! -d $backupPath ] ; then
		sudo mkdir -p $backupPath  1>> $LOG 2>&1
fi

log_echo ""
echo "### Creating backing up directories ===================================================== ###"
log_echo ""

if [ "$COLLECT_CONTENT" = "0" ]; then
	collect_content
fi
if [ "$COLLECT_LOGS" = "0" ]; then
	collect_logs
fi
if [ "$COMPRESS_FILES" = "0" ]; then
	compress_files
fi

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
echo "if then >"
else
	s3cmd put -r $backup $s3Bucket/  1>> $LOG 2>&1
	rm -rf $backup  1>> $LOG 2>&1
fi
}

# END OF FUNCTIONS ################################################################################

if [ "$UPLOAD_TO_S3" = "0" ]; then
	upload_to_s3
fi
log_echo ""
log_echo "### You may find the logs at: $LOGS ................................................. ###"
log_echo ""
