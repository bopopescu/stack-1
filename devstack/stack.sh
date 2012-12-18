#!/usr/bin/env bash
CALLER=$1
CONTROLLER_ADDRESS=$2

killall screen 1>/dev/null 2>&1
# Keep track of the devstack directory
TOP_DIR=$(cd $(dirname "$0") && pwd)

# Import common functions
source $TOP_DIR/functions

# Determine what system we are running on.  This provides ``os_VENDOR``,
# ``os_RELEASE``, ``os_UPDATE``, ``os_PACKAGE``, ``os_CODENAME``
# and ``DISTRO``
GetDistro


# Settings
# ========
if [[ ! -r $TOP_DIR/stackrc ]]; then
    echo "ERROR: missing $TOP_DIR/stackrc - did you grab more than just stack.sh?"
    exit 1
fi
source $TOP_DIR/stackrc


# Proxy Settings
# --------------

# HTTP and HTTPS proxy servers are supported via the usual environment variables [1]
# ``http_proxy``, ``https_proxy`` and ``no_proxy``. They can be set in
# ``localrc`` if necessary or on the command line::
#
# [1] http://www.w3.org/Daemon/User/Proxies/ProxyClients.html
#
#     http_proxy=http://proxy.example.com:3128/ no_proxy=repo.example.net ./stack.sh

if [[ -n "$http_proxy" ]]; then
    export http_proxy=$http_proxy
fi
if [[ -n "$https_proxy" ]]; then
    export https_proxy=$https_proxy
fi
if [[ -n "$no_proxy" ]]; then
    export no_proxy=$no_proxy
fi

# Destination path for installation ``DEST``
DEST=${DEST:-/opt/stack}


# Sanity Check
# ============

# Remove services which were negated in ENABLED_SERVICES
# using the "-" prefix (e.g., "-n-vol") instead of
# calling disable_service().
disable_negated_services

# ``stack.sh`` keeps function libraries here
# Make sure ``$TOP_DIR/lib`` directory is present
if [ ! -d $TOP_DIR/lib ]; then
    echo "ERROR: missing devstack/lib"
    exit 1
fi

# ``stack.sh`` keeps the list of ``apt`` and ``rpm`` dependencies and config
# templates and other useful files in the ``files`` subdirectory
FILES=$TOP_DIR/files
if [ ! -d $FILES ]; then
    echo "ERROR: missing devstack/files"
    exit 1
fi

SCREEN_NAME=${SCREEN_NAME:-stack}
# Check to see if we are already running DevStack
if type -p screen >/dev/null && screen -ls | egrep -q "[0-9].$SCREEN_NAME"; then
    echo "You are already running a stack.sh session."
    echo "To rejoin this session type 'screen -x stack'."
    echo "To destroy this session, type './unstack.sh'."
    exit 1
fi

# Make sure we only have one volume service enabled.
if is_service_enabled cinder && is_service_enabled n-vol; then
    echo "ERROR: n-vol and cinder must not be enabled at the same time"
    exit 1
fi

# Set up logging level
VERBOSE=$(trueorfalse True $VERBOSE)


# root Access
# -----------
if [[ $EUID -eq 0 ]]; then
    # Give the non-root user the ability to run as **root** via ``sudo``
    is_package_installed sudo || install_package sudo
    if ! getent group stack >/dev/null; then
        echo "Creating a group called stack"
        groupadd stack
    fi
    if ! getent passwd stack >/dev/null; then
        echo "Creating a user called stack"
        useradd -g stack -s /bin/bash -d $DEST -m stack
    fi

    # UEC images ``/etc/sudoers`` does not have a ``#includedir``, add one
    grep -q "^#includedir.*/etc/sudoers.d" /etc/sudoers ||
        echo "#includedir /etc/sudoers.d" >> /etc/sudoers
    ( umask 226 && echo "stack ALL=(ALL) NOPASSWD:ALL" \
        > /etc/sudoers.d/50_stack_sh )

    STACK_DIR="$DEST/${PWD##*/}"
    chown -R stack "$STACK_DIR"
    exec su -c "set -e; cd $STACK_DIR; bash stack.sh $CALLER $CONTROLLER_ADDRESS" stack
    exit 1
else
    # We're not **root**, make sure ``sudo`` is available
    is_package_installed sudo || die "Sudo is required.  Re-run stack.sh as root ONE TIME ONLY to set up sudo."

    # UEC images ``/etc/sudoers`` does not have a ``#includedir``, add one
    sudo grep -q "^#includedir.*/etc/sudoers.d" /etc/sudoers ||
        echo "#includedir /etc/sudoers.d" | sudo tee -a /etc/sudoers

    # Set up devstack sudoers
    TEMPFILE=`mktemp`
    echo "`whoami` ALL=(root) NOPASSWD:ALL" >$TEMPFILE
    # Some binaries might be under /sbin or /usr/sbin, so make sure sudo will
    # see them by forcing PATH
    echo "Defaults:`whoami` secure_path=/sbin:/usr/sbin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin" >> $TEMPFILE
    chmod 0440 $TEMPFILE
    sudo chown root:root $TEMPFILE
    sudo mv $TEMPFILE /etc/sudoers.d/50_stack_sh

    # Remove old file
    sudo rm -f /etc/sudoers.d/stack_sh_nova
fi

# Create the destination directory and ensure it is writable by the user
sudo mkdir -p $DEST
sudo chown -R  `whoami` $DEST

# Set ``OFFLINE`` to ``True`` to configure ``stack.sh`` to run cleanly without
# Internet access. ``stack.sh`` must have been previously run with Internet
# access to install prerequisites and fetch repositories.
OFFLINE=`trueorfalse False $OFFLINE`

# Set ``ERROR_ON_CLONE`` to ``True`` to configure ``stack.sh`` to exit if
# the destination git repository does not exist during the ``git_clone``
# operation.
ERROR_ON_CLONE=`trueorfalse False $ERROR_ON_CLONE`

# Destination path for service data
DATA_DIR=${DATA_DIR:-${DEST}/data}
sudo mkdir -p $DATA_DIR
sudo chown `whoami` $DATA_DIR


# Common Configuration
# ====================

# Set fixed and floating range here so we can make sure not to use addresses
# from either range when attempting to guess the IP to use for the host.
# Note that setting FIXED_RANGE may be necessary when running DevStack
# in an OpenStack cloud that uses either of these address ranges internally.
FLOATING_RANGE=${FLOATING_RANGE:-172.24.4.224/28}
FIXED_RANGE=${FIXED_RANGE:-10.0.0.0/24}
FIXED_NETWORK_SIZE=${FIXED_NETWORK_SIZE:-256}
NETWORK_GATEWAY=${NETWORK_GATEWAY:-10.0.0.1}

