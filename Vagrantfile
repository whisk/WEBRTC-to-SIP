VM_KAM_IP    = '192.168.56.10'
VM_TURN_IP   = '192.168.56.11'
VM_CLIENT_IP = '192.168.56.12'

Vagrant.configure('2') do |config|
  # Kamailio + RTPEngine
  config.vm.define 'kamailio' do |config|
    config.vm.box = 'bento/ubuntu-16.04'
    config.vm.provider 'virtualbox' do |vb|
      vb.memory = '2048'
      vb.cpus   = 2
    end
    config.vm.hostname = 'kamailio.websip.dev'
    config.vm.network 'private_network', ip: VM_KAM_IP
#    config.vm.network 'public_network'

    config.vm.provision 'kamailio', type: 'shell', inline: <<-SCRIPT
      export DEBIAN_FRONTEND=noninteractive
      apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xfb40d3e6508ea4c8
      echo "deb http://deb.kamailio.org/kamailio44 xenial main" > /etc/apt/sources.list.d/kamailio.list
      apt-get update
      apt-get -y install kamailio kamailio-websocket-modules kamailio-mysql-modules kamailio-tls-modules kamailio-presence-modules mysql-server
      # COPY FILES
      cp /vagrant/files/etc/default/kamailio /etc/default
      cp /vagrant/files/etc/rsyslog.d/40-kamailio.conf /etc/rsyslog.d
      cp /vagrant/files/usr/share/kamailio/mysql/topos-create.sql /usr/share/kamailio/mysql/
      cp /vagrant/files/etc/kamailio/{tls.cfg,kamailio.cfg,kamctlrc} /etc/kamailio
      printf "\ny\ny\ny\n" | kamdbctl create
      kamctl add websip websip
      kamctl add oldsip oldsip
      service kamailio start
      update-rc.d ufw disable
    SCRIPT

    config.vm.provision 'rtpengine', type: 'shell', inline: <<-SCRIPT
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y git dpkg-dev debhelper iptables-dev libavcodec-dev libavfilter-dev libcurl4-openssl-dev \
        libevent-dev libglib2.0-dev libhiredis-dev libpcap-dev libxmlrpc-core-c3-dev markdown \
         dkms linux-headers-`uname -r`
      rm -rf rtpengine && git clone https://github.com/sipwise/rtpengine.git
      cd rtpengine
      ./debian/flavors/no_ngcp
      dpkg-buildpackage && cd .. && dpkg -i ngcp-rtpengine-daemon_*.deb ngcp-rtpengine-iptables_*.deb ngcp-rtpengine-kernel-dkms_*.deb
      # COPY FILES
      cp /vagrant/files/etc/rtpengine/rtpengine.conf /etc/rtpengine/
      cp /vagrant/files/etc/default/ngcp-rtpengine-daemon /etc/default/
      service ngcp-rtpengine-daemon restart
      service kamailio restart
    SCRIPT
  end

  # TURN server
  config.vm.define 'turn' do |config|
    config.vm.box = 'bento/ubuntu-16.04'
    config.vm.provider 'virtualbox' do |vb|
      vb.memory = '2048'
      vb.cpus   = 2
    end
    config.vm.hostname = 'turn.websip.dev'
    config.vm.network 'private_network', ip: VM_TURN_IP

    config.vm.provision 'base', type: 'shell', inline: <<-SCRIPT
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y coturn
      # COPY FILES
      cp /vagrant/files/etc/turn*.conf /etc/
      cp /vagrant/files/etc/default/coturn /etc/default/
      service coturn start
      update-rc.d coturn enable
    SCRIPT
  end

  # WebRTC client
  config.vm.define 'client' do |config|
    config.vm.box = 'bento/ubuntu-16.04'
    config.vm.provider 'virtualbox' do |vb|
      vb.memory = '2048'
      vb.cpus   = 2
    end
    config.vm.hostname = 'client.websip.dev'
    config.vm.network 'private_network', ip: VM_CLIENT_IP

    config.vm.provision 'base', type: 'shell', inline: <<-SCRIPT
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y nginx
      # COPY FILES
      cp /vagrant/files/etc/nginx/sites-available/default /etc/nginx/sites-available/
      cp -r /vagrant/files/var/www/html/* /var/www/html/
      service nginx start
      update-rc.d nginx enable
    SCRIPT
  end
end
