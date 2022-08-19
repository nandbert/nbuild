# -*- tab-width: 4 -*-
##############################################################################
#
# Copyright (c) 2014 Freescale Semiconductor;
#
##############################################################################
#
#  CONTENT
#    not only clean, but even tidy
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2007-03-23
#
#  LANGUAGE
#    make
#
##############################################################################

ifndef _TIDY_MK
_TIDY_MK =	true


##############################################################################

TIDY_WILDS +=	*~ 

tidy:: clean
	rm -f $(sort $(TIDY_WILDS))

showtidy:
	@echo would remove: "$(sort $(TIDY_WILDS))"

##############################################################################

endif

