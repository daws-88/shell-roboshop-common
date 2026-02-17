#!/bin/bash
souce ./common.sh

check_root
###### MYSQL ####
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Install mysql"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enable mysql"
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "start mysql"
mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting up root password"
print_time