# Find the interface used for the default route
HOST_IP_IFACE=${HOST_IP_IFACE:-$(ip route | sed -n '/^default/{ s/.*dev \(\w\+\)\s\+.*/\1/; p; }')}
# Search for an IP unless an explicit is set by ``HOST_IP`` environment variable
if [ -z "$HOST_IP" -o "$HOST_IP" == "dhcp" ]; then
    HOST_IP=""
    HOST_IPS=`LC_ALL=C ip -f inet addr show ${HOST_IP_IFACE} | awk '/inet/ {split($2,parts,"/");  print parts[1]}'`
    for IP in $HOST_IPS; do
        # Attempt to filter out IP addresses that are part of the fixed and
        # floating range. Note that this method only works if the ``netaddr``
        # python library is installed. If it is not installed, an error
        # will be printed and the first IP from the interface will be used.
        # If that is not correct set ``HOST_IP`` in ``localrc`` to the correct
        # address.
        if ! (address_in_net $IP $FIXED_RANGE || address_in_net $IP $FLOATING_RANGE); then
            HOST_IP=$IP
            break;
        fi
	HOST_IP=$IP
    done
    if [ "$HOST_IP" == "" ]; then
        echo "Could not determine host ip address."
        echo "Either localrc specified dhcp on ${HOST_IP_IFACE} or defaulted"
        exit 1
    fi
fi

# Allow the use of an alternate hostname (such as localhost/127.0.0.1) for service endpoints.
SERVICE_HOST=${SERVICE_HOST:-$HOST_IP}

# Configure services to use syslog instead of writing to individual log files
SYSLOG=`trueorfalse False $SYSLOG`
SYSLOG_HOST=${SYSLOG_HOST:-$HOST_IP}
SYSLOG_PORT=${SYSLOG_PORT:-516}

# Use color for logging output (only available if syslog is not used)
LOG_COLOR=`trueorfalse True $LOG_COLOR`

# Service startup timeout
SERVICE_TIMEOUT=${SERVICE_TIMEOUT:-60}


# Configure Projects
# ==================

# Get project function libraries
source $TOP_DIR/lib/keystone
source $TOP_DIR/lib/glance
source $TOP_DIR/lib/nova
source $TOP_DIR/lib/cinder
source $TOP_DIR/lib/n-vol
source $TOP_DIR/lib/ceilometer
source $TOP_DIR/lib/heat
source $TOP_DIR/lib/quantum

# Set the destination directories for OpenStack projects
HORIZON_DIR=$DEST/horizon
OPENSTACKCLIENT_DIR=$DEST/python-openstackclient
NOVNC_DIR=$DEST/noVNC
SWIFT_DIR=$DEST/swift
SWIFT3_DIR=$DEST/swift3
SWIFTCLIENT_DIR=$DEST/python-swiftclient

# Name of the LVM volume group to use/create for iscsi volumes
VOLUME_GROUP=${VOLUME_GROUP:-stack-volumes}
VOLUME_NAME_PREFIX=${VOLUME_NAME_PREFIX:-volume-}
INSTANCE_NAME_PREFIX=${INSTANCE_NAME_PREFIX:-instance-}

# Generic helper to configure passwords
function read_password {
    XTRACE=$(set +o | grep xtrace)
    set +o xtrace
    var=$1; msg=$2
    pw=${!var}

    localrc=$TOP_DIR/localrc

    # If the password is not defined yet, proceed to prompt user for a password.
    if [ ! $pw ]; then
        # If there is no localrc file, create one
        if [ ! -e $localrc ]; then
            touch $localrc
        fi

        # Presumably if we got this far it can only be that our localrc is missing
        # the required password.  Prompt user for a password and write to localrc.
        echo ''
        echo '################################################################################'
        echo $msg
        echo '################################################################################'
        echo "This value will be written to your localrc file so you don't have to enter it "
        echo "again.  Use only alphanumeric characters."
        echo "If you leave this blank, a random default value will be used."
        pw=" "
        while true; do
            echo "Enter a password now:"
            read -e $var
            pw=${!var}
            [[ "$pw" = "`echo $pw | tr -cd [:alnum:]`" ]] && break
            echo "Invalid chars in password.  Try again:"
        done
        if [ ! $pw ]; then
            pw=`openssl rand -hex 10`
        fi
        eval "$var=$pw"
        echo "$var=$pw" >> $localrc
    fi
    $XTRACE
}


# Nova Network Configuration
# --------------------------
PUBLIC_INTERFACE_DEFAULT=br100
FLAT_NETWORK_BRIDGE_DEFAULT=br100
GUEST_INTERFACE_DEFAULT=eth0

PUBLIC_INTERFACE=${PUBLIC_INTERFACE:-$PUBLIC_INTERFACE_DEFAULT}
NET_MAN=${NET_MAN:-FlatDHCPManager}
EC2_DMZ_HOST=${EC2_DMZ_HOST:-$SERVICE_HOST}
FLAT_NETWORK_BRIDGE=${FLAT_NETWORK_BRIDGE:-$FLAT_NETWORK_BRIDGE_DEFAULT}
VLAN_INTERFACE=${VLAN_INTERFACE:-$GUEST_INTERFACE_DEFAULT}

# Test floating pool and range are used for testing.  They are defined
# here until the admin APIs can replace nova-manage
TEST_FLOATING_POOL=${TEST_FLOATING_POOL:-test}
TEST_FLOATING_RANGE=${TEST_FLOATING_RANGE:-192.168.253.0/29}

# ``MULTI_HOST`` is a mode where each compute node runs its own network node.  This
# allows network operations and routing for a VM to occur on the server that is
# running the VM - removing a SPOF and bandwidth bottleneck.
MULTI_HOST=`trueorfalse False $MULTI_HOST`

# If you are using the FlatDHCP network mode on multiple hosts, set the
# ``FLAT_INTERFACE`` variable but make sure that the interface doesn't already
# have an IP or you risk breaking things.
#
# **DHCP Warning**:  If your flat interface device uses DHCP, there will be a
# hiccup while the network is moved from the flat interface to the flat network
# bridge.  This will happen when you launch your first instance.  Upon launch
# you will lose all connectivity to the node, and the VM launch will probably
# fail.
#
# If you are running on a single node and don't need to access the VMs from
# devices other than that node, you can set FLAT_INTERFACE=
# This will stop nova from bridging any interfaces into FLAT_NETWORK_BRIDGE.
FLAT_INTERFACE=${FLAT_INTERFACE-$GUEST_INTERFACE_DEFAULT}

