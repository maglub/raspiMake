#--- https://downloads.raspberrypi.org/raspbian_lite/images/

#--- 2017-07-05 is the last release of jessie
JESSIE_VERSION = 2017-07-05
JESSIE_RELEASE_DATE = $(JESSIE_VERSION)
JESSIE_SYMLINK = jessie.img
JESSIE_FILE    = $(JESSIE_VERSION)-raspbian-jessie-lite.zip
JESSIE_IMAGE   = $(JESSIE_VERSION)-raspbian-jessie-lite.img
JESSIE_URL     = https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-$(JESSIE_RELEASE_DATE)/$(JESSIE_FILE)

#--- This section has to be updated with new releases of stretch
#--- Sadly, the release date is not always the same date as the release version
#STRETCH_VERSION = 2017-11-29
STRETCH_VERSION = 2018-04-18
#STRETCH_RELEASE_DATE = 2017-12-01
STRETCH_RELEASE_DATE = 2018-04-19
STRETCH_SYMLINK = stretch.img
STRETCH_FILE    = $(STRETCH_VERSION)-raspbian-stretch.zip
STRETCH_IMAGE   = $(STRETCH_VERSION)-raspbian-stretch.img
STRETCH_URL     = https://downloads.raspberrypi.org/raspbian/images/raspbian-$(STRETCH_RELEASE_DATE)/$(STRETCH_FILE)

#--- This section has to be updated with new releases of stretch
#--- Sadly, the release date is not always the same date as the release version
#STRETCH_LITE_VERSION = 2017-11-29
STRETCH_LITE_VERSION = 2018-04-18
STRETCH_LITE_RELEASE_DATE = 2018-04-19
STRETCH_LITE_SYMLINK = stretchLite.img
STRETCH_LITE_FILE    = $(STRETCH_LITE_VERSION)-raspbian-stretch-lite.zip
STRETCH_LITE_IMAGE   = $(STRETCH_LITE_VERSION)-raspbian-stretch-lite.img
STRETCH_LITE_URL     = https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-$(STRETCH_LITE_RELEASE_DATE)/$(STRETCH_LITE_FILE)

#--- Buster
BUSTER_VERSION = 2019-09-26
BUSTER_RELEASE_DATE = 2019-06-30
BUSTER_SYMLINK = buster.img
BUSTER_FILE    = $(BUSTER_VERSION)-raspbian-buster.zip
BUSTER_IMAGE   = $(BUSTER_VERSION)-raspbian-buster.img
BUSTER_URL     = https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-$(BUSTER_RELEASE_DATE)/$(BUSTER_FILE)

#--- Buster_lite
BUSTER_LITE_VERSION = 2019-09-26
BUSTER_LITE_RELEASE_DATE = 2019-09-30
BUSTER_LITE_SYMLINK = busterLite.img
BUSTER_LITE_FILE    = $(BUSTER_LITE_VERSION)-raspbian-buster-lite.zip
BUSTER_LITE_IMAGE   = $(BUSTER_LITE_VERSION)-raspbian-buster-lite.img
BUSTER_LITE_URL     = https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-$(BUSTER_LITE_RELEASE_DATE)/$(BUSTER_LITE_FILE)
#BUSTER_LITE_URL     = https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-09-30/2019-09-26-raspbian-buster-lite.zip


#--- This section is for OctoPi (https://octoprint.org/download/)
OCTOPI_SYMLINK = octopi.img
OCTOPI_FILE    = octopi.zip
OCTOPI_IMAGE   = octopi-jessie-lite.img
OCTOPI_URL     = https://octopi.octoprint.org/latest

CAT_COMMAND:=$(shell type -p pv || echo cat)


#--- default is the first recipe, and will be called with just "make"
default: diskutilList help

