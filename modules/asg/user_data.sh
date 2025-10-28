#!/bin/bash

# User data script for Ubuntu application servers
# This script installs and configures the Java application

set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install Java 17
apt-get install -y openjdk-17-jdk

# Install other required packages
apt-get install -y wget curl unzip git htop awscli

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Download and install application (replace with your actual application)
# This is a placeholder - replace with your actual application deployment
cat > /opt/app/application.jar << 'EOF'
# Placeholder for your Java application JAR file
# Replace this with actual application deployment logic
EOF

# Create application configuration
cat > /opt/app/application.properties << EOF
# Application Configuration
server.port=8080
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
EOF

# Create application user
useradd -r -s /bin/false appuser || true

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
curl -f http://localhost:8080/health || exit 1
EOF

chmod +x /opt/app/health-check.sh

# Create log directory
mkdir -p /var/log
touch /var/log/${project_name}-${environment}.log
chown appuser:appuser /var/log/${project_name}-${environment}.log

# Set permissions
chown -R appuser:appuser /opt/app

# Enable and start the service
systemctl daemon-reload
systemctl enable ${project_name}-${environment}
systemctl start ${project_name}-${environment}

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

# Signal completion
/opt/aws/bin/cfn-signal -e $? --stack ${project_name}-${environment} --resource AutoScalingGroup --region ap-south-1

