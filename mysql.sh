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

yum update -y
VALIDATE $? "Updating yum repos"

yum remove -y mariadb-libs
VALIDATE $? "Removing mariadb-libs"

rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
VALIDATE $? "Adding MySQL repository"

rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
VALIDATE $? "Importing MySQL GPG key"

yum install -y mysql-community-server
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling MySQL Service"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL Service"

grep 'temporary password' /var/log/mysqld.log
VALIDATE $? "Fetching temporary MySQL root password"

mysql_secure_installation --set-root-pass RoboShop@1 
VALIDATE $? "Setting MySQL root password"

mysql -uroot -pRoboShop@1 -e "show databases;" &>> $LOGFILE
VALIDATE $? "Validating MySQL root login"