## FIXME(ja): should/can we check that FLAT_INTERFACE is sane?

MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_USER=${MYSQL_USER:-root}
read_password MYSQL_PASSWORD "ENTER A PASSWORD TO USE FOR MYSQL."

# NOTE: Don't specify ``/db`` in this string so we can use it for multiple services
BASE_SQL_CONN=${BASE_SQL_CONN:-mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST}

# Rabbit connection info
if is_service_enabled rabbit; then
    RABBIT_HOST=${RABBIT_HOST:-localhost}
    read_password RABBIT_PASSWORD "ENTER A PASSWORD TO USE FOR RABBIT."
fi


# Swift
SWIFT_DATA_DIR=${SWIFT_DATA_DIR:-${DEST}/data/swift}
SWIFT_CONFIG_DIR=${SWIFT_CONFIG_DIR:-/etc/swift}
#SWIFT_LOOPBACK_DISK_SIZE=${SWIFT_LOOPBACK_DISK_SIZE:-1000000}#1G

# The ring uses a configurable number of bits from a path’s MD5 hash as
# a partition index that designates a device. The number of bits kept
# from the hash is known as the partition power, and 2 to the partition
# power indicates the partition count. Partitioning the full MD5 hash
# ring allows other parts of the cluster to work in batches of items at
# once which ends up either more efficient or at least less complex than
# working with each item separately or the entire cluster all at once.
# By default we define 9 for the partition count (which mean 512).
SWIFT_PARTITION_POWER_SIZE=${SWIFT_PARTITION_POWER_SIZE:-18}

if is_service_enabled swift; then
    # If we are using swift3, we can default the s3 port to swift instead
    # of nova-objectstore
    if is_service_enabled swift3;then
        S3_SERVICE_PORT=${S3_SERVICE_PORT:-8080}
    fi
    # We only ask for Swift Hash if we have enabled swift service.
    # SWIFT_HASH is a random unique string for a swift cluster that
    # can never change.
    read_password SWIFT_HASH "ENTER A RANDOM SWIFT HASH."
fi

# Set default port for nova-objectstore
S3_SERVICE_PORT=${S3_SERVICE_PORT:-3333}


# Keystone
# --------

# The ``SERVICE_TOKEN`` is used to bootstrap the Keystone database.  It is
# just a string and is not a 'real' Keystone token.
read_password SERVICE_TOKEN "ENTER A SERVICE_TOKEN TO USE FOR THE SERVICE ADMIN TOKEN."
# Services authenticate to Identity with servicename/SERVICE_PASSWORD
read_password SERVICE_PASSWORD "ENTER A SERVICE_PASSWORD TO USE FOR THE SERVICE AUTHENTICATION."
# Horizon currently truncates usernames and passwords at 20 characters
read_password ADMIN_PASSWORD "ENTER A PASSWORD TO USE FOR HORIZON AND KEYSTONE (20 CHARS OR LESS)."

# Set the tenant for service accounts in Keystone
SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-service}



# Horizon
# -------
APACHE_USER=${APACHE_USER:-$USER}
APACHE_GROUP=${APACHE_GROUP:-$APACHE_USER}


# Log files
# ---------

