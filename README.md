# Introduction

This Makefile will help you create raspbian-lite SD cards on Mac OSX. You might get it to work on Linux as well, but I have not put any thought into making it work across the borders. This Makefile supports creating /boot/ssh and /boot/wpa_supplicant.conf automatically, see below.

* jessie - for projects that are not yet ready for the latest and greatest release
* stretch - currently the latest release

Usage:

```
#--- make without any options will list connected SD cards (and other disks)
make 
#--- create a card with raspbian-jessie-lite
make jessie DISK=X

#--- create a card with raspbian-stretch-lite
make stretch DISK=X
```

make will download and unpack the necessary image, and write it to the selected /dev/rdisk device.

## Pre requisites

* pv

```
brew install pv
```

If you don't feel like installing the "pv" command, just replace "pv" with "cat" in the Makefile.

# Examples

I recommend that you create both a ./wpa_supplicant.conf file and a ./ssh file, so that you start your raspberry pi with a working wifi connection and ssh enabled. This, of course, have some security implications. Don't leave your raspberry pi like that without changing the password for the "pi" user, and do not connect it directly to the internet.

## SSH

If you want ssh to be enabled at boot, touch ./ssh and run make.

Example:

```
touch ./ssh
make stretch DISK=X
```

## wpa_supplicant.conf

If you want your favorite wifi configured, create a wpa_supplicant.conf file in this directory, and it will automatically be copied to the SD card.

```
cat<<EOT > wpa_supplicant.conf
country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
  ssid="YOUR_WIFI_SSID"
  psk="YOUR_SUPER_SECRET_WIFI_PASSWORD"
  id_str="HOME"
  priority=15
}
EOT

make stretch DISK=X
```

## Simple demo

```
$ make
diskutil list
...
/dev/disk2 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *16.1 GB    disk2
   1:             Windows_FAT_32 boot                    43.8 MB    disk2s1
   2:                      Linux                         1.8 GB     disk2s2
...

$ touch ssh
$ vi wpa_supplicant.conf

$ make stretch DISK=2
wget http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-09-08/2017-09-07-raspbian-stretch-lite.zip
...
* Extracting 2017-09-07-raspbian-stretch-lite.img from 2017-09-07-raspbian-stretch-lite.zip
unzip -o 2017-09-07-raspbian-stretch-lite.zip
Archive:  2017-09-07-raspbian-stretch-lite.zip
  inflating: 2017-09-07-raspbian-stretch-lite.img  
ln -sf 2017-09-07-raspbian-stretch-lite.img stretch.img
DISK: 2
test -n "2" # $DISK => make jessie/stretch DISK=XXX needed
diskutil unmountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
pv stretch.img | sudo dd of=/dev/rdisk2 bs=1m || true
1.73GiB 0:02:10 [13.6MiB/s] [==================================================================================================>] 100%            
0+28299 records in
0+28299 records out
1854590976 bytes transferred in 130.476857 secs (14213946 bytes/sec)
* Sleeping 3 seconds, to allow OSX to find the newly written SD card again
* checking for ssh file
* checking for wpa_supplicant.conf file
* Looking in /Volumes/boot
-rwxrwxrwx  1 malu  staff    0 Sep 18 17:36 /Volumes/boot/ssh
-rwxrwxrwx  1 malu  staff  164 Sep 18 17:36 /Volumes/boot/wpa_supplicant.conf
* Unmounting and ejecting disk
diskutil unmountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
diskutil eject /dev/disk2
Disk /dev/disk2 ejected
```


# License

MIT License

Copyright (c) 2017 Magnus Lübeck

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

