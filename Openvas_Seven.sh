#!/bin/bash
#Author: SaySeven && Corvo

if [ $USER != root ]; then
  echo -e " .d88b. "                                  
  echo -e " 8P  Y8 88b. .d88b 8d8b. Yb  dP .d88 d88b "
  echo -e " 8b  d8 8  8 8.dP' 8P Y8  YbdP  8  8  Yb. "
  echo -e "  Y88P  88P  Y88P 8   8   YP    Y88 Y88P "
  echo -e "        8   "                              
  echo -e " .d88b.  "                                 
  echo -e " YPwww. .d88b Yb  dP .d88b 8d8b.  "        
  echo -e "     d8 8.dP'  YbdP  8.dP' 8P Y8   "       
  echo -e "  Y88P   Y88P   YP    Y88P 8   8  "
  echo -e "                   by:SaySeven"
	echo "            Voce precisa ser root"
	exit
fi

echo -e " .d88b. "                                  
echo -e " 8P  Y8 88b. .d88b 8d8b. Yb  dP .d88 d88b "
echo -e " 8b  d8 8  8 8.dP' 8P Y8  YbdP  8  8  Yb. "
echo -e "  Y88P  88P  Y88P 8   8   YP    Y88 Y88P "
echo -e "        8   "                              
echo -e " .d88b.  "                                 
echo -e " YPwww. .d88b Yb  dP .d88b 8d8b.  "        
echo -e "     d8 8.dP'  YbdP  8.dP' 8P Y8   "       
echo -e "  Y88P   Y88P   YP    Y88P 8   8  "
echo -e "                   by:SaySeven"

apt update && apt upgrade -y

#Creating a gvm system user and group
sudo useradd -r -M -U -G sudo -s /usr/sbin/nologin gvm

#Add current user to gvm group
sudo usermod -aG gvm $USER
su $USER

#Setting an install prefix environment variable
export INSTALL_PREFIX=/usr/local

#Adjusting PATH for running gvmd
export PATH=$PATH:$INSTALL_PREFIX/sbin

#Choosing a source directory
export SOURCE_DIR=$HOME/source
mkdir -p $SOURCE_DIR

#Choosing a build directory
export BUILD_DIR=$HOME/build
mkdir -p $BUILD_DIR

#Choosing a temporary install directory
export INSTALL_DIR=$HOME/install
mkdir -p $INSTALL_DIR

#Installing common build dependencies
sudo apt update
sudo apt install --no-install-recommends --assume-yes \
  build-essential \
  curl \
  cmake \
  pkg-config \
  python3 \
  python3-pip \
  gnupg

#Importing the Greenbone Community Signing key
curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc
gpg --import /tmp/GBCommunitySigningKey.asc

#Setting the trust level for the Greenbone Community Signing key
echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" | gpg --import-ownertrust

#Setting the gvm-libs version to use
export GVM_LIBS_VERSION=22.7.3

#Required dependencies for gvm-libs
sudo apt install -y \
  libglib2.0-dev \
  libgpgme-dev \
  libgnutls28-dev \
  uuid-dev \
  libssh-gcrypt-dev \
  libhiredis-dev \
  libxml2-dev \
  libpcap-dev \
  libnet1-dev \
  libpaho-mqtt-dev

#Optional dependencies for gvm-libs
sudo apt install -y \
  libldap2-dev \
  libradcli-dev

#Downloading the gvm-libs sources
curl -f -L https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVM_LIBS_VERSION.tar.gz -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gvm-libs/releases/download/v$GVM_LIBS_VERSION/gvm-libs-v$GVM_LIBS_VERSION.tar.gz.asc -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source file
gpg --verify $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz

#Building gvm-libs
mkdir -p $BUILD_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs
cmake $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var

make -j$(nproc)

