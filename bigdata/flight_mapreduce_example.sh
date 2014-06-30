#!/bin/bash

export IMAGE_USER="ubuntu"
MASTER_IP=`nova list | grep master | awk '{print $12}' | cut -d"=" -f2`

scp -r -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet mapreduce_jobs/flight $IMAGE_USER@$MASTER_IP: > /dev/null 2>&1

ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo cp -r flight /home/hadoop/ ; sudo chown -R hadoop:hadoop /home/hadoop/flight" > /dev/null 2>&1

ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo cp -r flight /home/hadoop/ ; sudo chown -R hadoop:hadoop /home/hadoop/flight; sudo wget http://stat-computing.org/dataexpo/2009/2008.csv.bz2 -P /home/hadoop; sudo apt-get update && sudo apt-get install bzip2 -y; sudo bunzip2 /home/hadoop/*.bz2 ; sudo chown hadoop:hadoop /home/hadoop/*.csv; sudo su hadoop -c 'cd /usr/share/hadoop; sed 1d /home/hadoop/2008.csv > /home/hadoop/data.csv ; hadoop dfs -put /home/hadoop/data.csv /user/hadoop/data.csv ; mkdir /home/hadoop/flight/flightcarrierperformance_classes; /usr/java/jdk1.7.0_25/bin/javac -Xlint -classpath /usr/share/hadoop/hadoop-core-1.2.1.jar:/usr/share/hadoop/lib/commons-cli-1.2.jar -d /home/hadoop/flight/flightcarrierperformance_classes/ /home/hadoop/flight/FlightCarrierPerformance.java /home/hadoop/flight/Performance.java ; /usr/java/jdk1.7.0_25/bin/jar -cvf /home/hadoop/flight/FlightCarrierPerformance.jar -C /home/hadoop/flight/flightcarrierperformance_classes/ . ; hadoop jar /home/hadoop/flight/FlightCarrierPerformance.jar org.myorg.FlightCarrierPerformance data.csv job_output ; hadoop dfs -cat /user/hadoop/job_output/part-r-00000'"
