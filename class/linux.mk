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
include 		$(NBUILD)/base/platform.mk

GNU_CC ?=		$(GCC_PREFIX)gcc -c
GNU_CX ?=		$(GCC_PREFIX)g++ -c
GNU_AS ?=		$(GCC_PREFIX)gcc -c
GNU_LD ?=		$(GCC_PREFIX)gcc
GNU_AR ?=		$(GCC_PREFIX)ar rcs
GNU_PROMPT ?=	gcc/linux

_GNU_CCOPTS +=	-Wall -Wno-unused -Wno-parentheses -Wno-sign-compare -Wno-format
GNU_CCOPTS :=	$(_CCOPTS) $(CCOPTS)

ifeq ($(LENIENT),)
GNU_CPOPTS +=	-Werror=strict-prototypes -Werror-implicit-function-declaration
endif
GNU_CPOPTS :=	$(_CPOPTS) $(CPOPTS)

GNU_CXOPTS +=
GNU_ASOPTS +=

GNU_LDOPTS +=	-lm -lstdc++

include			$(NBUILD)/base/core.mk
include			$(NBUILD)/base/.GNU.mk
include			$(NBUILD)/base/sub.mk
include			$(NBUILD)/base/headdep.mk

# app specific
ifneq ($(GNU_APP),) 
include			$(NBUILD)/base/tags.mk

endif # /app

