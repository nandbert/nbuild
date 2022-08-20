# -*- tab-width: 4 -*-
#
#  CONTENT
#    some internal helper functions that are reused by several packages
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2008-12-01
#
#  LANGUAGE
#    make
#

ifndef _HELPERS_MK
_HELPERS_MK =	true

# if we really need spaces ...
#
_EMPTY :=
_SPACE :=	$(_EMPTY) $(_EMPTY)

# must be adapted if main MF includes other MFs
NBMAKEFILE ?=	Makefile $(wildcard ../BUILD.mk)

# object dir prefix
ODP ?=		o-
ODPL ?=		2

# remove the last word from a list
#
cutlast =	$(wordlist 1,$(words $(wordlist 2,$(words $(1)),$(1))),$(1))

# create an include dir from a lib name, i.e. remove the last directory and
# any o-* elements in the path
#
incdir =	$(subst $(_SPACE),,$(call cutlast, $(call cutlast, \
			$(patsubst /$(ODP)%,,$(subst /, /,$(dir $(1)))))))

# remove the o- part of a path
#
cutodir =	$(subst $(_SPACE),,$(patsubst /$(ODP)%,,$(subst /, /,$(1))))

# make names of .o files from supported suffices
#
OBJ_SEP ?=	-
_src2obj =	$(strip $(foreach suf, s S c cpp cc C mc ms,\
			$(patsubst %.$(suf),%$(OBJ_SEP)$(suf).o,$(filter %.$(suf),$(1)))))

# remove duplicates starting from the right (for libs)
#
nlibuniq =	$(shell echo $(1) | awk '{ \
		  for(i=NF;i>0;i--){ \
		    for(j=0;j<l;j++) \
		      if(a[j]==$$i) break; \
		    if(j==l) a[l++]=$$i; \
		  } \
		  for(j=l-1;j>=0;j--) print a[j];}')

# remove duplicates starting from the left (for subbuilds)
#
nsubuniq =	$(shell echo $(1) | awk '{ \
		  for(i=1;i<=NF;i++){ \
		    for(j=0;j<l;j++) \
		      if(a[j]==$$i) break; \
		    if(j==l) a[l++]=$$i; \
		  } \
		  for(j=0;j<l;j++) print a[j];}')

# shellscript to make pathes relative to the current dir
#
NPATH2REL =	awk -vwd=`/bin/pwd` -F/ 'BEGIN{ \
		  $$0=wd;for(f=2;f<=NF;f++) c[f]=$$f \
			}{ \
		  if(NF>1 && $$1!=".."){ \
		    printf("%s",$$1); \
		    for(f=2;f<=NF&&c[f]==$$f;f++); \
		    for(i=f;c[i];i++); \
		    for(j=f;j<i;j++)    printf("../"); \
		    for(i=f;$$i;i++) {if(i>f) printf("/"); printf("%s",$$i); } \
		    printf("\n"); \
		  }else \
		    print; \
		}'
# make function to make pathes relative to the current dir
#
npath2rel =	$(foreach l,$(1),$(shell echo $(l)|$(NPATH2REL)))

# make pathes absolute
#
ifeq ($(MAKE_VERSION),3.81)
npath2abs =	$(abspath $(1))
else
npath2abs =	$(shell for i in $(1); do \
		  [ -d `dirname $$i` ] && (cd `dirname $$i` ; \
		  printf "%s/%s " `/bin/pwd` `basename $$i`) \
		done)
endif

# implementation of __showlibs to share between _corelib and _coreapp
#
nshowlibs =	\
	@if [ $(words $(1)) -gt 1 ] ; then \
	for i in $(call cutlast,$(1)) ; do \
	  printf "$(__NEST)+-- %s\n" $$i ; \
	  make --no-print-directory -C `dirname $$i` __$(2)showlibs \
	    __NEST="$(__NEST)|   "; \
	  printf "$(__NEST)|\n"; \
	done ; fi; \
	i=$(lastword $(1)); if [ "$$i" != "" ] ; then \
	printf "$(__NEST)+-- %s\n" $$i ; \
	make --no-print-directory -C `dirname $$i` __$(2)showlibs \
	  __NEST="$(__NEST)    "; \
	fi

