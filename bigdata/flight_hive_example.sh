#!/bin/bash

export IMAGE_USER="ubuntu"
MASTER_IP=`nova list | grep master | awk '{print $12}' | cut -d"=" -f2`

(cat | tee > /tmp/hive.sql) << EOF
CREATE TABLE flights (Year STRING, Month STRING, DayofMonth STRING, DayOfWeek STRING, DepTime STRING, CRSDepTime STRING, ArrTime STRING, CRSArrTime STRING, UniqueCarrier STRING, FlightNum STRING, TailNum STRING, ActualElapsedTime STRING, CRSElapsedTime STRING, AirTime STRING, ArrDelay STRING, DepDelay STRING, Origin STRING, Dest STRING, Distance STRING, TaxiIn STRING, TaxiOut STRING, Cancelled STRING, CancellationCode STRING, Diverted STRING, CarrierDelay STRING, WeatherDelay STRING, NASDelay STRING, SecurityDelay STRING, LateAircraftDelay STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','; 
LOAD DATA LOCAL INPATH '../hadoop/data.csv' OVERWRITE INTO TABLE flights;

SELECT origin, dest FROM flights WHERE UniqueCarrier="AA";
EOF

scp -r -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet /tmp/hive.sql $IMAGE_USER@$MASTER_IP: > /dev/null 2>&1

ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo cp -r hive.sql /home/hadoop/ ; sudo chown -R hadoop:hadoop /home/hadoop/hive.sql" > /dev/null 2>&1

ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo wget http://stat-computing.org/dataexpo/2009/2008.csv.bz2 -P /home/hadoop; sudo apt-get update && sudo apt-get install bzip2 -y; sudo bunzip2 /home/hadoop/*.bz2 ; sudo chown hadoop:hadoop /home/hadoop/*.csv; sudo su hadoop -c 'sed 1d /home/hadoop/2008.csv > /home/hadoop/data.csv ; hadoop dfs -put /home/hadoop/data.csv /user/hadoop/data.csv ; cd /home/hadoop ; /opt/hive/bin/hive -f /home/hadoop/hive.sql'"
