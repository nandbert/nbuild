# -*- tab-width: 4 -*-
#
#  CONTENT
#    make package to create SUN RPC stubs
#
#  PARAMETERS
#	 RPC_X	interface definition file
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2022-02-08
#
#  LANGUAGE
#    make
#

ifeq (/$(RPCGEN)/,//)
RPCGEN	= rpcgen
endif

ifeq (/$(RPC_X_DIR)/,//)
RPC_X_DIR	= .
endif

#.SUFFIXES: %_svc.c %_clnt.c %_xdr.c 


%.h: $(RPC_X_DIR)/%.x
	[ "$@" = "$(notdir $@)" ] && D=`pwd`/ ; \
	cd $(RPC_X_DIR) ; $(RPCGEN) -h $(notdir $<) > $${D}$@

%_xdr.c: $(RPC_X_DIR)/%.x
	[ "$@" = "$(notdir $@)" ] && D=`pwd`/ ; \
	cd $(RPC_X_DIR) ; $(RPCGEN) -c $(notdir $<) > $${D}$@

%_clnt.c: $(RPC_X_DIR)/%.x
	[ "$@" = "$(notdir $@)" ] && D=`pwd`/ ; \
	cd $(RPC_X_DIR) ; $(RPCGEN) -l $(notdir $<) > $${D}$@

%_svc.c: $(RPC_X_DIR)/%.x
	[ "$@" = "$(notdir $@)" ] && D=`pwd`/ ; \
	cd $(RPC_X_DIR) ; $(RPCGEN) -m $(notdir $<) > $${D}$@


RPC_H	=	$(RPC_X:.x=.h)


all::

CCOPTS +=	-I.

clean::
	rm -f *_svc.c *_clnt.c *_xdr.c $(RPC_H)

