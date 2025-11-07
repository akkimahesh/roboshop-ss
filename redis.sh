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

apt update -y &>> $LOGFILE
VALIDATE $? "Updating apt repos"

apt install redis-server -y &>> $LOGFILE
VALIDATE $? "Installing Redis Server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Configuring Redis to listen on all interfaces"

systemctl restart redis
VALIDATE $? "Restarting Redis Service"