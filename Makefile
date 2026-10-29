# SiriEntitlementFix (Universal / 通用版)
# 不写 INSTALL_TARGET_PROCESSES：不绑定进程，由 LiveContainer 注入后对容器内所有 App 生效

ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SiriEntitlementFix

SiriEntitlementFix_FILES = Tweak.x
SiriEntitlementFix_CFLAGS = -fobjc-arc
SiriEntitlementFix_FRAMEWORKS = Foundation Intents

include $(THEOS_MAKE_PATH)/tweak.mk
