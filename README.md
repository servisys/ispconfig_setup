# README #

[![PayPayl donate button](https://www.paypalobjects.com/it_IT/IT/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TB4Q3UJDC5JDJ "Help US support this project using Paypal")

# Version #
v.2.0.1

This is a system to automate the installation of ISPConfig 3 control Panel ( http://www.ispconfig.org/page/home.html ).

Tested on:

- Debian 8 Jessie (VmWare Esxi, Amazon AWS, Virtualbox, OVH VPS)
- Debian 7 Wheezy (VmWare Esxi, Amazon AWS, Virtualbox, OVH VPS)
- Ubuntu 14.04 Trusty (VmWare Esxi, Amazon AWS, Virtualbox, OVH VPS)
- Ubuntu 15.10 Willy (VmWare Esxi, Amazon AWS, Virtualbox, OVH VPS)
- Centos 7 (Vitualbox)
- ISPConfig 3.*

For now it is tested and developed only on Debian systems.

Maybe it works well also on Ubuntu systems.

### What is this repository for? ###

This repository contains some scripts for the automation

of installation of ISPConfig 3 control panel.

Before start be sure to configure your server following the following guides:

- Debian 7: https://www.howtoforge.com/perfect-server-debian-wheezy-apache2-bind-dovecot-ispconfig-3
- Debian 8: https://www.howtoforge.com/tutorial/debian-8-jessie-minimal-server/
- Ubuntu 14.10: https://www.howtoforge.com/tutorial/ubuntu-minimal-server-install/
- Ubuntu 15.10: https://www.howtoforge.com/tutorial/ubuntu-minimal-server-install/
- Centos 7: http://www.howtoforge.com/centos-7-server

You can Choose during install:
- Apache / Nginx
- Dovecot or Courier
- Quota On/Off
- Jailkit On/Off
- Squirrelmail / Roundcube
- ISPConfig 3 Standard / Expert mode
- ISPConfig 3 Multiserver Setup (* Debian 8 only for now)

### How do I get set up? ###

* Summary of set up

First of all follow the guide 

https://www.howtoforge.com/perfect-server-debian-wheezy-apache2-bind-dovecot-ispconfig-3

to install debian as required for ISPConfig

* Configuration for Debian 7 / 8 - Ubuntu 14.04 / 15.10

After you got a fresh and perfect Debian installation you had to

```shell
cd /tmp; wget --no-check-certificate -O installer.tgz "https://github.com/servisys/ispconfig_setup/tarball/master"; tar zxvf installer.tgz; cd *ispconfig*; bash install.sh
```
* Centos 7

```shell
cd /tmp; yum install wget unzip net-tools; wget --no-check-certificate -O installer.tgz "https://github.com/servisys/ispconfig_setup/tarball/master"; tar zxvf installer.tgz; cd *ispconfig*; bash install.sh
```

Centos 7 is in a very early stage, we got to test a bit, any help will be appreciated. 
Some feature are missing for now, only implemented Apache and Dovecot, no webmail.

Follow the instruction on the screen

### Who had contributed to this work? ###

* The scripts and instructions have been produced by Matteo Temporini ( <temporini.matteo@gmail.com> )
* Special thanks to Torsten Widmann for contribution to the code
* Special thankt to Michiel Kamphuis for contribution to Multiserver Setup integration
* The code is based on the "Automatic Debian System Installation for ISPConfig 3" of Author: Mark Stunnenberg <mark@e-rave.nl>
* Howtoforge community https://www.howtoforge.com/community/
