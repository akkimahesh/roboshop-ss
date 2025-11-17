#!/bin/bash
# USE Amazon Linux 2 AMI

ID=$(id -u)

TIMESTAMP=$(date +%F-%H%M)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

if [ "$ID" -ne 0 ]
then
    echo "Please run as root"
    exit 1
else
    echo "Running as root"
fi

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo "ERROR:: $2  failed"
        exit 1
    else
        echo "SUCCESS:: $2 success"
    fi  
}

dnf update -y &>> $LOGFILE
VALIDATE $? "Updating dnf repos"

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Nginx Service"

systemctl start nginx &>> $LOGFILE  
VALIDATE $? "Starting Nginx Service"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing default Nginx content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "Downloading web application code"

cd /usr/share/nginx/html
VALIDATE $? "Changing to Nginx html directory"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "Extracting web application code"

cp /root/roboshop-ss/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "Copying roboshop.conf to Nginx directory"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting Nginx Service"