# implementation of __cachelibs to share between _corelib and _coreapp
#
ncachelibs = \
	@for i in $(1) ; do \
	  echo __$(2)TL_LIBS+=$$i ; \
	  echo __$(2)TL_MFS+=$(addprefix $(shell pwd)/,$(NBMAKEFILE)) ; \
	  make --no-print-directory -C `dirname $$i` __$(2)cachelibs ; \
	done

all:: # protect debugpath2rel

debugpath2rel:
	@$(NPATH2REL)

# the toplevel dir of the project (one above "tools")
NBTOP =		$(shell while [ ! -d tools ] && [ `pwd` != /home ] ; \
		do cd .. ; done ; pwd)

ifeq ($(NBUILD_PLATFORM),windows)
cygpathm = $(shell echo $(1) | sed 's|/cygdrive/\(.\)|\1:|g')
else
cygpathm = $(1)
endif

##############################################################################
# pattern rules for o-dirs
##############################################################################

%$(OBJ_SEP)c.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $(INPUT_OPTION.c)$< $(ERRORFILT)

%$(OBJ_SEP)c.o: ../%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $(INPUT_OPTION.c)$< $(ERRORFILT)

%$(OBJ_SEP)S.o: %.S
	$(COMPILE.S) $(OUTPUT_OPTION) $< $(ERRORFILT)

%$(OBJ_SEP)S.o: ../%.S
	$(COMPILE.S) $(OUTPUT_OPTION) $< $(ERRORFILT)

%$(OBJ_SEP)s.o: %.s
	$(COMPILE.s) $(OUTPUT_OPTION) $< $(ERRORFILT)

%$(OBJ_SEP)s.o: ../%.s
	$(COMPILE.s) $(OUTPUT_OPTION) $< $(ERRORFILT)

%$(OBJ_SEP)ms.o: %.ms
	$(NBQ)$(TOOLS)/nmex/nmex $(NMEXOPTS) -n -t metas $< $*-tmp.s
	$(COMPILE.s) $(OUTPUT_OPTION) $*-tmp.s $(ERRORFILT)

%$(OBJ_SEP)ms.o: ../%.ms
	$(NBQ)$(TOOLS)/nmex/nmex $(NMEXOPTS) -n -t metas $< $*-tmp.s
	$(COMPILE.s) $(OUTPUT_OPTION) $*-tmp.s $(ERRORFILT)

%$(OBJ_SEP)cpp.o: %.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $(INPUT_OPTION.cpp)$< $(ERRORFILT)

%$(OBJ_SEP)cpp.o: ../%.cpp
	$(COMPILE.cpp) $(OUTPUT_OPTION) $(INPUT_OPTION.cpp)$< $(ERRORFILT)

# reusing COMPILE.cpp for alternative suffices
%$(OBJ_SEP)cc.o: %.cc
	$(COMPILE.cpp) $(OUTPUT_OPTION) $(INPUT_OPTION.cpp)$< $(ERRORFILT)

%$(OBJ_SEP)cc.o: ../%.cc
	$(COMPILE.cpp) $(OUTPUT_OPTION) $(INPUT_OPTION.cpp)$< $(ERRORFILT)

%$(OBJ_SEP)C.o: %.C
	$(COMPILE.cpp) $(OUTPUT_OPTION) $(INPUT_OPTION.cpp)$< $(ERRORFILT)

%$(OBJ_SEP)C.o: ../%.C
	$(COMPILE.cpp) $(OUTPUT_OPTION) $(INPUT_OPTION.cpp)$< $(ERRORFILT)

# create (outlying) o-dir
$(ODP)%:
	mkdir $@

endif
