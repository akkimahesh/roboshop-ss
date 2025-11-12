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

dnf install python36 gcc python3-devel -y
VALIDATE $? "Installing Python3 and dependencies"

useradd roboshop
VALIDATE $? "Creating roboshop user"

mkdir /app 
VALIDATE $? "Creating /app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment application code"

cd /app 
VALIDATE $? "Changing to /app directory"

unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Extracting payment application code"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing payment application dependencies"



