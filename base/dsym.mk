# -*- tab-width: 4 -*-
#
#  CONTENT
#    make package to create symbol files from C headers containing #defines 
#    of peripheral addresses
#
#  PARAMETERS
#    DSYM	      		name of the symbol file to generate
#    DSYM_HEADERS 		headerfiles to be used
#
#    DYM_FILTER			optional command to preselect symbols (i.e. grep -v)
#
#    DSYM[1234]	      	optional other symbol files
#    DSYM[1234]_HEADERS optional other headers
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2008-12-11
#
#  LANGUAGE
#    make
#

ifndef _DSYM_MK
_DSYM_MK =	true

ifeq ($(origin NBUILD),undefined)
  $(error error: NBUILD undefined)
endif

##############################################################################
# parameters
##############################################################################

ifeq ($(strip $(DSYM)),)
  $(error error: no DSYM set)
endif

ifeq ($(strip $(DSYM_HEADERS)),)
  $(error error: no DSYM set)
endif

DSYM_FILTER ?=	cat


##############################################################################
# targets
##############################################################################

_DSYM_TF:=	tmp_$(shell echo $$PPID)

$(DSYM):	$(DSYM_HEADERS)
$(DSYM1): 	$(DSYM1_HEADERS)
$(DSYM2): 	$(DSYM2_HEADERS)
$(DSYM3): 	$(DSYM3_HEADERS)
$(DSYM4): 	$(DSYM4_HEADERS)

$(DSYM) $(DSYM1) $(DSYM2) $(DSYM3) $(DSYM4):
	@echo generating: $@
	@printf "#include <stdio.h>\n" > $(_DSYM_TF).c
	@for i in $^ ; do printf "#include \"%s\" \n" $$i ; done \
	  >> $(_DSYM_TF).c
	@printf "main(){\n" >> $(_DSYM_TF).c
	@cat $^ | awk '{\
	  if($$1=="#define" && $$2!~"PERIPH" && $$2!~"_H$$" && $$2!~"BRACKET")\
	    printf("printf(\"%%08x d %s\\n\",%s);\n",$$2,$$2);\
          else printf("//skipped: %s\n",$$0); \
	  if($$1~"Cbuf") \
	    printf("printf(\"%%08x d %s\\n\",%s);\n",$$1,$$1);\
	}' >> $(_DSYM_TF).c
	@printf "return 0;\n}\n">> $(_DSYM_TF).c
	@gcc $(_DSYM_TF).c -o $(_DSYM_TF).exe
	@./$(_DSYM_TF).exe | $(DSYM_FILTER) | sort -k1,1 -k3,3r | uniq > $@
	@rm $(_DSYM_TF).*

# was:
#@./$(_DSYM_TF).exe | sort -k1,1 -k 3,3r | sort -u -k1,1 > $@ 

all::	$(DSYM) $(DSYM1) $(DSYM2) $(DSYM3) $(DSYM4)

clean::
	rm -f $(DSYM) $(DSYM1) $(DSYM2) $(DSYM3) $(DSYM4)

endif
