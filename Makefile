THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

ARCHS = arm64
TARGET = iphone:latest:8.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = wxRedPlugin
wxRedPlugin_FILES = $(wildcard Red/*.m) Red/Tweak.xm
wxRedPlugin_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
