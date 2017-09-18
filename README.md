# Introduction

This Makefile will help you create raspbian-lite SD cards on Mac OSX. You might get it to work on Linux as well, but I have not put any thought into making it work across the borders.

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

