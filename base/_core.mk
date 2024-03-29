# -*- tab-width: 4 -*-
#
#  CONTENT
#    (tempate for a) generated make package to compile &core& firmware,
#    typically included by a core and compiler specific make package
#
#  PARAMETERS
#    &core&_APP	   		name of the application to generate
#    &core&_APP_SRCS	source files of the application
#    &core&_APP_LIBS    full paths of libraries linked to the application
#    &core&_APP_LIBS2   libraries that bypass TL and are just added at the end
#
#    &core&_LIB	   		name of the library to generate (instead or in
#						addition to the app
#    &core&_LIB_SRCS	source files of the library
#    &core&_LIB_LIBS    full paths of libraries required by the libs
#
#
#    &core&_INCS      	include paths (beside of the paths of sub-libs), used
#						also in header dependency generation
#    &core&_INCS2		include paths not used for tagging
#
#    &core&_DEFS      	defines (used also in header dependency generation
#
#    &core&_LDSCRIPT  	linker script (including switch -xxx if required)
#
#    &core&_CCOPTS		additional compiler options (C and C++)
#    &core&_CXOPTS		additional compiler options (C++ only)
#    &core&_CPOPTS		additional compiler options (plain C only)
#    &core&_ASOPTS		additional assembler options
#    &core&_LDOPTS   	additional linker options
#
#
#    &core&_CC			C compiler
#    &core&_CX			C++ compiler
#    &core&_AS			assembler
#    &core&_LD			linker
#    &core&_AR			archiver
#
#    &core&_PROMPT		nice string that starts short messages
#
#    &core&_OD			optional, default is objdump
#    &core&_OC			optional, default is objcopy
#    &core&_NM			optional, default is nm
#
#    &core&_SRSECS		sections to be extracted when generating an srecord
#						file
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2009-12-17 initial
#    2011-04-04 completely revised
#
#  LANGUAGE
#    make
#


##############################################################################
# check required parameters
##############################################################################

ifeq ($(origin NBUILD),undefined)
  $(error error: NBUILD undefined)
endif

ifeq ($(strip $(&core&_APP) $(&core&_LIB)),)
  $(error error: no &core& target (lib/app) set)
endif

ifeq ($(strip $(&core&_APP_SRCS) $(&core&_LIB_SRCS)),)
  $(error error: no &core& sources set)
endif

ifeq ($(strip $(&core&_CC)),)
  $(error error: &core&_CC undefined)
endif

ifeq ($(strip $(&core&_CX)),)
  $(error error: &core&_CX undefined)
endif

ifeq ($(strip $(&core&_AS)),)
  $(error error: &core&_AS undefined)
endif

ifeq ($(strip $(&core&_LD)),)
  $(error error: &core&_LD undefined)
endif

ifeq ($(strip $(&core&_AR)),)
  $(error error: &core&_AR undefined)
endif

# defaults for some rare customization options
&core&_OD ?=		objdump
&core&_OC ?=		objcopy
&core&_NM ?=		nm
&core&_CCOO ?=		-o $@
&core&_LDOO ?=		-o $@
&core&_AROO ?=		$@
&core&_SRSECS ?=	.text .data .rodata


##############################################################################

include		$(NBUILD)/base/helpers.mk
include		$(NBUILD)/base/platform.mk


##############################################################################
# experimental: "translibs", i.e. transitive library linking
##############################################################################

ifeq ($(NBTL),1)

__&core&TL_CACHE :=		.&core&-tl-cache.d

# include our translib cache (only if we need it)
ifeq  ($(NBUILD_TL),1)
ifneq ($(basename $(&core&_APP)),)
ifeq ($(findstring clean,$(MAKECMDGOALS)),)
ifeq ($(findstring depend,$(MAKECMDGOALS)),)
ifeq ($V,2)
$(info *** include $(__&core&TL_CACHE))
endif
include $(__&core&TL_CACHE)
endif
endif
endif
endif

