# Install Prometheus
- Create an ec2 instance with Ubuntu 22.04 ami and t2.micro instance-type, allow inbond traffic on 9090 **(default port for prometheus)**
- Create two ec2 instance  for use as **app servers** with Ubuntu 22.04 ami and t2.micro instance-type, allow inbond traffic on 9100
- ssh into prometheus server 
- install git by running 
  ```
  sudo apt install git -y
  ```
- clone prometheus repo from within server 
```
git clone https://github.com/Michaelgwei86/eagles-batch-devops-projects.git
```
- then navigate to the prometheus folder by running
```
cd /home/ubuntu/eagles-batch-devops-projects
```
- Checkout to the prometheus-and-grafana branch
```
git checkout prometheus-and-grafana
```
- install prometheus by running 
  ```
   sh install-prometheus.sh
  ```
- check that prometheus service is running 
  ```
   sudo systemctl status prometheus.service

   ```
- Access prometheus on the browser by using 
  ``` 
  public-ip:9090
  ```
# Install Node Exporter

- ssh into app server  by using ssh or instance connect
- Instal git and clone the github repo with source code(follow same steps as in previous stage above)
  - install git by running 
  ```
  sudo apt install git -y
  ```
  - clone prometheus repo from within server 
  ```
   git clone https://github.com/Michaelgwei86/eagles-batch-devops-projects.git
  ```
  - then navigate to th e prometheus folder by running
  ```
  cd maven-sonarqube-nexus-project/prometheus
  ```
- install node exporter 
  ```
  sh install-node-exporter.sh
  ```
- navigate to prometheus server then run below command
  ```
  cd /etc/prometheus/
  ```
- then edit the prometheus file using 
  ```
  sudo nano prometheus.yml
  ```
- add private ip address of app server with node exporter installed and paste in **- targets section** like this <private_ip:9100>
  ```
  scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    ```
- use ctrl x y enter to save and exit the nano editor
- restart prometheus service by running 
  ```
  sudo systemctl restart prometheus.service
  ```

# Configure Service discovery for Prometheus
- create two new ec2-instance for prometheus service discovery, OS=Ubuntu, instance_type=t2.nano. Allow inbound traffic on 9100
- Associate IAM role for ec2 to the prometheus server. Ensure role has admin access
- Update file with config from prometheus_service Discovery.yml from cloned folder like this

```bash
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'node'
    ec2_sd_configs:
      - region: us-east-1
        port: 9100

#scrape_configs:
 # - job_name: 'prometheus'
  #  static_configs:
   #   - targets: ['172.31.39.131:9100']

# rule_files:
#   - "alertmanager-rules.yml"

# alerting:
#   alertmanagers:
#   - static_configs:
#     - targets:
#       - localhost:9093
```

  ```
  sudo nano /etc/prometheus/prometheus.yml 
  ```
- restart prometheus service 
  ```
  sudo systemctl restart prometheus.service
  ```
- verify targets in prometheus to confirm that prometheus can now discover the newly added servers

# Install Grafana
- Create an ec2 instance with Ubuntu 20.04 ami and t2.micro instance-type, allow inbond traffic on 3000 **(default port for grafana)**
  
- ssh into grafana server 
- install git by running 
  ```
  sudo apt install git -y
  ```
- clone prometheus repo from within server 
```
git clone https://github.com/anselmenumbisia/maven-sonarqube-nexus-project.git
```
- then navigate to th e prometheus folder by running
```
cd /home/ubuntu/maven-sonarqube-nexus-project/prometheus
```
- install grafana by running 
  ```
   sh install-grafana.sh
  ```
- check that grafana service is running 
  ```
  sudo systemctl status grafana-server.service
  ```
- To access grafana on the UI, 
```bash
- Access Grafana: Open a web browser and go to http://<Grafana-EC2-IP>:3000/.
- Login: Default username and password are both admin (you will be prompted to change the password).
- Add Data Source:
- Click on the gear icon (Settings) in the left sidebar.
- Click on Data Sources.
- Click the Add data source button.
- Select Prometheus.
- In the URL field, enter http://<Prometheus-EC2-IP>:9090.
- Click Save & Test to verify the connection.
 1. Create Grafana Dashboards
- Create a Dashboard:
- Click the + icon in the left sidebar.
- Click Dashboard.
- Click Add new panel.
- Configure the query and visualization options to display your Prometheus metrics.
- Save the dashboard
```

##
- Grab grafana dashboards from here https://grafana.com/grafana/dashboards/ 
- grab this dashboard id < https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/ >  **ID: 11074**

# Install prometheus alertmanager
- ssh into prometheus server
- edit inbound sg to allow traffic on port 9093
- then navigate to the prometheus folder by running
```
cd /home/ubuntu/maven-sonarqube-nexus-project/prometheus
```
- install alertmanager
  ```
   sh install-alertmanager.sh 
   ```
- access alertmanager on the browser using < public_ip:9093 >
  
  ## Test Alertmanager
- Navigate to https://myaccount.google.com/
- configure 2 step verification for your google account if prompted to
- search for **app passwords**
- Create an app password and save the peassword in a safe location
- Navigate to your prometheus server and edit your alert manager config file by running
  ```
  sudo nano /etc/alertmanager/alertmanager.yml 
  ```
- update content with your own variables and paster password generated in previous step as value for **auth password**. Update email address to point to your email for test
- restart the alermanager service 
 ```
sudo systemctl restart alertmanager
```
- Edit prometheus config file to call an alertmanager rule file called **alertmanager-rules.yml**
  ```
  sudo nano /etc/prometheus/prometheus.yml
  ```

- uncomment section for alert manager in this file as see below

```
 rule_files:
   - "alertmanager-rules.yml"

 alerting:
   alertmanagers:
   - static_configs:
     - targets:
       - localhost:9093

```

- save file and restart prometheus service 
  ```
  sudo systemctl restart prometheus
  ```
- Check in prometheus app > status > rules that you can now see the rules
- 
## Test alert rules
- ssh into any apps/target servers where node exporter is installed
- install stress
```
 sudo apt-get install stress
 ```
- The run 
```
stress --cpu 4 --timeout 300s
```

