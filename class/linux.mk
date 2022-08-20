# -*- tab-width: 4 -*-
#
#  CONTENT
#	 common settings for linux based build flavors
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2017-02-18
#
#  LANGUAGE
#    make
#
include $(NBUILD)/base/platform.mk

GNU_CC ?=		$(GCC_PREFIX)gcc -c
GNU_CX ?=		$(GCC_PREFIX)g++ -c
GNU_AS ?=		$(GCC_PREFIX)gcc -c
GNU_LD ?=		$(GCC_PREFIX)gcc
GNU_AR ?=		$(GCC_PREFIX)ar rcs
GNU_PROMPT ?=	gcc/linux

_CCOPTS +=		-Wall -Wno-unused -Wno-parentheses -Wno-sign-compare -Wno-format
CCOPTS :=		$(_CCOPTS) $(CCOPTS)

ifeq ($(LENIENT),)
CPOPTS +=		-Werror=strict-prototypes -Werror-implicit-function-declaration
endif
CPOPTS :=		$(_CPOPTS) $(CPOPTS)

CXOPTS +=
ASOPTS +=

LDOPTS +=		-lm -lstdc++

include $(NBUILD)/base/usage.mk
include $(NBUILD)/base/single.mk
include $(NBUILD)/base/sub.mk
include $(NBUILD)/base/headdep.mk

# app specific
ifneq ($(APP),) 
include $(NBUILD)/base/tags.mk

# desktop, i.e. not using the board package
ifndef _BOARD_MK 

run:	allsub
	cd ..; $(notdir $(shell pwd))/$(_GNU_ELF) $(CMDL)

file::
	@echo -e \
	'run:\tallsub\n\tcd ..; $(notdir $(shell pwd))/$(_GNU_ELF) $$(CMDL)\n\n'

endif # /desktop
endif # /app

