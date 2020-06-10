#!/bin/bash

## SSH

ssh_location="/home/vagrant/.ssh"

if [ ! -d $ssh_location ]; then
    mkdir $ssh_location
    cat /vagrant/*.pub >> $ssh_location/authorized_keys
fi


## Saltstack

# master with minion

salt_master_location=/etc/init.d/salt-master
minion_name="master-minion"

if [ ! -f $salt_master_location ]; then
    
    wget -O - https://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

    echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest bionic main" > /etc/apt/sources.list.d/saltstack.list

    apt-get update -y

    apt-get install -y salt-master salt-minion salt-api salt-cloud salt-ssh salt-syndic
    apt-get upgrade -y
    
    wget https://raw.githubusercontent.com/saltstack/salt/develop/pkg/salt.bash
    cp salt.bash /etc/bash_completion.d/
    source /etc/bash_completion.d/salt.bash

    systemctl start salt-master salt-minion

    master_pub=$(salt-key -F master| awk '/master\.pub:  (.*)/{print $2}')
    
    echo $minion_name > /etc/salt/minion_id
    echo "master: 192.168.10.198" > /etc/salt/minion.d/minion.conf
    echo "master_finger:" $master_pub >> /etc/salt/minion.d/minion.conf
    
    systemctl restart salt-minion
    service salt-minion restart
    
    salt-key -a $minion_name -y
fi
