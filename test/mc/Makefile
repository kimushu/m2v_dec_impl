
MODULES_DPI_C += test_m2vmc
SOURCES = feed_m2vmc.cpp verify_m2vmc.cpp
LDFLAGS = -lrt

include ../common.mk

clean: clean.common

ifneq ($(USE_IMAGE_VIEWER),)
SIM_CMD += -GUSE_IMAGE_VIEWER=$(USE_IMAGE_VIEWER)
endif

