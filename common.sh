
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.daws88s.fun
MYSQL_HOST=mysql.daws88s.fun
SCRIPT_DIR=$PWD
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOG_FOLDER
echo "Script strated at $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: Please run this script as root privelliage"
        exit 1
    fi
}

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ....$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2....$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

nodejs_setup() {
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disable nodejs"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enable nodejs 20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "install nodejs"
}

java_setup() {
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Install python"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Package into a .jar"
    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moved to shipping.jar"
}

python_setup() {
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing python"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Install dependencies"
}

app_setup() {
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "add user"
    else
        echo -e "User already exist...$Y SKIPPING $N"| tee -a $LOG_FILE
    fi
    mkdir -p /app
    VALIDATE $? "create /app"
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "download code"
    cd /app
    VALIDATE $? "move to /app"
    rm -rf /app/* $>>$LOG_FILE
    VALIDATE $? "remove old code"
    unzip /tmp/$app_name.zip &>>LOG_FILE
    VALIDATE $? "unzip the code"
}

system_setup() { 
cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
VALIDATE $? "created systemctl service"
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reload files"
systemctl enable $app_name &>>LOG_FILE
VALIDATE $? "enable catalogue"
}



app_restart() {
    ystemctl restart $app_name
    VALIDATE $? "restart $app_name"
}

print_time() {
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}