# 3 recursion rules from lib part
__&core&_LIB_LIBSF =  $(call npath2abs,$(&core&_LIB_LIBS))

__&core&showlibs:
	$(call nshowlibs,$(__&core&_LIB_LIBSF),&core&)

__&core&cachelibs:
	$(call ncachelibs,$(__&core&_LIB_LIBSF),&core&)

# our libs with full pathname
__&core&_APP_LIBSF =  $(call npath2abs,$(&core&_APP_LIBS))

# recursively output libs and their dependencies on MFs
__&core&appcachelibs:
	$(call ncachelibs,$(__&core&_APP_LIBSF),&core&)

# regenerate the translib cache if a MF has changed
$(__&core&TL_CACHE): $(sort $(NBMAKEFILE) $(__&core&TL_MFS))
	@printf "&core&.mk: regenerating lib cache "`pwd`"/$@\n"
	@make --no-print-directory __&core&appcachelibs | awk > $@ '\
	  /^__&core&TL_LIB/ { var[0,n[0]++]=$$0 } \
	  /^__&core&TL_MF/ {  var[1,n[1]++]=$$0 } \
	  END{ \
	    for(v=0;v<2;v++){ \
	      l=0; \
	      for(i=n[v];i>0;i--){ \
	        for(j=0;j<l;j++) \
		  if(a[j]==var[v,i]) break; \
	        if(j==l) a[l++]=var[v,i]; \
	      } \
	      for(j=l-1;j>=0;j--) print a[j]; \
            } \
	  }'

# recuded libs for linker
__&core&_APP_LDLIBS = $(call nlibuniq, $(call npath2rel, $(__&core&_APP_LIBSF) \
			$(__&core&TL_LIBS))) $(&core&_APP_LIBS2)

debugtl::
	@echo __&core&_APP_LIBSF=$(__&core&_APP_LIBSF)
	@echo __&core&TL_LIBS=$(__&core&TL_LIBS)
	@echo npath2rel, __&core&_APP_LIBSF=$(call npath2rel, $(__&core&_APP_LIBSF))

# recursively show libs
__&core&appshowlibs:
	$(call nshowlibs,$(__&core&_APP_LIBSF),&core&)

# show all libs and translibs nicely formated
showlibs::
	@echo "---------------------------"
	@echo $(&core&_APP)
	@make --no-print-directory __&core&appshowlibs __NEST="\r"
ifneq ($(&core&_APP_LIBS2),)
	@echo "---------------------------"
	@echo "explicitely added (LIBS2)  "
	@echo "$(&core&_APP_LIBS2)"
endif
	@echo "---------------------------"
	@echo "reduced libs for linker cmd"
	@echo "---------------------------"
	@for i in $(__&core&_APP_LDLIBS); do echo $$i ; done

# cleaning dependencies
cleandepend::
	rm -f $(__&core&TL_CACHE)

else

__&core&_APP_LDLIBS = $(call nlibuniq, $(call npath2rel, $(__&core&_APP_LIBSF) \
			$(&core&_APP_LIBS))) $(&core&_APP_LIBS2)

endif


##############################################################################
# phony targets
##############################################################################

.PHONY: 	clean all pre_all debug&core&

all::		pre_all

pre_all:: # just a hook, maybe useful in special applications


##############################################################################
# build the app
##############################################################################

ifneq ($(basename $(&core&_APP)),)

_&core&_APP_OBJS =	$(call _src2obj,$(&core&_APP_SRCS))

_&core&_APP =		$(basename $(&core&_APP))

_&core&_ELF = $(_&core&_APP).elf

$(_&core&_ELF): $(_&core&_APP_OBJS) $(__&core&_APP_LDLIBS)
ifeq ($(V),0)
	@echo "  $(&core&_PROMPT) LD $@ <= $(filter-out %.ld,$+)"
else
	@echo "  $(&core&_PROMPT) LD $@"
