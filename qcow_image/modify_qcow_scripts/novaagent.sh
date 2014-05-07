#!/bin/bash

cd ~/
mkdir nova-agent
cd nova-agent
wget http://boot.rackspace.com/files/nova-agent/nova-agent-Linux-x86_64-1.39.0.tar.gz
tar xzf nova-agent-*.tar.gz
./installer.sh
sed '1i### BEGIN INIT INFO\n# Provides: Nova-Agent\n# Required-Start: $remote_fs $syslog\n# Required-Stop: $remote_fs $syslog\n# Default-Start: 2 3 4 5\n# Default-Stop: 0 1 6\n# Short-Description: Start daemon at boot time\n# Description: Enable service provided by daemon.\n### END INIT INFO\n' /usr/share/nova-agent/1.39.0/etc/generic/nova-agent > /usr/share/nova-agent/1.39.0/etc/generic/nova-agent.lsb
cp -av /usr/share/nova-agent/1.39.0/etc/generic/nova-agent.lsb /etc/init.d/nova-agent
chmod +x /etc/init.d/nova-agent
update-rc.d -f nova-agent defaults
/etc/init.d/nova-agent restart
cd ..
rm -rf nova-agent
