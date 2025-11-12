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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

useradd roboshop 
VALIDATE $? "Creating roboshop user"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping application code"

mkdir -p /app
VALIDATE $? "Creating /app directory"

cd /app
VALIDATE $? "Changing to /app directory"

unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Extracting shipping application code"

mvn clean package &>> $LOGFILE
VALIDATE $? "Building shipping application code"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Moving shipping jar file"

cp /root/roboshop-ss/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying shipping.service to systemd directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping service"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping service"

dnf install mysql -y
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.maheshakki.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loading shipping schema to MySQL database"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping service"
