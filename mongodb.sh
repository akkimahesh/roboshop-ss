ID=$(id -u)

TIMESTAMP=$(date +%F-%H%M)
LOGFILE="/temp/$0-$TIMESTAMP.log"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Creating mongo.repo file"

dnf install mongodb-org -y  &>> $LOGFILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod  &>> $LOGFILE
VALIDATE $? "Enabling MongoDB Service"

systemctl start mongod  &>> $LOGFILE
VALIDATE $? "Starting MongoDB Service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Configuring MongoDB to listen on all interfaces"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB Service"