# Draw a spinner so the user knows something is happening
function spinner()
{
    local delay=0.75
    local spinstr='|/-\'
    printf "..." >&3
    while [ true ]; do
        local temp=${spinstr#?}
        printf "[%c]" "$spinstr" >&3
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b" >&3
    done
}

# Echo text to the log file, summary log file and stdout
# echo_summary "something to say"
function echo_summary() {
    if [[ -t 3 && "$VERBOSE" != "True" ]]; then
        kill >/dev/null 2>&1 $LAST_SPINNER_PID
        if [ ! -z "$LAST_SPINNER_PID" ]; then
            printf "\b\b\bdone\n" >&3
        fi
        echo -n $@ >&6
        spinner &
        LAST_SPINNER_PID=$!
    else
        echo $@ >&6
    fi
}

# Echo text only to stdout, no log files
# echo_nolog "something not for the logs"
function echo_nolog() {
    echo $@ >&3
}

# Set up logging for ``stack.sh``
# Set ``LOGFILE`` to turn on logging
# Append '.xxxxxxxx' to the given name to maintain history
# where 'xxxxxxxx' is a representation of the date the file was created
if [[ -n "$LOGFILE" || -n "$SCREEN_LOGDIR" ]]; then
    LOGDAYS=${LOGDAYS:-7}
    TIMESTAMP_FORMAT=${TIMESTAMP_FORMAT:-"%F-%H%M%S"}
    CURRENT_LOG_TIME=$(date "+$TIMESTAMP_FORMAT")
fi

if [[ -n "$LOGFILE" ]]; then
    # First clean up old log files.  Use the user-specified ``LOGFILE``
    # as the template to search for, appending '.*' to match the date
    # we added on earlier runs.
    LOGDIR=$(dirname "$LOGFILE")
    LOGNAME=$(basename "$LOGFILE")
    mkdir -p $LOGDIR
    find $LOGDIR -maxdepth 1 -name $LOGNAME.\* -mtime +$LOGDAYS -exec rm {} \;
    LOGFILE=$LOGFILE.${CURRENT_LOG_TIME}
    SUMFILE=$LOGFILE.${CURRENT_LOG_TIME}.summary

    # Redirect output according to config
    # Copy stdout to fd 3
    exec 3>&1
    if [[ "$VERBOSE" == "True" ]]; then
        # Redirect stdout/stderr to tee to write the log file
        exec 1> >( tee "${LOGFILE}" ) 2>&1
        # Set up a second fd for output
        exec 6> >( tee "${SUMFILE}" )
    else
        # Set fd 1 and 2 to primary logfile
        exec 1> "${LOGFILE}" 2>&1
        # Set fd 6 to summary logfile and stdout
        exec 6> >( tee "${SUMFILE}" /dev/fd/3 )
    fi

    echo_summary "stack.sh log $LOGFILE"
    # Specified logfile name always links to the most recent log
    ln -sf $LOGFILE $LOGDIR/$LOGNAME
    ln -sf $SUMFILE $LOGDIR/$LOGNAME.summary
else
    # Set up output redirection without log files
    # Copy stdout to fd 3
    exec 3>&1
    if [[ "$VERBOSE" != "True" ]]; then
        # Throw away stdout and stderr
        exec 1>/dev/null 2>&1
    fi
    # Always send summary fd to original stdout
    exec 6>&3
fi

# Set up logging of screen windows
# Set ``SCREEN_LOGDIR`` to turn on logging of screen windows to the
# directory specified in ``SCREEN_LOGDIR``, we will log to the the file
# ``screen-$SERVICE_NAME-$TIMESTAMP.log`` in that dir and have a link
# ``screen-$SERVICE_NAME.log`` to the latest log file.
# Logs are kept for as long specified in ``LOGDAYS``.
if [[ -n "$SCREEN_LOGDIR" ]]; then

    # We make sure the directory is created.
    if [[ -d "$SCREEN_LOGDIR" ]]; then
        # We cleanup the old logs
        find $SCREEN_LOGDIR -maxdepth 1 -name screen-\*.log -mtime +$LOGDAYS -exec rm {} \;
    else
        mkdir -p $SCREEN_LOGDIR
    fi
fi


# Set Up Script Execution
# -----------------------

# Kill background processes on exit
trap clean EXIT
clean() {
    local r=$?
    kill >/dev/null 2>&1 $(jobs -p)
    exit $r
}


# Exit on any errors so that errors don't compound
trap failed ERR
failed() {
    local r=$?
    kill >/dev/null 2>&1 $(jobs -p)
    set +o xtrace
    [ -n "$LOGFILE" ] && echo "${0##*/} failed: full log in $LOGFILE"
    exit $r
}

# Print the commands being run so that we can see the command that triggers
# an error.  It is also useful for following along as the install occurs.
set -o xtrace


# Install Packages
# ================
echo_summary "Installing package prerequisites"
install_package $(get_packages $FILES/apts)

if [[ $SYSLOG != "False" ]]; then
    install_package rsyslog-relp
fi

if is_service_enabled rabbit; then
    # Install rabbitmq-server
    # the temp file is necessary due to LP: #878600
    tfile=$(mktemp)
    install_package rabbitmq-server > "$tfile" 2>&1
    cat "$tfile"
    rm -f "$tfile"
fi

if is_service_enabled mysql; then

    if [[ "$os_PACKAGE" = "deb" ]]; then
        # Seed configuration with mysql password so that apt-get install doesn't
        # prompt us for a password upon install.
        cat <<MYSQL_PRESEED | sudo debconf-set-selections
mysql-server-5.1 mysql-server/root_password password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/root_password_again password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/start_on_boot boolean true
MYSQL_PRESEED
    fi

    # while ``.my.cnf`` is not needed for OpenStack to function, it is useful
    # as it allows you to access the mysql databases via ``mysql nova`` instead
    # of having to specify the username/password each time.
    if [[ ! -e $HOME/.my.cnf ]]; then
        cat <<EOF >$HOME/.my.cnf
[client]
user=$MYSQL_USER
password=$MYSQL_PASSWORD
host=$MYSQL_HOST
EOF
        chmod 0600 $HOME/.my.cnf
    fi
    # Install mysql-server
    install_package mysql-server
fi

if is_service_enabled horizon; then
    # Install apache2, which is NOPRIME'd
    install_package apache2 libapache2-mod-wsgi
fi

if is_service_enabled swift; then
    # Install memcached for swift.
    install_package memcached
fi

TRACK_DEPENDS=${TRACK_DEPENDS:-False}

# Install python packages into a virtualenv so that we can track them
if [[ $TRACK_DEPENDS = True ]] ; then
    echo_summary "Installing Python packages into a virtualenv $DEST/.venv"
    install_package python-virtualenv

    rm -rf $DEST/.venv
    virtualenv --system-site-packages $DEST/.venv
    source $DEST/.venv/bin/activate
    $DEST/.venv/bin/pip freeze > $DEST/requires-pre-pip
fi

# Install python requirements
echo_summary "Installing Python prerequisites"
pip_install $(get_packages $FILES/pips | sort -u)


# Check Out Source
# ----------------

echo_summary "Installing OpenStack project source"

install_keystoneclient
install_glanceclient
install_novaclient

# Check out the client libs that are used most
git_clone $OPENSTACKCLIENT_REPO $OPENSTACKCLIENT_DIR $OPENSTACKCLIENT_BRANCH

# glance, swift middleware and nova api needs keystone middleware
if is_service_enabled key g-api n-api swift; then
    # unified auth system (manages accounts/tokens)
    install_keystone
fi
if is_service_enabled swift; then
    # storage service
    git_clone $SWIFT_REPO $SWIFT_DIR $SWIFT_BRANCH
    # storage service client and and Library
    git_clone $SWIFTCLIENT_REPO $SWIFTCLIENT_DIR $SWIFTCLIENT_BRANCH
    if is_service_enabled swift3; then
        # swift3 middleware to provide S3 emulation to Swift
        git_clone $SWIFT3_REPO $SWIFT3_DIR $SWIFT3_BRANCH
    fi
fi
if is_service_enabled g-api n-api; then
    # image catalog service
    install_glance
fi
if is_service_enabled nova; then
    # compute service
    install_nova
fi
if is_service_enabled n-novnc; then
    # a websockets/html5 or flash powered VNC console for vm instances
    git_clone $NOVNC_REPO $NOVNC_DIR $NOVNC_BRANCH
fi
if is_service_enabled horizon; then
    # django powered web control panel for openstack
    git_clone $HORIZON_REPO $HORIZON_DIR $HORIZON_BRANCH $HORIZON_TAG
fi
if is_service_enabled quantum; then
    git_clone $QUANTUM_CLIENT_REPO $QUANTUM_CLIENT_DIR $QUANTUM_CLIENT_BRANCH
fi
if is_service_enabled quantum; then
    # quantum
    git_clone $QUANTUM_REPO $QUANTUM_DIR $QUANTUM_BRANCH
fi
if is_service_enabled heat; then
    install_heat
fi
if is_service_enabled cinder; then
    install_cinder
fi
if is_service_enabled ceilometer; then
    install_ceilometer
fi


# Initialization
# ==============
echo_summary "Configuring OpenStack projects"

# Set up our checkouts so they are installed into python path
# allowing ``import nova`` or ``import glance.client``
configure_keystoneclient
configure_novaclient
setup_develop $OPENSTACKCLIENT_DIR
if is_service_enabled key g-api n-api swift; then
    configure_keystone
fi
if is_service_enabled swift; then
    setup_develop $SWIFT_DIR
    setup_develop $SWIFTCLIENT_DIR
fi
if is_service_enabled swift3; then
    setup_develop $SWIFT3_DIR
fi
if is_service_enabled g-api n-api; then
    configure_glance
fi

# Do this _after_ glance is installed to override the old binary
# TODO(dtroyer): figure out when this is no longer necessary
configure_glanceclient

if is_service_enabled nova; then
    configure_nova
fi
if is_service_enabled horizon; then
    setup_develop $HORIZON_DIR
fi
if is_service_enabled quantum; then
    setup_develop $QUANTUM_CLIENT_DIR
    setup_develop $QUANTUM_DIR
fi
if is_service_enabled heat; then
    configure_heat
fi
if is_service_enabled cinder; then
    configure_cinder
fi

if [[ $TRACK_DEPENDS = True ]] ; then
    $DEST/.venv/bin/pip freeze > $DEST/requires-post-pip
    if ! diff -Nru $DEST/requires-pre-pip $DEST/requires-post-pip > $DEST/requires.diff ; then
        cat $DEST/requires.diff
    fi
    echo "Ran stack.sh in depend tracking mode, bailing out now"
    exit 0
fi


# Syslog
# ------

if [[ $SYSLOG != "False" ]]; then
    if [[ "$SYSLOG_HOST" = "$HOST_IP" ]]; then
        # Configure the master host to receive
        cat <<EOF >/tmp/90-stack-m.conf
\$ModLoad imrelp
\$InputRELPServerRun $SYSLOG_PORT
EOF
        sudo mv /tmp/90-stack-m.conf /etc/rsyslog.d
    else
        # Set rsyslog to send to remote host
        cat <<EOF >/tmp/90-stack-s.conf
*.*		:omrelp:$SYSLOG_HOST:$SYSLOG_PORT
EOF
        sudo mv /tmp/90-stack-s.conf /etc/rsyslog.d
    fi
    echo_summary "Starting rsyslog"
    restart_service rsyslog
fi


# Finalize queue installation
# ----------------------------

if is_service_enabled rabbit; then
    # Start rabbitmq-server
    echo_summary "Starting RabbitMQ"
    if [[ "$os_PACKAGE" = "rpm" ]]; then
        # RPM doesn't start the service
        restart_service rabbitmq-server
    fi
    # change the rabbit password since the default is "guest"
    sudo rabbitmqctl change_password guest $RABBIT_PASSWORD
fi


# Mysql
# -----

if is_service_enabled mysql; then
    echo_summary "Configuring and starting MySQL"

    if [[ "$os_PACKAGE" = "deb" ]]; then
        MY_CONF=/etc/mysql/my.cnf
        MYSQL=mysql
    else
        MY_CONF=/etc/my.cnf
        MYSQL=mysqld
    fi

    # Start mysql-server
    if [[ "$os_PACKAGE" = "rpm" ]]; then
        # RPM doesn't start the service
        start_service $MYSQL
        # Set the root password - only works the first time
        sudo mysqladmin -u root password $MYSQL_PASSWORD || true
    fi
    # Update the DB to give user ‘$MYSQL_USER’@’%’ full control of the all databases:
    sudo mysql -uroot -p$MYSQL_PASSWORD -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' identified by '$MYSQL_PASSWORD';"

    # Now update ``my.cnf`` for some local needs and restart the mysql service

    # Change ‘bind-address’ from localhost (127.0.0.1) to any (0.0.0.0)
    sudo sed -i '/^bind-address/s/127.0.0.1/0.0.0.0/g' $MY_CONF

    # Set default db type to InnoDB
    if sudo grep -q "default-storage-engine" $MY_CONF; then
        # Change it
        sudo bash -c "source $TOP_DIR/functions; iniset $MY_CONF mysqld default-storage-engine InnoDB"
    else
        # Add it
        sudo sed -i -e "/^\[mysqld\]/ a \
default-storage-engine = InnoDB" $MY_CONF
    fi

    restart_service $MYSQL
fi

if [ -z "$SCREEN_HARDSTATUS" ]; then
    SCREEN_HARDSTATUS='%{= .} %-Lw%{= .}%> %n%f %t*%{= .}%+Lw%< %-=%{g}(%{d}%H/%l%{g})'
fi

# Create a new named screen to run processes in
screen -d -m -S $SCREEN_NAME -t shell -s /bin/bash
sleep 1
# Set a reasonable status bar
screen -r $SCREEN_NAME -X hardstatus alwayslastline "$SCREEN_HARDSTATUS"


# Keystone
# --------

if is_service_enabled key; then
    echo_summary "Starting Keystone"
    configure_keystone
    init_keystone
    start_keystone
    echo "Waiting for keystone to start..."
    if ! timeout $SERVICE_TIMEOUT sh -c "while ! http_proxy= curl -s $KEYSTONE_AUTH_PROTOCOL://$SERVICE_HOST:$KEYSTONE_API_PORT/v2.0/ >/dev/null; do sleep 1; done"; then
      echo "keystone did not start"
      exit 1
    fi

    # ``keystone_data.sh`` creates services, admin and demo users, and roles.
    SERVICE_ENDPOINT=$KEYSTONE_AUTH_PROTOCOL://$KEYSTONE_AUTH_HOST:$KEYSTONE_AUTH_PORT/v2.0

    ADMIN_PASSWORD=$ADMIN_PASSWORD SERVICE_TENANT_NAME=$SERVICE_TENANT_NAME SERVICE_PASSWORD=$SERVICE_PASSWORD \
    SERVICE_TOKEN=$SERVICE_TOKEN SERVICE_ENDPOINT=$SERVICE_ENDPOINT SERVICE_HOST=$SERVICE_HOST \
    S3_SERVICE_PORT=$S3_SERVICE_PORT KEYSTONE_CATALOG_BACKEND=$KEYSTONE_CATALOG_BACKEND \
    DEVSTACK_DIR=$TOP_DIR ENABLED_SERVICES=$ENABLED_SERVICES HEAT_API_CFN_PORT=$HEAT_API_CFN_PORT \
        bash -x $FILES/keystone_data.sh

    # Set up auth creds now that keystone is bootstrapped
    export OS_AUTH_URL=$SERVICE_ENDPOINT
    export OS_TENANT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=$ADMIN_PASSWORD
fi


# Horizon
# -------

# Set up the django horizon application to serve via apache/wsgi

if is_service_enabled horizon; then
    echo_summary "Configuring and starting Horizon"

    # Remove stale session database.
    rm -f $HORIZON_DIR/openstack_dashboard/local/dashboard_openstack.sqlite3

    # ``local_settings.py`` is used to override horizon default settings.
    local_settings=$HORIZON_DIR/openstack_dashboard/local/local_settings.py
    cp $FILES/horizon_settings.py $local_settings

    # Initialize the horizon database (it stores sessions and notices shown to
    # users).  The user system is external (keystone).
    cd $HORIZON_DIR
    python manage.py syncdb --noinput
    cd $TOP_DIR

    # Create an empty directory that apache uses as docroot
    sudo mkdir -p $HORIZON_DIR/.blackhole

    if [[ "$os_PACKAGE" = "deb" ]]; then
        APACHE_NAME=apache2
        APACHE_CONF=sites-available/horizon
        # Clean up the old config name
        sudo rm -f /etc/apache2/sites-enabled/000-default
        # Be a good citizen and use the distro tools here
        sudo touch /etc/$APACHE_NAME/$APACHE_CONF
        sudo a2ensite horizon
    else
        # Install httpd, which is NOPRIME'd
        APACHE_NAME=httpd
        APACHE_CONF=conf.d/horizon.conf
        sudo sed '/^Listen/s/^.*$/Listen 0.0.0.0:80/' -i /etc/httpd/conf/httpd.conf
    fi

    # Configure apache to run horizon
    sudo sh -c "sed -e \"
        s,%USER%,$APACHE_USER,g;
        s,%GROUP%,$APACHE_GROUP,g;
        s,%HORIZON_DIR%,$HORIZON_DIR,g;
        s,%APACHE_NAME%,$APACHE_NAME,g;
        s,%DEST%,$DEST,g;
    \" $FILES/apache-horizon.template >/etc/$APACHE_NAME/$APACHE_CONF"

    restart_service $APACHE_NAME
fi


# Glance
# ------

if is_service_enabled g-reg; then
    echo_summary "Configuring Glance"

    init_glance

    # Store the images in swift if enabled.
    #if is_service_enabled swift; then
        #iniset $GLANCE_API_CONF DEFAULT default_store swift
        #iniset $GLANCE_API_CONF DEFAULT swift_store_auth_address $KEYSTONE_SERVICE_PROTOCOL://$KEYSTONE_SERVICE_HOST:$KEYSTONE_SERVICE_PORT/v2.0/
        #iniset $GLANCE_API_CONF DEFAULT swift_store_user $SERVICE_TENANT_NAME:glance
        #iniset $GLANCE_API_CONF DEFAULT swift_store_key $SERVICE_PASSWORD
        #iniset $GLANCE_API_CONF DEFAULT swift_store_create_container_on_put True
    #fi
fi

# Nova
# ----
if is_service_enabled nova; then
    echo_summary "Configuring Nova"
    configure_nova
fi

if is_service_enabled n-net q-dhcp; then
    # Delete traces of nova networks from prior runs
    sudo killall dnsmasq || true
    clean_iptables
    rm -rf $NOVA_STATE_PATH/networks
    mkdir -p $NOVA_STATE_PATH/networks

    # Force IP forwarding on, just on case
    sudo sysctl -w net.ipv4.ip_forward=1
fi

# Storage Service
# ---------------
if is_service_enabled swift; then
    swift-init all stop || true

    USER_GROUP=$(id -g)
    sudo rm -r -f ${SWIFT_DATA_DIR}
    sudo mkdir -p ${SWIFT_DATA_DIR}
    sudo chown -R $USER:${USER_GROUP} ${SWIFT_DATA_DIR}
    mkdir -p  ${SWIFT_DATA_DIR}/node
    mkdir -p  ${SWIFT_DATA_DIR}/node/sdb1
    sudo chown -R $USER:${USER_GROUP} ${SWIFT_DATA_DIR}/node

    sudo rm -r -f ${SWIFT_CONFIG_DIR}/* /var/run/swift
    sudo mkdir -p ${SWIFT_CONFIG_DIR} /var/run/swift
    sudo chown -R $USER: ${SWIFT_CONFIG_DIR} /var/run/swift

    # Swift use rsync to synchronize between all the different
    # partitions (which make more sense when you have a multi-node
    # setup) we configure it with our version of rsync.
    sed -e "
        s/%GROUP%/${USER_GROUP}/;
        s/%USER%/$USER/;
        s/%IP%/$HOST_IP/;
        s,%SWIFT_DATA_DIR%,$SWIFT_DATA_DIR,;
    " $FILES/swift/rsyncd.conf | sudo tee /etc/rsyncd.conf
    sudo sed -i '/^RSYNC_ENABLE=false/ { s/false/true/ }' /etc/default/rsync

    if is_service_enabled swift3;then
        swift_auth_server="s3token "
    fi

    # By default Swift will be installed with the tempauth middleware
    # which has some default username and password if you have
    # configured keystone it will checkout the directory.
    if is_service_enabled key; then
        swift_auth_server+="authtoken keystoneauth"
    else
        swift_auth_server=tempauth
    fi

        SWIFT_CONFIG_PROXY_SERVER=${SWIFT_CONFIG_DIR}/proxy-server.conf
        cp ${SWIFT_DIR}/etc/proxy-server.conf-sample ${SWIFT_CONFIG_PROXY_SERVER}

        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT user
        iniset ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT user ${USER}

        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT swift_dir
        iniset ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT swift_dir ${SWIFT_CONFIG_DIR}

        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT workers
        iniset ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT workers 1

	iniuncomment ${swift_node_config} DEFAULT log_facility
        iniset ${swift_node_config} DEFAULT log_facility LOG_LOCAL1

        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT log_level
        iniset ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT log_level DEBUG

        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT bind_port
        iniset ${SWIFT_CONFIG_PROXY_SERVER} DEFAULT bind_port ${SWIFT_DEFAULT_BIND_PORT:-8080}
    
        # Only enable Swift3 if we have it enabled in ENABLED_SERVICES
        is_service_enabled swift3 && swift3=swift3 || swift3=""
    
        iniset ${SWIFT_CONFIG_PROXY_SERVER} pipeline:main pipeline "catch_errors healthcheck cache ratelimit ${swift3} ${swift_auth_server} proxy-logging proxy-server"
    
        iniset ${SWIFT_CONFIG_PROXY_SERVER} app:proxy-server account_autocreate true
    
        # Configure Keystone
        sed -i '/^# \[filter:authtoken\]/,/^# \[filter:keystoneauth\]$/ s/^#[ \t]*//' ${SWIFT_CONFIG_PROXY_SERVER}
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken auth_host $KEYSTONE_AUTH_HOST
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken auth_port $KEYSTONE_AUTH_PORT
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken auth_protocol $KEYSTONE_AUTH_PROTOCOL
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken auth_uri $KEYSTONE_SERVICE_PROTOCOL://$KEYSTONE_SERVICE_HOST:$KEYSTONE_SERVICE_PORT/
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken admin_tenant_name $SERVICE_TENANT_NAME
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken admin_user swift
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken admin_password $SERVICE_PASSWORD
    
        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} filter:keystoneauth use
        iniuncomment ${SWIFT_CONFIG_PROXY_SERVER} filter:keystoneauth operator_roles
        iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:keystoneauth operator_roles "Member, admin"

    if is_service_enabled swift3;then
        cat <<EOF >>${SWIFT_CONFIG_PROXY_SERVER}
