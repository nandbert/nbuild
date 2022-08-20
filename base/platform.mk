# -*- tab-width: 4 -*-
#
#  CONTENT
#    centralize treatment of some platform dependent stuff
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2008-12-17
#
#  LANGUAGE
#    make
#

ifndef _PLATFORM_MK
_PLATFORM_MK =	true

SHELL = 		/bin/bash
MAKEFLAGS += 	--no-builtin-rules
.DEFAULT_GOAL =	all

NBTL ?=			1

override LANG =	C
export LANG

.SUFFIXES:

##############################################################################
# user config
##############################################################################

-include $(NBUILD)/../nbuild.config

##############################################################################
# determine platform and give it a simple name
##############################################################################

ifeq ($(OSTYPE),)
  NBUILD_PLATFORM :=	linux
else
ifneq ($(findstring solaris,$(OSTYPE)),)
  NBUILD_PLATFORM := 	solaris
else
ifneq ($(findstring linux,$(OSTYPE)),)
  NBUILD_PLATFORM :=	linux
else
  NBUILD_PLATFORM :=	windows
endif
endif
endif

# bitwidth of the (linux) system
HOSTTYPE:=$(shell uname -m)
ifeq ($(HOSTTYPE),x86_64)
  NBUILD_PLATBITS =	64
else
  NBUILD_PLATBITS =	32
endif

all::

debugplat:
	@echo OSTYPE = $(OSTYPE)
	@echo HOSTNAME = $(HOSTNAME)
	@echo NBUILD_PLATFORM = $(NBUILD_PLATFORM)
	@echo NBUILD_PLATBITS = $(NBUILD_PLATBITS)


##############################################################################
# some assertions
##############################################################################

_EMPTY :=
_SPACE :=	$(_EMPTY) $(_EMPTY)

ifeq ($(findstring $(_SPACE),$(shell pwd)),$(_SPACE))
  $(error error: spaces in directory names (here: $(shell pwd))\
    not supported)
endif


##############################################################################
# tools that may behave differently
##############################################################################

# patch :=	patch
#
# ifeq ($(NBUILD_PLATFORM),solaris)
#   patch :=	gpatch
# endif

ifeq ($(NBUILD_PLATFORM),windows)
NBUILD_COLOR ?= 	yes
endif

ifeq ($(NBUILD_PLATFORM),linux)
NBUILD_COLOR ?= 	yes
endif

# ifeq ($(findstring patch 2.5,$(shell $(patch) --version | head -1)),)
#   $(error error: wrong version of tool "patch")
# endif

ifneq ($(findstring GNU Awk 2,$(shell gawk --version | head -1)),)
  $(error error: wrong version of tool "gawk")
endif

ifeq ($(NBUILD_PLATBITS),64)
XLIBPATH =	/usr/X11R6/lib64
else
XLIBPATH =	/usr/X11R6/lib
endif


##############################################################################
# colorized output
##############################################################################

ifeq ($(TERM),dumb)
NBUILD_COLOR := no
endif

ifeq ($(EMACS),t)
NBUILD_COLOR := no
endif

ifeq ($(NBUILD_PLATFORM),windows)
ifeq ($(findstring bash,$(BASH)),)
NBUILD_COLOR := no
endif
endif

ifeq ($(NBUILD_COLOR),yes)
COLNIL :=	\033[0m
COLRED :=	\033[1;31m
COLBLU :=	\033[1;34m
COLMAG :=	\033[1;35m
COLGRE :=	\033[1;32m
COLCYA :=	\033[1;36m
COLBLK :=	\033[0;1;38m
endif

debugcolor:
	@echo -ne "$(COLRED)red $(COLBLU)blu $(COLMAG)mag $(COLBLK)blk "
	@echo -e "$(COLCYA)cyan $(COLGRE)green$(COLNIL)"

##############################################################################
# executable file name extension
##############################################################################

ifeq ($(NBUILD_PLATFORM),windows)
EXE_EXT = .exe
endif

ifeq ($(NBUILD_PLATFORM),linux)
EXE_EXT =
endif

##############################################################################
# verbosity
##############################################################################

V ?=	0
ifeq ($(V),0)
  NBQ =		@
  nbmsg =	@echo "  "$(1) ;
endif

##############################################################################
# use translibs
##############################################################################

NBUILD_TL ?=	1

##############################################################################
# for exports
##############################################################################

safile: MAKEFLAGS +=	--no-print-directory

safile:
ifeq ($(NBTL),1)
	make showlibs
else
	make clean
endif
	make file | grep -v ^make[[] > .Makefile
	mv .Makefile Makefile

endif
