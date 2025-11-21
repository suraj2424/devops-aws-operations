# DevOps Assignment

This repository contains my completed DevOps assignment, covering EC2 setup, web service deployment, automation using Bash and Cron, AWS CloudWatch integration, and final documentation.

---

## Part 1: Environment Setup

### Steps Completed
- Launched a **t3.micro Ubuntu EC2** instance (Free Tier).
- ⚠️ Note: Here used t3.micro instead of t2.micro since it had free tier eligitibility.
- Created a new user: **devops_intern**
- Granted passwordless sudo access.
- Updated hostname to include my name: `suraj-devops`.

### Deliverables
- Screenshot showing:
  - Updated hostname  
  - `devops_intern` entry in `/etc/passwd`  
  - Output of `sudo whoami` executed by `devops_intern`

Screenshots of this part are in the `Part I` directory._
---

## Part 2: Simple Web Service Setup

### Steps Completed
- Installed **Nginx** on the EC2 instance.
- Created a custom HTML page at: `/var/www/html/index.html`

- Page displays:
- My name  
- EC2 Instance ID (fetched via metadata)  
- Server uptime  

### Deliverables
- Screenshot of the webpage accessed through the instance's **public IP**.

Screenshots of this part are in the `Part II` directory._
---

## Part 3: Monitoring Script

### Steps Completed
Created a monitoring script at: `/usr/local/bin/system_report.sh`

The script outputs:
- Current date & time  
- System uptime  
- CPU usage  
- Memory usage  
- Disk usage  
- Top 3 CPU-consuming processes  

Created a cron job to run the script every **5 minutes**, appending output to: `/var/log/system_report.log`

### Cronjob Entry (Deliverable 1)
`*/5 * * * * /usr/local/bin/system_report.sh >> /var/log/system_report.log 2>&1`

### Deliverables
- Screenshot of log file after at least **two runs**.

Screenshots of this part are in the `Part III` directory._

---

## Part 4: AWS Integration (CloudWatch Logs)

### Steps Completed
- Created CloudWatch log group: `/devops/intern-metrics`
- Created log stream: `ec2-metrics-stream`
- Converted the log file into CloudWatch-compatible JSON.
- Uploaded logs using AWS CLI.


### AWS CLI Commands Used (Deliverable 1)

Screenshots of this part are in the `Part IV` directory._

- Create Log Group:
```bash
aws logs create-log-group --log-group-name /devops/intern-metrics
```
- Create Log Stream:
```bash
aws logs create-log-stream \
--log-group-name /devops/intern-metrics \
--log-stream-name ec2-metrics-stream
```

- Create JSON log file:
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

- Upload logs:
```bash
aws logs put-log-events \
--log-group-name /devops/intern-metrics \
--log-stream-name ec2-metrics-stream \
--log-events file://events.json
```

### Deliverables
- Screenshot showing log entries inside CloudWatch Logs.

Screenshots of this part are in the `Part IV` directory.
---

## 📚 How to Reproduce This Environment

1. Launch an Ubuntu EC2 instance (Free Tier).
2. Create a user, configure sudo, update hostname.
3. Install Nginx or Apache.
4. Create a simple HTML file showing metadata and uptime.
5. Write a monitoring script and schedule it via cron.
6. Install and configure AWS CLI.
7. Create CloudWatch log group + stream.
8. Upload logs via AWS CLI.
9. Verify in CloudWatch console.

---

## ✔️ Completed By
**Suraj Suryawanshi**
