v.1.0.15

This is a system to automate the installation of ISPConfig 3 control Panel ( http://www.ispconfig.org/page/home.html ).

Tested on:

- Debian 8 Jessie (VmWare Esxi, Virtualbox, OVH VPS)

For now it is tested and developed only on Debian systems.

Maybe it works well also on Ubuntu systems.

### What is this repository for? ###

This repository contains some scripts for the automation

of installation of ISPConfig 3 control panel.

Before start be sure to configure your server following the following guides:

- Debian 7: https://www.howtoforge.com/perfect-server-debian-wheezy-apache2-bind-dovecot-ispconfig-3
- Debian 8: https://www.howtoforge.com/tutorial/debian-8-jessie-minimal-server/
- Centos 7: http://www.howtoforge.com/centos-7-server

You can Choose during install:
- Apache / Nginx
- Dovecot or Courier
- Quota On/Off
- Jailkit On/Off
- Squirrelmail / Roundcube
- ISPConfig 3 Standard / Expert mode

### How do I get set up? ###

* Summary of set up

First of all follow the guide 

https://www.howtoforge.com/perfect-server-debian-wheezy-apache2-bind-dovecot-ispconfig-3

to install debian as required for ISPConfig

* Configuration for Debian 7 / 8

After you got a fresh and perfect Debian installation you had to

```shell
cd /tmp; wget --no-check-certificate -O installer.tgz "https://github.com/SergiX44/ispconfig_setup/tarball/master"; tar zxvf installer.tgz; cd *ispconfig*; bash install.sh
```
* Centos 7

```shell
cd /tmp; yum install wget unzip net-tools; wget --no-check-certificate -O installer.tgz "https://github.com/SergiX44/ispconfig_setup/tarball/master"; tar zxvf installer.tgz; cd *ispconfig*; bash install.sh
```

Centos 7 is in a very early stage, we got to test a bit, any help will be appreciated. 

Follow the instruction on the screen

### Who had contributed to this work? ###

* The scripts and instructions have been produced by Matteo Temporini ( <temporini.matteo@gmail.com> )
* Special thanks to Torsten Widmann for contribution to the code
* The code is based on the "Automatic Debian System Installation for ISPConfig 3" of Author: Mark Stunnenberg <mark@e-rave.nl>
* Howtoforge community https://www.howtoforge.com/community/
* Updated by SergiX44
