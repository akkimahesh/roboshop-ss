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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Adding Erlang Repository"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Adding RabbitMQ Repository"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "Enabling RabbitMQ Service"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "Starting RabbitMQ Service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "Adding RabbitMQ User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "Setting Permissions for RabbitMQ User"
