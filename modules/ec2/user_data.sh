#!/bin/bash

# User data script for Ubuntu EC2 instances
# This script installs and configures the Java application on Ubuntu 22.04

set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y \
    openjdk-17-jdk \
    wget \
    curl \
    unzip \
    git \
    htop \
    awscli \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker (optional)
if [ "${install_docker}" = "true" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
fi

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Create application user
useradd -r -s /bin/false appuser || true

# Download and setup Java application
# This is a placeholder - replace with your actual application deployment
cat > /opt/app/application.jar << 'EOF'
# Placeholder for your Java application JAR file
# Replace this with actual application deployment logic
# Example: wget https://your-repo.com/application.jar
EOF

# Create application configuration
cat > /opt/app/application.properties << EOF
# Application Configuration
server.port=${app_port}
spring.datasource.url=jdbc:mysql://${db_endpoint}:3306/${db_name}
spring.datasource.username=${db_username}
spring.datasource.password=\${DB_PASSWORD}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# Logging configuration
logging.level.com.${project_name}=INFO
logging.file.name=/var/log/${project_name}-${environment}.log

# Health check endpoint
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always

# JVM settings
server.tomcat.max-threads=200
server.tomcat.min-spare-threads=10
EOF

# Create systemd service file
cat > /etc/systemd/system/${project_name}-${environment}.service << EOF
[Unit]
Description=${project_name} ${environment} Application
After=network.target

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/app
ExecStart=/usr/bin/java -Xms512m -Xmx1024m -jar /opt/app/application.jar --spring.config.location=file:/opt/app/application.properties
Restart=always
RestartSec=10
Environment=DB_PASSWORD=\$(aws ssm get-parameter --name "/${project_name}/${environment}/db-password" --with-decryption --query 'Parameter.Value' --output text --region ap-south-1)
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

[Install]
WantedBy=multi-user.target
EOF

# Create health check script
cat > /opt/app/health-check.sh << 'EOF'
#!/bin/bash
# Health check script
curl -f http://localhost:${app_port}/health || exit 1
EOF

chmod +x /opt/app/health-check.sh

# Create log directory
mkdir -p /var/log
touch /var/log/${project_name}-${environment}.log
chown appuser:appuser /var/log/${project_name}-${environment}.log

# Set permissions
chown -R appuser:appuser /opt/app

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/${project_name}-${environment}.log",
                        "log_group_name": "/aws/ec2/${project_name}-${environment}",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/syslog",
                        "log_group_name": "/aws/ec2/${project_name}-${environment}-system",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Enable and start the application service
systemctl daemon-reload
systemctl enable ${project_name}-${environment}
systemctl start ${project_name}-${environment}

# Create a simple health check endpoint if the application doesn't have one
cat > /opt/app/health-endpoint.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import json
import subprocess
import sys

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            try:
                # Check if Java process is running
                result = subprocess.run(['pgrep', '-f', 'java.*application.jar'], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    response = {'status': 'healthy', 'service': 'java-app'}
                    self.wfile.write(json.dumps(response).encode())
                else:
                    self.send_response(503)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    response = {'status': 'unhealthy', 'service': 'java-app'}
                    self.wfile.write(json.dumps(response).encode())
            except Exception as e:
                self.send_response(503)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {'status': 'error', 'error': str(e)}
                self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    PORT = 8080
    with socketserver.TCPServer(("", PORT), HealthHandler) as httpd:
        print(f"Health check server running on port {PORT}")
        httpd.serve_forever()
EOF

# Install Python3 if not already installed
apt-get install -y python3

# Make health endpoint executable
chmod +x /opt/app/health-endpoint.py

# Create systemd service for health endpoint (as backup)
cat > /etc/systemd/system/health-endpoint.service << EOF
[Unit]
Description=Health Check Endpoint
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 /opt/app/health-endpoint.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable health endpoint service
systemctl daemon-reload
systemctl enable health-endpoint
systemctl start health-endpoint

# Create log rotation configuration
cat > /etc/logrotate.d/${project_name}-${environment} << EOF
/var/log/${project_name}-${environment}.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 appuser appuser
    postrotate
        systemctl reload ${project_name}-${environment} > /dev/null 2>&1 || true
    endscript
}
EOF

# Set up automatic security updates
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# Configure timezone
timedatectl set-timezone UTC

# Signal completion
echo "User data script completed successfully" >> /var/log/user-data.log

