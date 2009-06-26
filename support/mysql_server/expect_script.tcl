set timeout -1
spawn aptitude -y install mysql-server
expect "user:$"
send "scimitar1"
expect "user:$"
send "scimitar1"