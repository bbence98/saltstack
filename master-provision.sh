#!/bin/bash

## SSH

ssh_location="/home/vagrant/.ssh"

if [ ! -d $ssh_location ]; then
    mkdir $ssh_location
    cat /vagrant/*.pub >> /home/vagrant/.ssh/authorized_keys
fi

## Saltstack

# master with minion

salt_master_location=/etc/init.d/salt-master
minion_name="master-minion"

if [ ! -f $salt_master_location ]; then
    
    wget -O - https://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

    echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest bionic main" > /etc/apt/sources.list.d/saltstack.list

    sudo apt-get update -y

    sudo apt-get install -y salt-master salt-minion salt-api salt-cloud salt-ssh salt-syndic
    sudo apt-get upgrade -y
    
    mkdir /srv/salt
    
    wget https://raw.githubusercontent.com/saltstack/salt/develop/pkg/salt.bash
    mv salt.bash /etc/bash_completion.d/
    source /etc/bash_completion.d/salt.bash

    sudo systemctl start salt-master salt-minion

    master_pub=$(salt-key -F master| awk '/master\.pub:  (.*)/{print $2}')
    
    echo $minion_name > /etc/salt/minion_id
    echo "master: 192.168.10.198" > /etc/salt/minion.d/minion.conf
    echo "master_finger:" $master_pub >> /etc/salt/minion.d/minion.conf
    
    sudo systemctl restart salt-master.service salt-minion.service
    sudo chown -R vagrant:vagrant /etc/salt /var/cache/salt /var/log/salt /var/run/salt /srv/salt
    
    echo "master configured"
    
    ## Accept the keys manually
fi

sudo reboot
