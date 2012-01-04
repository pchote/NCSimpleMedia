export THEOS_DEVICE_IP=172.18.0.161
SDKVERSION = 5.0
include /usr/local/theos/makefiles/common.mk

LIBRARY_NAME = NCSimpleMedia
NCSimpleMedia_FILES = NCSimpleMedia.mm NCDualPressButton.m
NCSimpleMedia_INSTALL_PATH = /System/Library/WeeAppPlugins/NCSimpleMedia.bundle
NCSimpleMedia_FRAMEWORKS = Foundation UIKit AVFoundation MediaPlayer
NCSimpleMedia_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk

after-stage::
	mv _/System/Library/WeeAppPlugins/NCSimpleMedia.bundle/NCSimpleMedia.dylib _/System/Library/WeeAppPlugins/NCSimpleMedia.bundle/NCSimpleMedia
#	cp -a *.png _/System/Library/WeeAppPlugins/NCSimpleMedia.bundle/
	cp Info.plist _/System/Library/WeeAppPlugins/NCSimpleMedia.bundle/
	cp *.strings _/System/Library/WeeAppPlugins/NCSimpleMedia.bundle/