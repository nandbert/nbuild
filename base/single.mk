# -*- tab-width: 4 -*-
#
#  CONTENT
#    simplify variable names for "single core" projects
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2021-07-20
#
#  LANGUAGE
#    make
#

ifneq ($(strip $(APP) $(LIB)),)

GNU_APP = 		$(APP)
GNU_APP_SRCS =	$(APP_SRCS)
GNU_APP_LIBS =	$(APP_LIBS)
GNU_APP_LIBS2=	$(APP_LIBS2)
GNU_LIB = 		$(LIB)
GNU_LIB_SRCS =	$(LIB_SRCS)
GNU_LIB_LIBS =	$(LIB_LIBS)
GNU_LIB_LIBS2=	$(LIB_LIBS2)
GNU_DEFS =		$(DEFS)
GNU_INCS =		$(INCS)
GNU_INCS2 =		$(INCS2)
GNU_CCOPTS =	$(CCOPTS)
GNU_CXOPTS =	$(CXOPTS)
GNU_CPOPTS =	$(CPOPTS)
GNU_ASOPTS =	$(ASOPTS)
GNU_LDOPTS =	$(LDOPTS)

endif

include 		$(NBUILD)/base/core.mk
include 		$(NBUILD)/base/.GNU.mk
