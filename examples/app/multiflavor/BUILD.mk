# -*- tab-width: 4 -*-
#
#  CONTENT
#    example how to build the objects in several "flavors" from the same set of sources
#	 (currently only o-linux
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2022-08-19
#
#  LANGUAGE
#    make
#
NBUILD =	../../..

APP =		hello.elf
APP_SRCS =	hello.c

APP_LIBS =	../../../lib/multiflavor/$(O-DIR)/libmulti.a

all::

clean::

# NOTE:
# - the BUILD.mk besides the sources replaces the Makefile
# - make works best when executed besides the Makefile (see Pauls 3rd rule,
#   http://make.mad-scientist.net/papers/rules-of-makefiles)
#   so a Makefile is generated inside the object dir ("o-linux") by inherit.sh:
#   ../../../bin/inherit.sh linux
#   this Makefile is just a forwarder to the real Makefile in the nbuild/flavors directory
# - the library path now starts with an extra ../ because its relative to the object dir
# - the library path contains the variable $(O-DIR) to link the right library
# - the include path is still deducted from GNU_APP_LIBS to ../../lib

