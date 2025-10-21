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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue application code"

cd /app
VALIDATE $? "Changing to /app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Extracting catalogue application code"

npm install &>> $LOGFILE
VALIDATE $? "Installing catalogue application dependencies"

cp /root/roboshop-ss/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue.service to systemd directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue service"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue service"

cp /root/roboshop-ss/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Creating mongo.repo file"

yum install -y mongodb-org &>> $LOGFILE
VALIDATE $? "Installing MongoDB"

mongosh --host mongodb.maheshakki.shop < /app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue schema to MongoDB"

systemctl restart catalogue
VALIDATE $? "Restarting catalogue service"