endif
	$(NBQ)$(&core&_LD) $(&core&_LDSCRIPT) $(&core&_LDOO) $+ \
	$(call cygpathm, $(&core&_LDOPTS)) $(ERRORFILT)
	@echo "------------------------------------------------------------"

_&core&_APP_CLEAN =	$(_&core&_ELF) $(_&core&_APP_OBJS) \
		$(_&core&_APP).tsym $(_&core&_APP)_sym.h $(_&core&_APP).dis

all::	$(_&core&_ELF)

clean_app::
	rm -f $(strip $(_&core&_APP_CLEAN))

clean:: clean_app

debug&core&::
	@echo "&core&_APP =             $(&core&_APP)"
	@echo "&core&_ELF =             $(_&core&_ELF)"
	@echo "_&core&_APP_OBJS =       $(_&core&_APP_OBJS)"

endif


##############################################################################
# build the lib
##############################################################################

ifneq ($(&core&_LIB),)

_&core&_LIB_OBJS =	$(call _src2obj,$(&core&_LIB_SRCS)) $(&core&_LIB_XOBJS)

$(&core&_LIB): $(_&core&_LIB_OBJS)
	@echo "  $(&core&_PROMPT) AR $(&core&_LIB)" #"<=" $(_&core&_LIB_OBJS)
	$(NBQ)rm -f $@
	$(NBQ)$(&core&_AR) $(&core&_AROO) $^ $(ERRORFILT)
	@echo "------------------------------------------------------------"

all::	$(&core&_LIB)

clean_lib::
	rm -f $(strip $(&core&_LIB) $(_&core&_LIB_OBJS))

clean:: clean_lib

debug&core&::
	@echo "&core&_LIB =             $(&core&_LIB)"
	@echo "_&core&_LIB_OBJS =       $(_&core&_LIB_OBJS)"

endif


##############################################################################
# override compile/assemble rules for &core& targets
##############################################################################

# prefer files found locally over VPATH
# disabled for metaio/are, only required for ole MQX builds??
# VPATH :=		. .. $(VPATH)

# collect all our options into the final compile rules

_&core&_LIBINCS =	$(filter-out -I, $(sort $(foreach d,	\
			$(&core&_APP_LIBS) $(&core&_LIB_LIBS),	\
			-I$(call incdir,$d))))

_&core&_4ALLOPTS =	$(addprefix -D,$(&core&_DEFS)) \
			$(addprefix -I,$(&core&_INCS) $(&core&_INCS2)) \
			$(_&core&_LIBINCS)

_&core&_OBJS =		$(_&core&_APP_OBJS) $(_&core&_LIB_OBJS)

$(_&core&_OBJS): COMPILE.c = 	$(call nbmsg,"$(&core&_PROMPT) CC" $@) \
				  $(&core&_CC) $(&core&_CCOPTS) \
				  $(&core&_CPOPTS) $(call cygpathm,$(_&core&_4ALLOPTS))

$(_&core&_OBJS): COMPILE.cpp = 	$(call nbmsg,"$(&core&_PROMPT) CX" $@) \
				  $(&core&_CX) $(&core&_CCOPTS) \
				  $(&core&_CXOPTS) $(call cygpathm,$(_&core&_4ALLOPTS))

$(_&core&_OBJS): COMPILE.S = 	$(call nbmsg,"$(&core&_PROMPT) AS" $@) \
				  $(&core&_AS) $(&core&_ASOPTS) \
				  $(call cygpathm,$(_&core&_4ALLOPTS))

$(_&core&_OBJS): COMPILE.s = 	$(call nbmsg,"$(&core&_PROMPT) AS" $@) \
				  $(&core&_AS) $(&core&_ASOPTS) \
				  $(call cygpathm,$(_&core&_4ALLOPTS))

$(_&core&_OBJS): OUTPUT_OPTION = $(&core&_CCOO)

$(_&core&_OBJS): INPUT_OPTION.c = $(&core&_CCIO)

