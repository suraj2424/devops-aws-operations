# PART I

## SETUP ENVIRONMENT

- create ec2 instance with proper system specs
- connect to ec2 instance using ssh

```bash
ssh -i "your-key.pem" ubuntu@your-ec2-public-dns
```
- you can find above link in connect section of ec2 instance in aws console

- Now, connect to ec2 instance using ssh locally using above command.

## ADD NEW USER AND GRANT SUDO PRIVILEGES
- create new user
```bash
sudo adduser devops_intern
```
- grant sudo privileges without password
```bash
sudo visudo
```

- add below line at the end of file
```bash
devops_intern ALL=(ALL) NOPASSWD:ALL
```

- check if new user is added
```bash
cat /etc/passwd | grep devops_intern
```

## CHECK NEW USER & PRIVILEGES
- switch to new user
```bash
su - devops_intern
```
- check sudo privileges
```bash
sudo whoami
```

## UPDATE HOSTNAME
- update hostname to include your name
```bash
sudo hostnamectl set-hostname yourname-devops
```

- verify hostname
```bash
hostname
```

# PART II

## INSTALL NECESSARY PACKAGES
- update package lists
```bash
sudo apt update
```
- install nginx
```bash
sudo apt install nginx -y
```

- start nginx service
```bash
sudo systemctl start nginx
```

## INSTANCE ID AND UPTIME VARIABLES
- 
- first get token
```bash
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
```
- now fetch instance id using token
```bash
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
```

- now fetch public ipv4 address of instance using token
```bash
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4
```

- fetch uptime
```bash
UPTIME=$(uptime -p)
```

### create a html in /var/www/html/index.html
```html
<!DOCTYPE html>
<html>
<head>
    <title>DevOps NGINX Part</title>
</head>
<body>
    <p><b>Name:</b> Suraj Suryawanshi</p>
    <p><b>Instance ID:</b> $INSTANCE_ID</p>
    <p><b>Uptime:</b> $UPTIME</p>
</body>
</html>
```

## now add the content to index.html file
```bash
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>DevOps NGINX Part</title>
</head>
<body>
    <p><b>Name:</b> Suraj Suryawanshi</p>
    <p><b>Instance ID:</b> $INSTANCE_ID</p>
    <p><b>Uptime:</b> $UPTIME</p>
</body>
</html>
EOF
```
## check localhost if nginx is working
```bash
curl localhost
```
- you should see the html content in output

## now you can access the webpage using public ip of instance in browser
- http://your-ec2-public-ip


# PART III

## CREATE MONITORING SCRIPT
- create a script at /usr/local/bin/system_report.sh
```bash
sudo nano /usr/local/bin/system_report.sh
```

- The script content is as below:
```bash
#!/bin/bash

echo "----------------------------------------"
echo "System Report - $(date)"
echo "----------------------------------------"

echo "Current Date & Time: $(date)"
echo "Uptime:"
uptime -p

echo "CPU Usage (%):"
top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}'

echo "Memory Usage (%):"
free | grep Mem | awk '{print ($3/$2)*100 "%"}'

echo "Disk Usage (%):"
df -h / | awk 'NR==2 {print $5}'

echo "Top 3 CPU Consuming Processes:"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 4

echo ""
```

- make the script executable
```bash
sudo chmod +x /usr/local/bin/system_report.sh
```
## CREATE CRON JOB
- create a cron job to run the script every 5 minutes
- edit crontab
```bash
sudo crontab -e
```
- add below line at the end of file
```bash
*/5 * * * * /usr/local/bin/system_report.sh >> /var/log/system_report.log 2>&1
```
- save and exit
- verify cron job
```bash
sudo crontab -l
```

- Now the script will run every 5 minutes and append output to /var/log/system_report.log
- check the log file after some time to see the output
```bash
cat /var/log/system_report.log
```

# PART IV

## Configure AWS CLI
- install aws cli
```bash
sudo snap install aws-cli --classic
```
- configure aws cli with proper iam user credentials
```bash
aws configure
```
- provide access key, secret key, region and output format

## AWS CLOUDWATCH LOGS INTEGRATION
- create log group
- create log group using aws cli
```bash
aws logs create-log-group --log-group-name /devops/intern-metrics
```

- create log stream
```bash
aws logs create-log-stream \
--log-group-name /devops/intern-metrics \
--log-stream-name ec2-metrics-stream
```

- convert log file to cloudwatch compatible json (leaving white spaces lines)
```bash
echo "[" > events.json
while IFS= read -r line; do
    if [ -n "$line" ]; then
        echo "{\"timestamp\": $(date +%s000), \"message\": \"${line//\"/\\\"}\"}," >> events.json
    fi
done < /var/log/system_report.log
sed -i '$ s/,$//' events.json
echo "]" >> events.json
```

- upload logs to cloudwatch
```bash
aws logs put-log-events \
--log-group-name /devops/intern-metrics \
--log-stream-name ec2-metrics-stream \
--log-events file://events.json
```

### Note:
- Make sure AWS CLI is configured with proper IAM permissions to create log groups, log streams, and put log events.