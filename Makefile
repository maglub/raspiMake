#--- http://downloads.raspberrypi.org/raspbian_lite/images/

JESSIE_VERSION = 2017-07-05
JESSIE_SYMLINK = jessie.img
JESSIE_FILE    = $(JESSIE_VERSION)-raspbian-jessie-lite.zip
JESSIE_IMAGE   = $(JESSIE_VERSION)-raspbian-jessie-lite.img
JESSIE_URL     = http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/$(JESSIE_FILE)

STRETCH_VERSION = 2017-09-07
STRETCH_SYMLINK = stretch.img
STRETCH_FILE    = $(STRETCH_VERSION)-raspbian-stretch-lite.zip
STRETCH_IMAGE   = $(STRETCH_VERSION)-raspbian-stretch-lite.img
STRETCH_URL     = http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-09-08/$(STRETCH_FILE)

#--- default is the first recipe, and will be called with just "make"
default: diskutilList help

help:
	@echo ""
	@echo "Usage:"
	@echo ""
	@echo "* Look for new images at: http://downloads.raspberrypi.org/raspbian_lite/images/"
	@echo "* If you want to enable ssh, touch ./ssh (if the file exist in this directory, it will be copied to /boot)"
	@echo "* If you want to set up wpa_supplicant.conf, create one in this directory, and it will be copied to /boot"
	@echo ""
	@echo "#--- "make" with no arguments will list disks"
	@echo "make"
	@echo ""
	@echo "#--- X => the disk number you see above"
	@echo "make jessie DISK=X"
	@echo "make stretch DISK=X"
	@echo ""

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

ddStretch: diskSet
	diskutil unmountDisk /dev/disk$(DISK)
	pv $(STRETCH_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true

stretch: $(STRETCH_SYMLINK) ddStretch copyFiles

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

ddJessie: diskSet
	diskutil unmountDisk /dev/disk$(DISK)
	pv $(JESSIE_SYMLINK) | sudo dd of=/dev/rdisk$(DISK) bs=1m || true

jessie:  $(JESSIE_SYMLINK) ddJessie copyFiles

#===================================
# MAIN 
#===================================

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


clean:
	rm *.img || true

distclean: clean
	rm *jessie*.zip || true
	rm *stretch*.zip || true