$(_&core&_OBJS): INPUT_OPTION.cpp = $(&core&_CXIO)


# show the variables
debug&core&::
	@echo "&core&_DEFS =            $(&core&_DEFS)"
	@echo "&core&_INCS =            $(&core&_INCS)"
	@echo "_&core&_LIBINCS =        $(_&core&_LIBINCS)"
	@echo "_&core&_4ALLOPTS =       $(_&core&_4ALLOPTS)"
	@echo "VPATH = $(VPATH)"

showdefines&core&:
	echo |  $(&core&_CC) $(&core&_CCOPTS) $(&core&_CPOPTS) \
	$(call cygpathm,$(_&core&_4ALLOPTS)) -dM -E -

showdefines: showdefines&core&

##############################################################################
# implicit rules for auxiliary files. not built by default, using Makefile
# must add them to all:: if required
##############################################################################

# something similar to the log file of a standalone assembler
# does currently not work, because based on stabs symbols (not dwarf)
#
#$(_&core&).log: $(_&core&).elf
#	@echo faking: $@
#	$(NBQ)for i in `objdump -g $< | awk \
#        '$$2=="file"&&$$4=="line"&&$$6=="addr" {print $$3}' | sort -u` ; do \
#	  [ ! -f $$i ] && echo "source file $$i not found" || { \
#	  (echo DEBUG_START; objdump -g $< ; \
#	   echo FILE_START ; cat $$i) | gawk -v fn=$$i '$(_&core&_AWKSPELL)' | \
#	   grep -v FILE_START; } done > $@
#	$(NBQ)(echo ; echo DATA: ; $(&core&_NM) -n $< | \
#	grep -i " D "||echo none) >> $@

# disassembly
$(_&core&_APP).dis: $(_&core&_APP).elf
	@echo disassembling: $< to $@
	$(NBQ)$(&core&_OD) -S $< > $@
	$(NBQ)(echo ; echo DATA: ; $(&core&_NM) -n $< | \
	grep -i " D "||echo none) >> $@

# text symbols for nicer listing of PC regs
$(_&core&_APP).tsym: $(_&core&_APP).elf
	@echo "generating: $@"
	$(NBQ)$(&core&_NM) -n $< | grep -i " t " > $@

# include file with symbols
$(_&core&_APP)_sym.h: %_sym.h: %.elf
	@echo "generating: $@"
	@$(&core&_NM) -n $< | gawk -v name=$* > $@ \
	'BEGIN{gsub("/","_",name);\
	printf("#ifndef %s_SYM_H\n#define %s_SYM_H\n",name,name);}\
	{ if($$2=="T" || $$2=="D") \
	{gsub("[.]","_",$$3); printf("#define %s_%s 0x%s\n",name,$$3,$$1);}}\
	END{printf("#endif\n");}'

# srecord file
$(_&core&_APP).srec: $(_&core&_APP).elf
	@echo "generating: $@"
	$(NBQ)$(&core&_OC) -O srec \
	  $(addprefix -j ,$(&core&_SRSECS)) $< $@


##############################################################################
# another hook
##############################################################################

all:: post_all

post_all::

##############################################################################
# variables exported to sub.mk and headdep.mk (only effective if these
# packages are used)
##############################################################################

ifneq ($(_&core&_APP),)
SUB_MAKES +=	$(foreach d,$(&core&_APP_LIBS) $(&core&_APP_LIBS2),$(dir $d))
endif

SUB_MAKES +=	$(foreach d,$(&core&_LIB_LIBS),$(dir $d))

# include directories
SUB_DIRS +=	$(subst -I,,$(&core&_INCS))

# directories of outlying source file
SUB_DIRS +=	$(sort $(foreach d,$(filter ../%,\
			$(&core&_APP_SRCS) $(&core&_LIB_SRCS)),$(dir $d)))

