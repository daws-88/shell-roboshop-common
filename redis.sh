#!/bin/bash
source ./common.sh

###### REDIS #####
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disable redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable redis 7"
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Install redis"
sed -i -e 's/127.0.0.1/0.0.0.0./g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Aloowing remote connections"

systemctl enable redis &>>$LOG_FILE
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Strat redis"
print_time
