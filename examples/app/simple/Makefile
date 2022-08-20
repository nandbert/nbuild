#
#  CONTENT
#    test for a simple linux build (not multi core, not multi flavor)
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

APP_LIBS =  ../../lib/simple/libsimple.a

all::

clean::

include		$(NBUILD)/class/linux.mk

# NOTE:
# - variable NBUILD needs to point to the root of the nbuild tree
# - include path is deducted from GNU_APP_LIBS to ../../lib
# - targets "allsub", "cleansub" work on the library (tree)
# - target "all" only rebuilds locally, but builds the lib once if not there yet
# - target "showlibs" shows the library tree
# - target "run" builds everything and runs the executable with $(CMDL) args