help:
	@echo ""
	@echo "Usage:"
	@echo ""
	@echo "* Look for new images at: https://downloads.raspberrypi.org/raspbian_lite/images/"
	@echo "* If you want to enable ssh, touch ./ssh (if the file exist in this directory, it will be copied to /boot)"
	@echo "* If you want to set up wpa_supplicant.conf, create one in this directory, and it will be copied to /boot"
	@echo ""
	@echo "#--- "make" with no arguments will list disks"
	@echo "make"
	@echo ""
	@echo "#--- X => the disk number you see above"
	@echo "make jessie DISK=X"
	@echo "make buster DISK=X"
	@echo "make stretch DISK=X"
	@echo ""
	@echo "make buster_lite DISK=X"
	@echo "make stretch_lite DISK=X"
	@echo "make octopi DISK=X"
	@echo ""
	@echo "make $(STRETCH_FILE) # download file"
	@echo "make $(JESSIE_FILE) # download file"
	@echo "make $(OCTOPI_FILE) # download file"

#--- list disks
diskutilList:
	diskutil list

#--- create a ./ssh file
ssh:
	touch ssh

#--- Check that the DISK variable is set
diskSet:
	@echo "DISK: $(DISK)"
	test -n "$(DISK)" # $$DISK => make jessie/stretch DISK=XXX needed

unmountDisk:
	diskutil unmountDisk /dev/disk$(DISK)

copyFiles:
	@echo "* Sleeping 3 seconds, to allow OSX to find the newly written SD card again"
	@sleep 3
	@echo "* checking for ssh file"
	@if [ -a ssh ] ; then touch /Volumes/boot/ssh ; fi ;
	@echo "* checking for wpa_supplicant.conf file"
	@if [ -a wpa_supplicant.conf ]; then cp wpa_supplicant.conf /Volumes/boot ; fi;
	@echo "* Looking in /Volumes/boot"
	@ls -la /Volumes/boot/ssh /Volumes/boot/wpa_supplicant.conf 2>/dev/null || true
	@echo "* Unmounting and ejecting disk"
	diskutil unmountDisk /dev/disk$(DISK)
	diskutil eject /dev/disk$(DISK)

#===================================
# OctoPi
#===================================
$(OCTOPI_FILE):
	curl --silent -v $(OCTOPI_URL) 2>&1 | grep Location | awk -F"/" '{print $$NF}' | tr -d '\r' | xargs -L1 -IX wget -O X $(OCTOPI_URL)
	ls -tr octopi-jessie-lite* | tail -1 | xargs -L1 -IX ln -sf X octopi.zip

$(OCTOPI_IMAGE): $(OCTOPI_FILE)
	@echo "* Extracting $(OCTOPI_IMAGE) from $(OCTOPI_FILE)"
	unzip -o $(OCTOPI_FILE)
	ls -tr *-octopi-*.img | tail -1 | xargs -L1 -IX ln -sf X $(OCTOPI_IMAGE) 
	@touch $(OCTOPI_IMAGE)
	
$(OCTOPI_SYMLINK): $(OCTOPI_IMAGE)
	ln -sf $(OCTOPI_IMAGE) $(OCTOPI_SYMLINK)