# sources for header dependencies
HDEP_SRCS += 	$(filter-out %.s,$(&core&_APP_SRCS) $(&core&_LIB_SRCS))

# flags used during header dependency generation (include pathes and defines)
HDEP_FLAGS +=	$(_&core&_4ALLOPTS)


##############################################################################
# submakes required for initial build of external libraries
# use the sub.mk package if they should be rebuilt (by 'allsub' target)
##############################################################################

$(filter %.o,$(&core&_APP_LIBS)): %.o:
	$(NBA)make -C $(dir $@) $(notdir $@)

$(filter ../%,$(sort $(filter %.a,$(__&core&_APP_LDLIBS)))): %.a:
	$(NBQ)make -C $(dir $@) $(notdir $@)

##############################################################################
# experimental: generate standalone makefile
##############################################################################

.PHONY: file

ifneq ($(strip $(&core&_APP)),)

&core&file::
	@echo -e \
	"## app &core&\n"\
	"all:: $(_&core&_ELF)\n\n"\
	"_&core&_APP_OBJS += $(_&core&_APP_OBJS)\n\n"\
	"$(_&core&_ELF): \$$(_&core&_APP_OBJS) $(__&core&_APP_LDLIBS)\n\t\$$(&core&_LD) \$$(&core&_LD_OPTS) -o \$$@ \$$+ \n\n"\

endif

ifneq ($(strip $(&core&_LIB)),)

&core&file::
	@echo -e \
	"## lib &core&\n"\
	"all:: $(&core&_LIB)\n\n"\
	"_&core&_LIB_OBJS += $(_&core&_LIB_OBJS)\n\n"\
	"$(&core&_LIB): \$$(_&core&_LIB_OBJS)\n\trm -f \$$@; $(&core&_AR) \$$@ \$$^\n\n"

ifeq ($(NBTL),1)
	@echo -e "__&core&showlibs:\n\n" 
endif
endif

&core&file::
	@echo -e \
	"## common &core&\n"\
	"O-DIR :=	$(O-DIR)\n\n"\
	"-include ../BUILD.mk\n\n"\
	"&core&_CC := $(&core&_CC)\n"\
	"&core&_CX := $(&core&_CX)\n"\
	"&core&_LD := $(&core&_LD)\n"\
	"&core&_AR := $(&core&_AR)\n"\
	"&core&_CC_OPTS := $(&core&_CCOPTS) $(_&core&_4ALLOPTS)\n"\
	"&core&_CX_OPTS := \$$(&core&_CC_OPTS) $(&core&_CXOPTS)\n"\
	"&core&_LD_OPTS := $(&core&_LDSCRIPT) $(&core&_LDOPTS)\n"\
	"\n"\
	"%-c.o: %.c\n\t\$$(&core&_CC) \$$(&core&_CC_OPTS) -o \$$@ \$$<\n\n"\
	"%-c.o: ../%.c\n\t\$$(&core&_CC) \$$(&core&_CC_OPTS) -o \$$@ \$$<\n\n"\
	"%-cpp.o: %.cpp\n\t\$$(&core&_CX) \$$(&core&_CX_OPTS) -o \$$@ \$$<\n\n"\
	"%-cpp.o: ../%.cpp\n\t\$$(&core&_CX) \$$(&core&_CX_OPTS) -o \$$@ \$$<\n\n"\
	"%-cc.o: %.cc\n\t\$$(&core&_CX) \$$(&core&_CX_OPTS) -o \$$@ \$$<\n\n"\
	"%-cc.o: ../%.cc\n\t\$$(&core&_CX) \$$(&core&_CX_OPTS) -o \$$@ \$$<\n\n"\
	"%.a:\n\tmake -C \$$(dir \$$@) \$$(notdir \$$@)\n\n"\
	"clean::\n\trm -f $(_&core&_ELF) $(&core&_LIB) \$$(_&core&_APP_OBJS) \$$(_&core&_LIB_OBJS)\n\n"\

file:: &core&file

