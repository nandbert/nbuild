#
#  CONTENT
#    demo for a simple build for heterogeneous cores. note the difference to multiflavored builds:
#	 here we are building 2 apps simultanously from partially overlapping and partially individual
#    sources. one could be an embedded firmware, and the other one the driver on the host.
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
NBUILD =		../../..

C0_APP =		c0.elf
C0_APP_SRCS =	c0.c common.c

C1_APP =		c1.elf
C1_APP_SRCS =	c1.c common.c


all::

clean::

run:	all
	./$(C0_APP) && ./$(C1_APP)

include         multicore.mk