ddOctopi: diskSet unmountDisk
	$(CAT_COMMAND) $(OCTOPI_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true


#===================================
# STRETCH
#===================================
$(STRETCH_FILE):
	wget $(STRETCH_URL)

$(STRETCH_IMAGE): $(STRETCH_FILE)
	@echo "* Extracting $(STRETCH_IMAGE) from $(STRETCH_FILE)"
	unzip -o $(STRETCH_FILE)
	@touch $(STRETCH_IMAGE)
	
$(STRETCH_SYMLINK): $(STRETCH_IMAGE)
	ln -sf $(STRETCH_IMAGE) $(STRETCH_SYMLINK)

ddStretch: diskSet unmountDisk
	$(CAT_COMMAND) $(STRETCH_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true

#===================================
# STRETCH_LITE
#===================================
$(STRETCH_LITE_FILE):
	wget $(STRETCH_LITE_URL)

$(STRETCH_LITE_IMAGE): $(STRETCH_LITE_FILE)
	@echo "* Extracting $(STRETCH_LITE_IMAGE) from $(STRETCH_LITE_FILE)"
	unzip -o $(STRETCH_LITE_FILE)
	@touch $(STRETCH_LITE_IMAGE)
	
$(STRETCH_LITE_SYMLINK): $(STRETCH_LITE_IMAGE)
	ln -sf $(STRETCH_LITE_IMAGE) $(STRETCH_LITE_SYMLINK)

ddStretchLite: diskSet unmountDisk
	$(CAT_COMMAND) $(STRETCH_LITE_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true

#===================================
# BUSTER
#===================================
$(BUSTER_FILE):
	echo $(BUSTER_FILE)
	wget $(BUSTER_URL)

$(BUSTER_IMAGE): $(BUSTER_FILE)
	echo $(BUSTER_IMAGE)
	ls -la $(BUSTER_IMAGE) || true
	@echo "* Extracting $(BUSTER_IMAGE) from $(BUSTER_FILE)"
	unzip -o $(BUSTER_FILE)
	@touch $(BUSTER_IMAGE)
	
$(BUSTER_SYMLINK): $(BUSTER_IMAGE)
	ln -sf $(BUSTER_IMAGE) $(BUSTER_SYMLINK)

ddBuster: diskSet unmountDisk
	echo "dd $(BUSTER_SYMLINK) to disk$(DISK)"
	$(CAT_COMMAND) $(BUSTER_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true

#===================================
# BUSTER_LITE
#===================================
$(BUSTER_LITE_FILE):
	echo $(BUSTER_LITE_FILE)
	wget $(BUSTER_LITE_URL)

$(BUSTER_LITE_IMAGE): $(BUSTER_LITE_FILE)
	echo $(BUSTER_LITE_IMAGE)
	ls -la $(BUSTER_LITE_IMAGE) || true
	@echo "* Extracting $(BUSTER_LITE_IMAGE) from $(BUSTER_LITE_FILE)"
	unzip -o $(BUSTER_LITE_FILE)
	@touch $(BUSTER_LITE_IMAGE)
	
$(BUSTER_LITE_SYMLINK): $(BUSTER_LITE_IMAGE)
	ln -sf $(BUSTER_LITE_IMAGE) $(BUSTER_LITE_SYMLINK)

ddBusterLite: diskSet unmountDisk
	echo "dd $(BUSTER_LITE_SYMLINK) to disk$(DISK)"
	$(CAT_COMMAND) $(BUSTER_LITE_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true


#===================================
# JESSIE
#===================================
$(JESSIE_FILE):
	wget $(JESSIE_URL)

$(JESSIE_IMAGE): $(JESSIE_FILE)
	@echo "* Extracting $(JESSIE_IMAGE) from $(JESSIE_FILE)"
	unzip -o $(JESSIE_FILE)
	touch $(JESSIE_IMAGE)
	
$(JESSIE_SYMLINK): $(JESSIE_IMAGE)
	@echo "* Creating symlink $(JESSIE_SYMLINK) => $(JESSIE_IMAGE)"
	ln -sf $(JESSIE_IMAGE) $(JESSIE_SYMLINK)

ddJessie: diskSet unmountDisk
	$(CAT_COMMAND) $(JESSIE_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true


#===================================
# MAIN 
#===================================

stretch: $(STRETCH_SYMLINK) ddStretch copyFiles

stretch_lite: $(STRETCH_LITE_SYMLINK) ddStretchLite copyFiles

buster: $(BUSTER_SYMLINK) ddBuster copyFiles

buster_lite: $(BUSTER_LITE_SYMLINK) ddBusterLite copyFiles

jessie:  $(JESSIE_SYMLINK) ddJessie copyFiles

octopi:  $(OCTOPI_SYMLINK) ddOctopi copyFiles

clean:
	rm *.img || true

distclean: clean
	rm *jessie*.zip || true
	rm *stretch*.zip || true
	rm *octopi*.zip || true
