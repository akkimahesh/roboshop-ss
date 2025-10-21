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