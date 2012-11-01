cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /usr/local/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /usr/local/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /usr/local/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /usr/local/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /usr/local/bin/nova-scheduler
cd /opt/stack/nova && /usr/local/bin/nova-network
cd /opt/stack/nova && /usr/local/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /usr/local/bin/nova-compute
cd /opt/stack/nova && /usr/local/bin/nova-api
cd /opt/stack/glance; /usr/local/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /usr/local/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
killall screen
git checkout master
./stack.sh 
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
fdisk
sudo fdisk 
sudo fdisk -l
fdisk -l
sudo fdisk -l
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd
ls
cd
mongo node75:29025
ls
vi devstack/localrc 
cp devstack/localrc .
chattr +i localrc 
sudo chattr +i localrc 
rm localrc 
ls
cd /opt/stack/nova && /usr/local/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /usr/local/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /usr/local/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /usr/local/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /usr/local/bin/nova-scheduler
cd /opt/stack/nova && /usr/local/bin/nova-network
cd /opt/stack/nova && /usr/local/bin/nova-cert
cd /opt/stack/nova && /usr/local/bin/nova-api
cd /opt/stack/nova && sg libvirtd /usr/local/bin/nova-compute
cd /opt/stack/glance; /usr/local/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /usr/local/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd
sudo cp /root/.bashrc .
. .bashrc 
ls
vi localrc 
rm -r -f *
vgs
sudo vgs
ls
git clone https://github.com/openstack-dev/devstack.git
cd devstack/
git checkout stable/folsom
git branch
cp ../localrc .
ls
vi localrc 
df -h
ls
./stack.sh 
ps ax|grep nova
cd
ls
cd keystone
ls
cd keystone
ls
cd identity/
ls
cd backends/
ls
ps ax|grep kvm
mount
ls /opt/stack/data/nova/instances/
cat /opt/stack/data/nova/networks/nova-br100.conf 
cd /opt/stack/nova/
git branch
cd
ls 
ps ax|grep vnc
vi /etc/nova/nova.conf 
cd /opt/stack/horizon/
ls
grep -R 728 *
vi horizon/dashboards/nova/instances/templates/instances/_detail_vnc.html 
sudo /etc/init.d/apache2 restart
vi /etc/nova/nova.conf 
cd
cd devstack/
ls
grep demo
vi files/keystone_data.sh 
killall screen
cd
cd devstack/
./stack.sh 
vi files/keystone_data.sh 
killall screen
./stack.sh 
killall screen
vi files/keystone_data.sh 
./stack.sh 
cd 
cd keystone
ls
cd identity/
ls
ps ax|grep kvm
cd
cd cinder/
ls
cd cinder
grep -R _copy *
vi volume/driver.py
cd
cd devstack/
killall screen
./stack.sh 
ps ax|grep kvm
vgs
sudo vgs
sudo lvs
ps ax|grep dd
sudo lvs
cd
cd devstack/
vi files/keystone_data.sh 
vi stack.sh 
cd
cd devstack/
./stack.sh 
vi files/keystone_data.sh 
mongo node75:29025
vi /etc/keystone/keystone.conf 
ps ax|grep nova
mount
mdadm
apt-get install mdadm
sudo apt-get install mdadm
sudo rabbitmqctl list_queues
sudo rabbitmqctl list_exchanges
sudo   rabbitmqctl list_bindings
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd
ld
ls
cd devstack/
vi lib/nova 
./stack.sh 
vi /etc/nova/nova.conf 
ssh node79
cd
cd nova/
ls
grep -R processLauncher *
grep -R ProcessLauncher *
grep -R ServiceLauncher *
grep -R Launcher *
vi nova/service.py
vi bin/nova-compute 
vi nova/service.py
vi bin/nova-compute 
vi nova/service.py
vi bin/nova-compute 
vi nova/service.py
vi nova/manager.py
vi nova/service.py
sudo rabbitmqctl list_queues
sudo rabbitmqctl list_queues|grep schedule
vi nova/service.py
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd
ls
vi localrc 
chattr -i localrc 
sudo chattr -i localrc 
ll
chown root:root localrc 
sudo chown root:root localrc 
vi localrc 
sudo vi localrc 
killall screen
cd devstack/
./stack.sh 
cp ../localrc .
vi localrc 
./stack.sh 
vi localrc 
./stack.sh 
vi localrc 
vi ../localrc 
cp ../localrc .
vi localrc 
./stack.sh 
cd
cd tem
cd
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-cert
cd /opt/stack/nova && /opt/stack/nova/bin/nova-objectstore
cd /opt/stack/horizon && sudo tail -f /var/log/apache2/horizon_error.log
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-volume --config-file /etc/cinder/cinder.conf
cd /opt/stack/cinder && /opt/stack/cinder/bin/cinder-api --config-file /etc/cinder/cinder.conf
cd /opt/stack/nova && ./bin/nova-consoleauth
cd /opt/stack/nova && ./bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf
cd /opt/stack/noVNC && ./utils/nova-novncproxy --config-file /etc/nova/nova.conf --web .
cd /opt/stack/nova && /opt/stack/nova/bin/nova-scheduler
cd /opt/stack/nova && /opt/stack/nova/bin/nova-network
cd /opt/stack/nova && sg libvirtd /opt/stack/nova/bin/nova-compute
cd /opt/stack/glance; /opt/stack/glance/bin/glance-api --config-file=/etc/glance/glance-api.conf
cd /opt/stack/nova && /opt/stack/nova/bin/nova-api
cd /opt/stack/keystone && /opt/stack/keystone/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug
cd /opt/stack/glance; /opt/stack/glance/bin/glance-registry --config-file=/etc/glance/glance-registry.conf
vi localrc 
vi devstack/lib/glance 
vi devstack/stack.sh 
vi devstack/lib/glance 
vi devstack/lib/template 
vi devstack/lib/glance 
vi devstack/stack.sh 
vi localrc 
cd devstack/
vi localrc 
cp ../localrc .
vi localrc 
./stack.sh 
vi localrc 
ssh node79
ssh root@node79
vi localrc 
./stack.sh 
cd
. devstack/eucarc admin
ps ax|grep k
. devstack/eucarc 
. devstack/eucarc admin
vi .bashrc 
. .bashrc 
nova list
nova flavor list
nova flavor-list
nova resize
nova resize 1212 m1.small
nova list
ll /opt/stack/data/nova/instances/
nova list
nova confirm-resize
nova
nova help
nova resize-confirm
nova resize-confirm 1212
nova list
cd /opt/stack/horizon/
ls
cd horizon
ls
cd dashboards/nova/
ls
cd instances/
ls
vi tables.py
/etc/init.d/apache2 restart
sudo /etc/init.d/apache2 restart
vi tables.py
sudo /etc/init.d/apache2 restart
vi tables.py
sudo /etc/init.d/apache2 restart
vi tables.py
ls
vi tables.py
vi urls.py
vi /opt/stack/devstack/localrc 
vi urls.py
vi tables.py
sudo /etc/init.d/apache2 restart
vi tables.py
sudo /etc/init.d/apache2 restart
vi urls.py
ls
vi views.py
vi urls.py
sudo /etc/init.d/apache2 restart
grep UpdateView *
vi urls.py
sudo /etc/init.d/apache2 restart
vi urls.py
vi views.py
vi urls.py
sudo /etc/init.d/apache2 restart
vi urls.py
vi views.py
sudo /etc/init.d/apache2 restart
vi views.py
find /opt/stack/horizon/ -name update.*
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/update.html 
cp /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/update.html /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/resize.html
vi views.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/resize.html 
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_update.html 
sudo /etc/init.d/apache2 restart
cp /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_update.html /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/resize.html 
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi tables.py
sudo /etc/init.d/apache2 restart
vi tables.py
vi views.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
vi views.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/index.html 
vi views.py
vi tables.py
ls
vi forms.py
vi __init__.py
vi panel.py
vi tabs.py
vi tables.py
vi forms.py
vi views.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
ls
vi templates/instances/index.html 
grep table *
ls
vi workflows.py
vi urls.py
vi views.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/resize.html 
vi views.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
sudo /etc/init.d/apache2 restart
ls
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
grep update *
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
vi urls.py
vi /opt/stack/horizon/horizon/dashboards/nova/instances/templates/instances/_resize.html 
vi urls.py
ls
vi views.py
