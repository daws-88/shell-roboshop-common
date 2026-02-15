#!/bin/bash
souce ./common.sh
check_root

### RABBITMQ #####
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copying mongo.repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Install rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enable rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Strat rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting up permessions"

print_time