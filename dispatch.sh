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

dnf install golang -y &>> $LOGFILE
VALIDATE $? "Installing Golang"

useradd roboshop
VALIDATE $? "Creating roboshop user"

mkdir /app 
VALIDATE $? "Creating /app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip
cd /app 
unzip /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "Extracting dispatch application code"

cd /app 
go mod init dispatch
go get 
go build &>> $LOGFILE
VALIDATE $? "Building dispatch application code"

cp /home/roboshop/dispatch/systemd.service /etc/systemd/system/dispatch.service
VALIDATE $? "Copying dispatch.service to systemd directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable dispatch 
VALIDATE $? "Enabling dispatch service"

systemctl start dispatch
VALIDATE $? "Starting dispatch service"


