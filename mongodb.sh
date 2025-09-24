#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shellscript"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) #current script name=mongodb.sh
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/roboshop-shellscript/mongodb.log

mkdir -p $LOGS_FOLDER 
echo "script started executed at: $(date)" | tee -a $LOG_FILE # tee is a splitter for output, it saves the input in file

if [ $USERID -ne 0 ]; then
    echo "run script with root access"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e "$2....$R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
    else 
    echo -e "$2....$R SUCCESS $N" | tee -a $LOGS_FILE
}

cp mongo.repo /etc/yum/repos.d/mongo.repo
VALIDATE $? "adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connections to momgodb"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb"