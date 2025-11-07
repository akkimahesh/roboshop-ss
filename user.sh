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

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash &>> $LOGFILE
VALIDATE $? "Installing NVM (Node Version Manager)"

source ~/.bashrc &>> $LOGFILE
VALIDATE $? "Sourcing .bashrc"

nvm install 18 &>> $LOGFILE
VALIDATE $? "Installing Node.js version 18"

nvm alias default 18
VALIDATE $? "Setting default Node.js version to 18"

node -v
npm -v

useradd roboshop 
VALIDATE $? "Creating roboshop user"

mkdir -p /app 
VALIDATE $? "Creating /app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user application code"

cd /app
VALIDATE $? "Changing to /app directory"

unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Extracting user application code"

npm install &>> $LOGFILE
VALIDATE $? "Installing user application dependencies"

cp /root/roboshop-ss/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user.service to systemd directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user service"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user service"

cp /root/roboshop-ss/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Creating mongo.repo file"

yum install -y mongodb-org &>> $LOGFILE
VALIDATE $? "Installing MongoDB"

mongosh --host mongodb.maheshakki.shop </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading user schema to MongoDB"

systemctl restart user
VALIDATE $? "Restarting user service"
