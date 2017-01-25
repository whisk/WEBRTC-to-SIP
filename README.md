# WebRTC to SIP

Automated *demo* configuration to enable calls between WebRTC and legacy SIP clients. This setup will allow:

* WebRTC -> SIP
* SIP -> WebRTC
* WebRTC <-> WebRTC
* SIP <-> SIP

This configuration provide 3 virtual servers: SIP server with RTP proxy, TURN server and a web-server. Used components:

* Kamailio 4.4 (SIP and WebRTC server)
* RTPEngine (RTP proxy)
* coturn (TURN server)
* sip.js (WebRTC client)
* nginx (web-server)
* Ubuntu 16.04 LTS
* Vagrant (for sandboxing)

This configuration was tested with Chrome browser and CSipSimple for Android.

## Installation

### Hostnames and IPs

NOTE: By default all virtual servers are bound to `192.168.56.0/24` network and use `websip.dev` domain. If you'd like to use different addresses, review contents of `/files/etc` directory and apply changes as necessary.

Add to your `/etc/hosts`:

  192.168.56.10  kamailio.websip.dev
  192.168.56.11  turn.websip.dev
  192.168.56.12  client.websip.dev

### Certificates

As WebRTC requires TLS, you need to have TLS keys and certificates. You may go with pre-generated ones or create your own self-signed bundle:

```
cd certs
./generate.sh
```

NOTE: previously generated keys and certs will be overwritted.

You may optionally add `ca.pfx` (or `ca.crt`) to your system trusted CA list.

### Provisioning

* Install [Vagrant](https://www.vagrantup.com/). You may also need to install [VirtualBox](https://www.virtualbox.org/).
* Launch boxes by typing:
```
  vagrant up kamailio
  vagrant up turn
  vagrant up client
```
  It could take a few minutes and about 8GB of disk space.

If you'd like to provision boxes again, type:

```
  vagrant provision <box name>
```

See `vagrant help` for more info.

## Usage

With a SIP client connect to our SIP server:

* Username: `oldsip`
* Password: `oldsip`
* Server: `kamailio.websip.dev`

Open `https://kamailio.websip.dev` to confirm security exception if you have not added self-generated CA certificate to trusted list.

Open `https://client.websip.dev` in Chrome browser. This page implements simple WebRTC client with built-in user credentials (`websip:websip`). Ented `oldsip` to call to.

You should receive a call from `websip` on your legacy SIP client.

Try to do it vice-versa etc.

## More info

Please refer to the following files:

* Configuration files under `files/etc`
* WebRTC sample page under `files/var/`
* Boxes provision scripts in `Vagrantfile`

## License

All used components are distributed under their respective licenses.