# NOTE(chmou): s3token middleware is not updated yet to use only
# username and password.
[filter:s3token]
paste.filter_factory = keystone.middleware.s3_token:filter_factory
auth_port = ${KEYSTONE_AUTH_PORT}
auth_host = ${KEYSTONE_AUTH_HOST}
auth_protocol = ${KEYSTONE_AUTH_PROTOCOL}
auth_token = ${SERVICE_TOKEN}
admin_token = ${SERVICE_TOKEN}

[filter:swift3]
use = egg:swift3#swift3
EOF
    fi

    cp ${SWIFT_DIR}/etc/swift.conf-sample ${SWIFT_CONFIG_DIR}/swift.conf
    iniset ${SWIFT_CONFIG_DIR}/swift.conf swift-hash swift_hash_path_suffix ${SWIFT_HASH}

    # This function generates an object/account/proxy configuration
    # emulating 4 nodes on different ports
    function generate_swift_configuration() {
        local server_type=$1
        local bind_port=$2
        local log_facility=$3
        local swift_node_config

        node_path=${SWIFT_DATA_DIR}/node
        swift_node_config=${SWIFT_CONFIG_DIR}/${server_type}-server.conf

        cp ${SWIFT_DIR}/etc/${server_type}-server.conf-sample ${swift_node_config}

        iniuncomment ${swift_node_config} DEFAULT user
        iniset ${swift_node_config} DEFAULT user ${USER}

        iniuncomment ${swift_node_config} DEFAULT bind_port
        iniset ${swift_node_config} DEFAULT bind_port ${bind_port}

        iniuncomment ${swift_node_config} DEFAULT swift_dir
        iniset ${swift_node_config} DEFAULT swift_dir ${SWIFT_CONFIG_DIR}

        iniuncomment ${swift_node_config} DEFAULT devices
        iniset ${swift_node_config} DEFAULT devices ${node_path}

        iniuncomment ${swift_node_config} DEFAULT log_facility
        iniset ${swift_node_config} DEFAULT log_facility LOG_LOCAL${log_facility}

        iniuncomment ${swift_node_config} DEFAULT mount_check
        iniset ${swift_node_config} DEFAULT mount_check false

        iniuncomment ${swift_node_config} ${server_type}-replicator vm_test_mode
        iniset ${swift_node_config} ${server_type}-replicator vm_test_mode yes
    }

    generate_swift_configuration object 6010 2
    generate_swift_configuration container 6011 3
    generate_swift_configuration account 6012 4

    # Specific configuration for swift for rsyslog. See
    # ``/etc/rsyslog.d/10-swift.conf`` for more info.
    swift_log_dir=${SWIFT_DATA_DIR}/logs
    rm -rf ${swift_log_dir}
    sudo mkdir -p ${swift_log_dir}
    sudo chown -R $USER:adm ${swift_log_dir}
    sed "s,%SWIFT_LOGDIR%,${swift_log_dir}," $FILES/swift/rsyslog.conf | sudo tee /etc/rsyslog.d/10-swift.conf
    restart_service rsyslog

    # This is where we create three different rings for swift with
    # different object servers binding on different ports.
    SWIFT_REPLICAS=${SWIFT_REPLICAS:-1}
    pushd ${SWIFT_CONFIG_DIR} >/dev/null && {
        rm -f *.builder *.ring.gz backups/*.builder backups/*.ring.gz

        port_number=6010
        swift-ring-builder object.builder create ${SWIFT_PARTITION_POWER_SIZE} ${SWIFT_REPLICAS} 1
        swift-ring-builder object.builder add z1-${HOST_IP}:${port_number}/sdb1 1
        swift-ring-builder object.builder rebalance

        port_number=6011
        swift-ring-builder container.builder create ${SWIFT_PARTITION_POWER_SIZE} ${SWIFT_REPLICAS} 1
        swift-ring-builder container.builder add z1-${HOST_IP}:${port_number}/sdb1 1
        swift-ring-builder container.builder rebalance

        port_number=6012
        swift-ring-builder account.builder create ${SWIFT_PARTITION_POWER_SIZE} ${SWIFT_REPLICAS} 1
        swift-ring-builder account.builder add z1-${HOST_IP}:${port_number}/sdb1 1
        swift-ring-builder account.builder rebalance

    } && popd >/dev/null

   # Start rsync
   sudo /etc/init.d/rsync restart || :
   swift-init all restart || true
   #swift-init proxy stop || true
   unset s swift_hash swift_auth_server
fi


# Volume Service
# --------------

if is_service_enabled cinder; then
    echo_summary "Configuring Cinder"
    init_cinder
elif is_service_enabled n-vol; then
    echo_summary "Configuring Nova volumes"
    init_nvol
fi

if is_service_enabled nova; then
    echo_summary "Configuring Nova"
    init_nova
fi

# Additional Nova configuration that is dependent on other services
add_nova_opt "network_manager=nova.network.manager.$NET_MAN"
add_nova_opt "public_interface=$PUBLIC_INTERFACE"
add_nova_opt "vlan_interface=$VLAN_INTERFACE"
add_nova_opt "flat_network_bridge=$FLAT_NETWORK_BRIDGE"
if [ -n "$FLAT_INTERFACE" ]; then
    add_nova_opt "flat_interface=$FLAT_INTERFACE"
fi
# All nova-compute workers need to know the vnc configuration options
# These settings don't hurt anything if n-xvnc and n-novnc are disabled
if is_service_enabled n-cpu; then
    if [ "$CALLER"x = "compute"x ];then
        NOVNCPROXY_URL=${NOVNCPROXY_URL:-"http://$CONTROLLER_ADDRESS:6080/vnc_auto.html"}
        add_nova_opt "novncproxy_base_url=$NOVNCPROXY_URL"
        XVPVNCPROXY_URL=${XVPVNCPROXY_URL:-"http://$CONTROLLER_ADDRESS:6081/console"}
        add_nova_opt "xvpvncproxy_base_url=$XVPVNCPROXY_URL"
    else
        NOVNCPROXY_URL=${NOVNCPROXY_URL:-"http://$SERVICE_HOST:6080/vnc_auto.html"}
        add_nova_opt "novncproxy_base_url=$NOVNCPROXY_URL"
        XVPVNCPROXY_URL=${XVPVNCPROXY_URL:-"http://$SERVICE_HOST:6081/console"}
        add_nova_opt "xvpvncproxy_base_url=$XVPVNCPROXY_URL"
    fi
fi
if [ "$VIRT_DRIVER" = 'xenserver' ]; then
    VNCSERVER_PROXYCLIENT_ADDRESS=${VNCSERVER_PROXYCLIENT_ADDRESS=169.254.0.1}
else
    #VNCSERVER_PROXYCLIENT_ADDRESS=${VNCSERVER_PROXYCLIENT_ADDRESS=127.0.0.1}
    VNCSERVER_PROXYCLIENT_ADDRESS=$SERVICE_HOST
fi
# Address on which instance vncservers will listen on compute hosts.
# For multi-host, this should be the management ip of the compute host.
VNCSERVER_LISTEN=${VNCSERVER_LISTEN=127.0.0.1}
add_nova_opt "vncserver_listen=0.0.0.0"
add_nova_opt "vncserver_proxyclient_address=$VNCSERVER_PROXYCLIENT_ADDRESS"
add_nova_opt "ec2_dmz_host=$EC2_DMZ_HOST"
if [ -n "$RABBIT_HOST" ] &&  [ -n "$RABBIT_PASSWORD" ]; then
    add_nova_opt "rabbit_host=$RABBIT_HOST"
    add_nova_opt "rabbit_password=$RABBIT_PASSWORD"
fi
add_nova_opt "glance_api_servers=$GLANCE_HOSTPORT"

echo_summary "Using libvirt virtualization driver"
add_nova_opt "compute_driver=libvirt.LibvirtDriver"
LIBVIRT_FIREWALL_DRIVER=${LIBVIRT_FIREWALL_DRIVER:-"nova.virt.libvirt.firewall.IptablesFirewallDriver"}
add_nova_opt "firewall_driver=$LIBVIRT_FIREWALL_DRIVER"


# Heat
# ----
if is_service_enabled heat; then
    echo_summary "Configuring Heat"
    init_heat
fi


# Launch Services
# ===============

# Only run the services specified in ``ENABLED_SERVICES``

# Launch the Glance services
if is_service_enabled g-api g-reg; then
    echo_summary "Starting Glance"
    start_glance
fi

# Create an access key and secret key for nova ec2 register image
if is_service_enabled key && is_service_enabled swift3 && is_service_enabled nova; then
    NOVA_USER_ID=$(keystone user-list | grep ' nova ' | get_field 1)
    NOVA_TENANT_ID=$(keystone tenant-list | grep " $SERVICE_TENANT_NAME " | get_field 1)
    CREDS=$(keystone ec2-credentials-create --user_id $NOVA_USER_ID --tenant_id $NOVA_TENANT_ID)
    ACCESS_KEY=$(echo "$CREDS" | awk '/ access / { print $4 }')
    SECRET_KEY=$(echo "$CREDS" | awk '/ secret / { print $4 }')
    add_nova_opt "s3_access_key=$ACCESS_KEY"
    add_nova_opt "s3_secret_key=$SECRET_KEY"
    add_nova_opt "s3_affix_tenant=True"
fi

screen_it zeromq "cd $NOVA_DIR && $NOVA_DIR/bin/nova-rpc-zmq-receiver"

# Launch the nova-api and wait for it to answer before continuing
if is_service_enabled n-api; then
    echo_summary "Starting Nova API"
    screen_it n-api "cd $NOVA_DIR && $NOVA_BIN_DIR/nova-api"
    echo "Waiting for nova-api to start..."
    if ! timeout $SERVICE_TIMEOUT sh -c "while ! http_proxy= wget -q -O- http://127.0.0.1:8774; do sleep 1; done"; then
      echo "nova-api did not start"
      exit 1
    fi
fi

if is_service_enabled mysql && is_service_enabled nova; then
    # Create a small network
    $NOVA_BIN_DIR/nova-manage network create private $FIXED_RANGE 1 $FIXED_NETWORK_SIZE $NETWORK_CREATE_ARGS

    # Create some floating ips
    $NOVA_BIN_DIR/nova-manage floating create $FLOATING_RANGE

    # Create a second pool
    $NOVA_BIN_DIR/nova-manage floating create --ip_range=$TEST_FLOATING_RANGE --pool=$TEST_FLOATING_POOL
fi

if is_service_enabled nova; then
    echo_summary "Starting Nova"
    start_nova
fi
if is_service_enabled n-vol; then
    echo_summary "Starting Nova volumes"
    start_nvol
fi
if is_service_enabled cinder; then
    echo_summary "Starting Cinder"
    start_cinder
fi
if is_service_enabled ceilometer; then
    echo_summary "Configuring Ceilometer"
    configure_ceilometer
    echo_summary "Starting Ceilometer"
    start_ceilometer
fi
screen_it horizon "cd $HORIZON_DIR && sudo tail -f /var/log/$APACHE_NAME/horizon_error.log"
#screen_it swift "cd $SWIFT_DIR && $SWIFT_DIR/bin/swift-proxy-server ${SWIFT_CONFIG_DIR}/proxy-server.conf -v"

# Starting the nova-objectstore only if swift3 service is not enabled.
# Swift will act as s3 objectstore.
is_service_enabled swift3 || \
    screen_it n-obj "cd $NOVA_DIR && $NOVA_BIN_DIR/nova-objectstore"

# launch heat engine, api and metadata
if is_service_enabled heat; then
    echo_summary "Starting Heat"
    start_heat
fi


# Install Images
# ==============
if is_service_enabled g-reg; then
    echo_summary "Uploading images"
    TOKEN=$(keystone  token-get | grep ' id ' | get_field 2)

    for image_url in ${IMAGE_URLS//,/ }; do
        upload_image $image_url $TOKEN
    done
fi


# Fin
# ===

set +o xtrace

if [[ -n "$LOGFILE" ]]; then
    exec 1>&3
    # Force all output to stdout and logs now
    exec 1> >( tee -a "${LOGFILE}" ) 2>&1
else
    # Force all output to stdout now
    exec 1>&3
fi


# Using the cloud
# ---------------

echo -e "\n\n"

if is_service_enabled horizon; then
    echo "Openstack is now available at http://$SERVICE_HOST/"
fi

# If Keystone is present you can point ``nova`` cli to this server
if is_service_enabled key; then
    echo "The default users are: admin and test"
    echo "The password: $ADMIN_PASSWORD" and "test"
fi

# Warn that ``EXTRA_FLAGS`` needs to be converted to ``EXTRA_OPTS``
if [[ -n "$EXTRA_FLAGS" ]]; then
    echo_summary "WARNING: EXTRA_FLAGS is defined and may need to be converted to EXTRA_OPTS"
fi

# Indicate how long this took to run (bash maintained variable ``SECONDS``)
echo_summary "stack.sh completed in $SECONDS seconds."
