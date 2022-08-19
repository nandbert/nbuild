# -*- tab-width: 4 -*-
#
#  CONTENT
#	 very simple example for heterogeneous multicore builds. in a real application of course we
#    would have 2 different compilers and put this file in some common "build class" folder to
#    let it be included from various makefiles
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
include 		$(NBUILD)/base/platform.mk

C0_CC ?=		$(GCC_PREFIX)gcc -c
C0_CX ?=		$(GCC_PREFIX)g++ -c
C0_AS ?=		$(GCC_PREFIX)gcc -c
C0_LD ?=		$(GCC_PREFIX)gcc
C0_AR ?=		$(GCC_PREFIX)ar rcs
C0_PROMPT ?=	core0

C1_CC ?=		$(GCC_PREFIX)gcc -c
C1_CX ?=		$(GCC_PREFIX)g++ -c
C1_AS ?=		$(GCC_PREFIX)gcc -c
C1_LD ?=		$(GCC_PREFIX)gcc
C1_AR ?=		$(GCC_PREFIX)ar rcs
C1_PROMPT ?=	core1

include			$(NBUILD)/base/core.mk
include			$(NBUILD)/base/.C0.mk
include			$(NBUILD)/base/.C1.mk