#Installing gvm-libs
mkdir -p $INSTALL_DIR/gvm-libs
make DESTDIR=$INSTALL_DIR/gvm-libs install
sudo cp -rv $INSTALL_DIR/gvm-libs/* /

#Setting the gvmd version to use
export GVMD_VERSION=23.0.1

#Required dependencies for gvmd
sudo apt install -y \
  libglib2.0-dev \
  libgnutls28-dev \
  libpq-dev \
  postgresql-server-dev-14 \
  libical-dev \
  xsltproc \
  rsync \
  libbsd-dev \
  libgpgme-dev

#Optional dependencies for gvmd
sudo apt install -y --no-install-recommends \
  texlive-latex-extra \
  texlive-fonts-recommended \
  xmlstarlet \
  zip \
  rpm \
  fakeroot \
  dpkg \
  nsis \
  gnupg \
  gpgsm \
  wget \
  sshpass \
  openssh-client \
  socat \
  snmp \
  python3 \
  smbclient \
  python3-lxml \
  gnutls-bin \
  xml-twig-tools

#Downloading the gvmd sources
curl -f -L https://github.com/greenbone/gvmd/archive/refs/tags/v$GVMD_VERSION.tar.gz -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gvmd/releases/download/v$GVMD_VERSION/gvmd-$GVMD_VERSION.tar.gz.asc -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source file
gpg --verify $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz

#Building gvmd
mkdir -p $BUILD_DIR/gvmd && cd $BUILD_DIR/gvmd
cmake $SOURCE_DIR/gvmd-$GVMD_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLOCALSTATEDIR=/var \
  -DSYSCONFDIR=/etc \
  -DGVM_DATA_DIR=/var \
  -DGVMD_RUN_DIR=/run/gvmd \
  -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
  -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
  -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
  -DLOGROTATE_DIR=/etc/logrotate.d

make -j$(nproc)

#Installing gvmd
mkdir -p $INSTALL_DIR/gvmd
make DESTDIR=$INSTALL_DIR/gvmd install
sudo cp -rv $INSTALL_DIR/gvmd/* /

#Setting the pg-gvm version to use
export PG_GVM_VERSION=22.6.1

#Required dependencies for pg-gvm
sudo apt install -y \
  libglib2.0-dev \
  postgresql-server-dev-14 \
  libical-dev

#Downloading the pg-gvm sources
curl -f -L https://github.com/greenbone/pg-gvm/archive/refs/tags/v$PG_GVM_VERSION.tar.gz -o $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz
curl -f -L https://github.com/greenbone/pg-gvm/releases/download/v$PG_GVM_VERSION/pg-gvm-$PG_GVM_VERSION.tar.gz.asc -o $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source file
gpg --verify $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz.asc $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION.tar.gz

#Building pg-gvm
mkdir -p $BUILD_DIR/pg-gvm && cd $BUILD_DIR/pg-gvm
cmake $SOURCE_DIR/pg-gvm-$PG_GVM_VERSION \
  -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)

#Installing pg-gvm
mkdir -p $INSTALL_DIR/pg-gvm
make DESTDIR=$INSTALL_DIR/pg-gvm install
sudo cp -rv $INSTALL_DIR/pg-gvm/* /

#Setting the GSA version to use
export GSA_VERSION=22.8.0

#Downloading the gsa sources
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-dist-$GSA_VERSION.tar.gz -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-dist-$GSA_VERSION.tar.gz.asc -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source files
gpg --verify $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz
mkdir -p $SOURCE_DIR/gsa-$GSA_VERSION
tar -C $SOURCE_DIR/gsa-$GSA_VERSION -xvzf $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz

#Installing gsa
sudo mkdir -p $INSTALL_PREFIX/share/gvm/gsad/web/
sudo cp -rv $SOURCE_DIR/gsa-$GSA_VERSION/* $INSTALL_PREFIX/share/gvm/gsad/web/

#Setting the GSAd version to use
export GSAD_VERSION=22.7.0

#Required dependencies for gsad
sudo apt install -y \
  libmicrohttpd-dev \
  libxml2-dev \
  libglib2.0-dev \
  libgnutls28-dev

#Downloading the gsad sources
curl -f -L https://github.com/greenbone/gsad/archive/refs/tags/v$GSAD_VERSION.tar.gz -o $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz
curl -f -L https://github.com/greenbone/gsad/releases/download/v$GSAD_VERSION/gsad-$GSAD_VERSION.tar.gz.asc -o $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source files
gpg --verify $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz.asc $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gsad-$GSAD_VERSION.tar.gz

#Building gsad
mkdir -p $BUILD_DIR/gsad && cd $BUILD_DIR/gsad
cmake $SOURCE_DIR/gsad-$GSAD_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DGVMD_RUN_DIR=/run/gvmd \
  -DGSAD_RUN_DIR=/run/gsad \
  -DLOGROTATE_DIR=/etc/logrotate.d

make -j$(nproc)

#Installing gsad
mkdir -p $INSTALL_DIR/gsad
make DESTDIR=$INSTALL_DIR/gsad install
sudo cp -rv $INSTALL_DIR/gsad/* /

#Setting the openvas-smb version to use
export OPENVAS_SMB_VERSION=22.5.3

#Required dependencies for openvas-smb
sudo apt install -y \
  gcc-mingw-w64 \
  libgnutls28-dev \
  libglib2.0-dev \
  libpopt-dev \
  libunistring-dev \
  heimdal-dev \
  perl-base

#Downloading the openvas-smb sources
curl -f -L https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVAS_SMB_VERSION.tar.gz -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz
curl -f -L https://github.com/greenbone/openvas-smb/releases/download/v$OPENVAS_SMB_VERSION/openvas-smb-v$OPENVAS_SMB_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source file
gpg --verify $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz

#Building openvas-smb
mkdir -p $BUILD_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb
cmake $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)

#Installing openvas-smb
mkdir -p $INSTALL_DIR/openvas-smb
make DESTDIR=$INSTALL_DIR/openvas-smb install
sudo cp -rv $INSTALL_DIR/openvas-smb/* /

#sudo cp -rv $INSTALL_DIR/openvas-smb/* /
export OPENVAS_SCANNER_VERSION=22.7.6

#Required dependencies for openvas-scanner
sudo apt install -y \
  bison \
  libglib2.0-dev \
  libgnutls28-dev \
  libgcrypt20-dev \
  libpcap-dev \
  libgpgme-dev \
  libksba-dev \
  rsync \
  nmap \
  libjson-glib-dev \
  libbsd-dev

#Debian optional dependencies for openvas-scanner
sudo apt install -y \
  python3-impacket \
  libsnmp-dev

#Downloading the openvas-scanner sources
curl -f -L https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS_SCANNER_VERSION.tar.gz -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz
curl -f -L https://github.com/greenbone/openvas-scanner/releases/download/v$OPENVAS_SCANNER_VERSION/openvas-scanner-v$OPENVAS_SCANNER_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source file
gpg --verify $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz

#Building openvas-scanner
mkdir -p $BUILD_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner
cmake $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DINSTALL_OLD_SYNC_SCRIPT=OFF \
  -DSYSCONFDIR=/etc \
  -DLOCALSTATEDIR=/var \
  -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
  -DOPENVAS_RUN_DIR=/run/ospd

make -j$(nproc)

#Installing openvas-scanner
mkdir -p $INSTALL_DIR/openvas-scanner
make DESTDIR=$INSTALL_DIR/openvas-scanner install
sudo cp -rv $INSTALL_DIR/openvas-scanner/* /

#Setting the ospd and ospd-openvas versions to use
export OSPD_OPENVAS_VERSION=22.6.1

#Required dependencies for ospd-openvas
sudo apt install -y \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-packaging \
  python3-wrapt \
  python3-cffi \
  python3-psutil \
  python3-lxml \
  python3-defusedxml \
  python3-paramiko \
  python3-redis \
  python3-gnupg \
  python3-paho-mqtt

#Downloading the ospd-openvas sources
curl -f -L https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPD_OPENVAS_VERSION.tar.gz -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz
curl -f -L https://github.com/greenbone/ospd-openvas/releases/download/v$OSPD_OPENVAS_VERSION/ospd-openvas-v$OSPD_OPENVAS_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source files
gpg --verify $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz

#Installing ospd-openvas
cd $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION
mkdir -p $INSTALL_DIR/ospd-openvas
python3 -m pip install --root=$INSTALL_DIR/ospd-openvas --no-warn-script-location .
sudo cp -rv $INSTALL_DIR/ospd-openvas/* /

#Setting the notus version to use
export NOTUS_VERSION=22.6.0

#Required dependencies for notus-scanner
sudo apt install -y \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-paho-mqtt \
  python3-psutil \
  python3-gnupg

#Downloading the notus-scanner sources
curl -f -L https://github.com/greenbone/notus-scanner/archive/refs/tags/v$NOTUS_VERSION.tar.gz -o $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz
curl -f -L https://github.com/greenbone/notus-scanner/releases/download/v$NOTUS_VERSION/notus-scanner-v$NOTUS_VERSION.tar.gz.asc -o $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz.asc

#variables
export INSTALL_PREFIX=/usr/local
export PATH=$PATH:$INSTALL_PREFIX/sbin
export SOURCE_DIR=$HOME/source
export BUILD_DIR=$HOME/build
export INSTALL_DIR=$HOME/install

#Verifying the source files
gpg --verify $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz.asc $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz
tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/notus-scanner-$NOTUS_VERSION.tar.gz

#Installing notus-scanner
cd $SOURCE_DIR/notus-scanner-$NOTUS_VERSION
mkdir -p $INSTALL_DIR/notus-scanner
python3 -m pip install --root=$INSTALL_DIR/notus-scanner --no-warn-script-location .
sudo cp -rv $INSTALL_DIR/notus-scanner/* /

#Required dependencies for greenbone-feed-sync
sudo apt install -y \
  python3 \
  python3-pip

#Installing greenbone-feed-sync system-wide for all users
mkdir -p $INSTALL_DIR/greenbone-feed-sync
python3 -m pip install --root=$INSTALL_DIR/greenbone-feed-sync --no-warn-script-location greenbone-feed-sync
sudo cp -rv $INSTALL_DIR/greenbone-feed-sync/* /

#Required dependencies for gvm-tools
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-setuptools \
  python3-packaging \
  python3-lxml \
  python3-defusedxml \
  python3-paramiko

#Installing gvm-tools system-wide
mkdir -p $INSTALL_DIR/gvm-tools
python3 -m pip install --root=$INSTALL_DIR/gvm-tools --no-warn-script-location gvm-tools
sudo cp -rv $INSTALL_DIR/gvm-tools/* /

#Installing the Redis server
sudo apt install -y redis-server

#Adding configuration for running the Redis server for the scanner
sudo cp $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION/config/redis-openvas.conf /etc/redis/
sudo chown redis:redis /etc/redis/redis-openvas.conf
echo "db_address = /run/redis-openvas/redis.sock" | sudo tee -a /etc/openvas/openvas.conf

#Start redis with openvas config
sudo systemctl start redis-server@openvas.service

#Ensure redis with openvas config is started on every system startup
sudo systemctl enable redis-server@openvas.service

#Adding the gvm user to the redis group
sudo usermod -aG redis gvm

#Installing the Mosquitto broker
sudo apt install -y mosquitto

#Starting the broker and adding the server uri to the openvas-scanner configuration
sudo systemctl start mosquitto.service
sudo systemctl enable mosquitto.service
echo -e "mqtt_server_uri = localhost:1883\ntable_driven_lsc = yes" | sudo tee -a /etc/openvas/openvas.conf

#Adjusting directory permissions
sudo mkdir -p /var/lib/notus
sudo mkdir -p /run/gvmd
sudo chown -R gvm:gvm /var/lib/gvm
sudo chown -R gvm:gvm /var/lib/openvas
sudo chown -R gvm:gvm /var/lib/notus
sudo chown -R gvm:gvm /var/log/gvm
sudo chown -R gvm:gvm /run/gvmd
sudo chmod -R g+srw /var/lib/gvm
sudo chmod -R g+srw /var/lib/openvas
sudo chmod -R g+srw /var/log/gvm

sleep 5

#Adjusting gvmd permissions
sudo chown gvm:gvm /usr/local/sbin/gvmd
sudo chmod 6750 /usr/local/sbin/gvmd

#Creating a GPG keyring for feed content validation
curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc
export GNUPGHOME=/tmp/openvas-gnupg
mkdir -p $GNUPGHOME
gpg --import /tmp/GBCommunitySigningKey.asc
echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" | gpg --import-ownertrust
export OPENVAS_GNUPG_HOME=/etc/openvas/gnupg
sudo mkdir -p $OPENVAS_GNUPG_HOME
sudo cp -r /tmp/openvas-gnupg/* $OPENVAS_GNUPG_HOME/
sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME

# allow users of the gvm group run openvas
echo -n "%gvm ALL = NOPASSWD: /usr/local/sbin/openvas" >> /etc/sudoers

sleep 5

#Installing the PostgreSQL server
sudo apt install -y postgresql

#Starting the PostgreSQL database server
sudo systemctl start postgresql@14-main

#Changing to the postgres user
#Setting up database permissions and extensions
cd /var/lib/postgresql
#sudo -u postgres createuser -DRS gvm
#sudo -u postgres createdb -O gvm gvmd
#sudo -u postgres psql gvmd -c "create role dba with superuser noinherit; grant dba to gvm"

sudo -u postgres createuser -DRS gvm && sudo -u postgres createdb -O gvm gvmd && sudo -u postgres psql gvmd -c "create role dba with superuser noinherit; grant dba to gvm"

sleep 5

#Creating an administrator user with generated password
/usr/local/sbin/gvmd --create-user=admin

#Creating an administrator user with provided password
/usr/local/sbin/gvmd --create-user=admin --password=admin

#Setting the Feed Import Owner
#/usr/local/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value `/usr/local/sbin/gvmd --get-users --verbose | grep admin | awk '{print $2}'`
/usr/local/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value "/usr/local/sbin/gvmd --get-users --verbose | grep admin | awk '{print $2}'"


#Systemd service file for ospd-openvas
echo "[Unit]" > /root/build/ospd-openvas.service
echo "Description=OSPd Wrapper for the OpenVAS Scanner (ospd-openvas)" >> /root/build/ospd-openvas.service
echo "Documentation=man:ospd-openvas(8) man:openvas(8)" >> /root/build/ospd-openvas.service
echo "After=network.target networking.service redis-server@openvas.service mosquitto.service" >> /root/build/ospd-openvas.service
echo "Wants=redis-server@openvas.service mosquitto.service notus-scanner.service" >> /root/build/ospd-openvas.service
echo "ConditionKernelCommandLine=!recovery" >> /root/build/ospd-openvas.service
echo "" >> /root/build/ospd-openvas.service
echo "[Service]" >> /root/build/ospd-openvas.service
echo "Type=exec" >> /root/build/ospd-openvas.service
echo "User=gvm" >> /root/build/ospd-openvas.service
echo "Group=gvm" >> /root/build/ospd-openvas.service
echo "RuntimeDirectory=ospd" >> /root/build/ospd-openvas.service
echo "RuntimeDirectoryMode=2775" >> /root/build/ospd-openvas.service
echo "PIDFile=/run/ospd/ospd-openvas.pid" >> /root/build/ospd-openvas.service
echo "ExecStart=/usr/local/bin/ospd-openvas --foreground --unix-socket /run/ospd/ospd-openvas.sock --pid-file /run/ospd/ospd-openvas.pid --log-file /var/log/gvm/ospd-openvas.log --lock-file-dir /var/lib/openvas --socket-mode 0o770 --mqtt-broker-address localhost --mqtt-broker-port 1883 --notus-feed-dir /var/lib/notus/advisories" >> /root/build/ospd-openvas.service
echo "SuccessExitStatus=SIGKILL" >> /root/build/ospd-openvas.service
echo "Restart=always" >> /root/build/ospd-openvas.service
echo "RestartSec=60" >> /root/build/ospd-openvas.service
echo "" >> /root/build/ospd-openvas.service
echo "[Install]" >> /root/build/ospd-openvas.service
echo "WantedBy=multi-user.target" >> /root/build/ospd-openvas.service

#Install systemd service file for ospd-openvas
sudo cp -v /root/build/ospd-openvas.service /etc/systemd/system/

#Systemd service file for notus-scanner
echo "[Unit]" > /root/build/notus-scanner.service
echo "Description=Notus Scanner" >> /root/build/notus-scanner.service
echo "Documentation=https://github.com/greenbone/notus-scanner" >> /root/build/notus-scanner.service
echo "After=mosquitto.service" >> /root/build/notus-scanner.service
echo "Wants=mosquitto.service" >> /root/build/notus-scanner.service
echo "ConditionKernelCommandLine=!recovery" >> /root/build/notus-scanner.service
echo "" >> /root/build/notus-scanner.service
echo "[Service]" >> /root/build/notus-scanner.service
echo "Type=exec" >> /root/build/notus-scanner.service
echo "User=gvm" >> /root/build/notus-scanner.service
echo "RuntimeDirectory=notus-scanner" >> /root/build/notus-scanner.service
echo "RuntimeDirectoryMode=2775" >> /root/build/notus-scanner.service
echo "PIDFile=/run/notus-scanner/notus-scanner.pid" >> /root/build/notus-scanner.service
echo "ExecStart=/usr/local/bin/notus-scanner --foreground --products-directory /var/lib/notus/products --log-file /var/log/gvm/notus-scanner.log" >> /root/build/notus-scanner.service
echo "SuccessExitStatus=SIGKILL" >> /root/build/notus-scanner.service
echo "Restart=always" >> /root/build/notus-scanner.service
echo "RestartSec=60" >> /root/build/notus-scanner.service
echo "" >> /root/build/notus-scanner.service
echo "[Install]" >> /root/build/notus-scanner.service
echo "WantedBy=multi-user.target" >> /root/build/notus-scanner.service

#Install systemd service file for notus-scanner
sudo cp -v /root/build/notus-scanner.service /etc/systemd/system/

#Systemd service file for gvmd
echo "[Unit]" > /root/build/gvmd.service
echo "Description=Greenbone Vulnerability Manager daemon (gvmd)" >> /root/build/gvmd.service
echo "After=network.target networking.service postgresql.service ospd-openvas.service" >> /root/build/gvmd.service
echo "Wants=postgresql.service ospd-openvas.service" >> /root/build/gvmd.service
echo "Documentation=man:gvmd(8)" >> /root/build/gvmd.service
echo "ConditionKernelCommandLine=!recovery" >> /root/build/gvmd.service
echo "" >> /root/build/gvmd.service
echo "[Service]" >> /root/build/gvmd.service
echo "Type=exec" >> /root/build/gvmd.service
echo "User=gvm" >> /root/build/gvmd.service
echo "Group=gvm" >> /root/build/gvmd.service
echo "PIDFile=/run/gvmd/gvmd.pid" >> /root/build/gvmd.service
echo "RuntimeDirectory=gvmd" >> /root/build/gvmd.service
echo "RuntimeDirectoryMode=2775" >> /root/build/gvmd.service
echo "ExecStart=/usr/local/sbin/gvmd --foreground --osp-vt-update=/run/ospd/ospd-openvas.sock --listen-group=gvm" >> /root/build/gvmd.service
echo "Restart=always" >> /root/build/gvmd.service
echo "TimeoutStopSec=10" >> /root/build/gvmd.service
echo "" >> /root/build/gvmd.service
echo "[Install]" >> /root/build/gvmd.service
echo "WantedBy=multi-user.target" >> /root/build/gvmd.service

#Install systemd service file for gvmd
sudo cp -v /root/build/gvmd.service /etc/systemd/system/

#Systemd service file for gsad
echo "[Unit]" > /root/build/gsad.service
echo "Description=Greenbone Security Assistant daemon (gsad)" >> /root/build/gsad.service
echo "Documentation=man:gsad(8) https://www.greenbone.net" >> /root/build/gsad.service
echo "After=network.target gvmd.service" >> /root/build/gsad.service
echo "Wants=gvmd.service" >> /root/build/gsad.service
echo "" >> /root/build/gsad.service
echo "[Service]" >> /root/build/gsad.service
echo "Type=exec" >> /root/build/gsad.service
echo "User=gvm" >> /root/build/gsad.service
echo "Group=gvm" >> /root/build/gsad.service
echo "RuntimeDirectory=gsad" >> /root/build/gsad.service
echo "RuntimeDirectoryMode=2775" >> /root/build/gsad.service
echo "PIDFile=/run/gsad/gsad.pid" >> /root/build/gsad.service
echo "ExecStart=/usr/local/sbin/gsad --foreground --listen=0.0.0.0 --port=9392 --http-only" >> /root/build/gsad.service
echo "Restart=always" >> /root/build/gsad.service
echo "TimeoutStopSec=10" >> /root/build/gsad.service
echo "" >> /root/build/gsad.service
echo "[Install]" >> /root/build/gsad.service
echo "WantedBy=multi-user.target" >> /root/build/gsad.service
echo "Alias=greenbone-security-assistant.service" >> /root/build/gsad.service

#Install systemd service file for gsad
sudo cp -v /root/build/gsad.service /etc/systemd/system/

#Making systemd aware of the new service files
sudo systemctl daemon-reload

#Downloading the data from the Greenbone Community Feed
sudo /usr/local/bin/greenbone-feed-sync

sleep 5

#Finally starting the services
sudo systemctl start notus-scanner
sudo systemctl start ospd-openvas
sudo systemctl start gvmd
sudo systemctl start gsad

#Ensuring services are run at every system startup
sudo systemctl enable notus-scanner
sudo systemctl enable ospd-openvas
sudo systemctl enable gvmd
sudo systemctl enable gsad

#Making systemd aware of the new service files
sudo systemctl daemon-reload

#Stop the services
sudo systemctl stop notus-scanner
sudo systemctl stop ospd-openvas
sudo systemctl stop gvmd
sudo systemctl stop gsad

sleep 5

#Finish
sudo greenbone-feed-sync --type GVMD_DATA
sudo greenbone-feed-sync --type SCAP
sudo greenbone-feed-sync --type CERT

#Stop the services
sudo systemctl stop notus-scanner
sudo systemctl stop ospd-openvas
sudo systemctl stop gvmd
sudo systemctl stop gsad

sleep 5

#Finish
sudo greenbone-nvt-sync
sudo greenbone-scapdata-sync
sudo greenbone-certdata-sync

#Starting the PostgreSQL database server
sudo systemctl start postgresql@14-main

#Setting the Feed Import Owner
/usr/local/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value `/usr/local/sbin/gvmd --get-users --verbose | grep admin | awk '{print $2}'`

sleep 5

#Stop the services
sudo service gvmd stop

sleep 5

#Making systemd aware of the new service files
sudo systemctl daemon-reload

#Downloading the data from the Greenbone Community Feed
sudo /usr/local/bin/greenbone-feed-sync

sleep 5

#Finally starting the services
sudo systemctl start notus-scanner
sudo systemctl start ospd-openvas
sudo systemctl start gvmd
sudo systemctl start gsad

#Checking the status of the services
sudo systemctl status notus-scanner
sudo systemctl status ospd-openvas
sudo systemctl status gvmd
sudo systemctl status gsad 