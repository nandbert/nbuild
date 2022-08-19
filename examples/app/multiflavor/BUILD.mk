#
#  CONTENT
#    
#
#  AUTHOR
#    Norbert
#
#  DATE
#    2016-03-10
#
#  LANGUAGE
#    make
#
NBUILD =		../../..

GNU_APP =		hello.elf
GNU_APP_SRCS =	hello.c

GNU_APP_LIBS =	../../../lib/multiflavor/$(O-DIR)/libmulti.a


all::

clean::

run: allsub
	./$(GNU_APP)

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

