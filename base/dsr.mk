# -*- tab-width: 4 -*-
##############################################################################
#
# Copyright (c) 2014 Freescale Semiconductor;
#
##############################################################################
#
#  CONTENT
#    make package to create simple dsr files (Data S-Record)
#
#  PARAMETERS
#    DSR_SRCS source files, each source generates a corresponding dsr.
#             allowed source types:
#               .mas (impe assembly with macros)
#               .asm (impe assembly)
#               .c (gnu c)
#               .S (gnu assembly with preprocessing)
#    DSR_DEPENDS a list of headers, on which the .c and .S files depend
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2007-07-13
#
#  LANGUAGE
#    make
#
##############################################################################

ifndef _DSR_MK
_DSR_MK =	true

ifeq ($(origin NBUILD),undefined)
  $(error error: NBUILD undefined)
endif


##############################################################################
# parameters
##############################################################################

ifeq ($(strip $(DSR_SRCS)),)
  $(error error: no DSR_SRCS set)
endif

IMPE_ASM	?= $(TOOLS)/impeasm/impeasm
NMEX    	?= $(TOOLS)/nmex/nmex


ifneq ("$(shell pxe-elf-gcc -mversion 2>&1)","PXE port version 1.2")
  $(error error: error wrong or missing pxe gcc)
endif


##############################################################################
# targets
##############################################################################

_DSR_TRS_MAS =	$(patsubst %.mas,%.dsr,$(filter %.mas,$(DSR_SRCS)))
_DSR_TRS_ASM =	$(patsubst %.asm,%.dsr,$(filter %.asm,$(DSR_SRCS)))
_DSR_TRS_C =	$(patsubst %.c,%.dsr,$(filter %.c,$(DSR_SRCS)))
_DSR_TRS_S =	$(patsubst %.S,%.dsr,$(filter %.S,$(DSR_SRCS)))

# targets using an intermediate elf file
_DSR_TRS_ELF =	$(_DSR_TRS_C) $(_DSR_TRS_S)

# all targets
_DSR_TRS =	$(_DSR_TRS_MAS) $(_DSR_TRS_ASM) $(_DSR_TRS_ELF)


.PHONY: clean all pre_all

pre_all::

all::	pre_all $(_DSR_TRS)

_DSR_CLEANS = $(_DSR_TRS)  \
	$(patsubst %.dsr,%.tsr,$(_DSR_TRS_MAS) $(_DSR_TRS_ASM)) \
	$(patsubst %.dsr,%.sym,$(_DSR_TRS_MAS) $(_DSR_TRS_ASM)) \
	$(patsubst %.dsr,%.log,$(_DSR_TRS_MAS) $(_DSR_TRS_ASM)) \
	$(patsubst %.dsr,%.tas,$(_DSR_TRS_MAS)) \
	$(patsubst %.dsr,%.elf,$(_DSR_TRS_ELF)) \

clean::
	rm -f $(_DSR_CLEANS)


##############################################################################
# implicit rules
##############################################################################

# impe macro assembler
$(_DSR_TRS_MAS): %.dsr : %.mas $(IMPE_ASM)
	@echo "assembling: $@"
	$(NMEX) $< $*.tas $(IMPE_INCS) -I $(TOOLS)/nmex && \
	  $(IMPE_ASM) -w -l -s $*.tas && rm $*.tsr

# impe assembler
$(_DSR_TRS_ASM): %.dsr : %.asm $(IMPE_ASM)
	@echo "assembling: $@"
	$(IMPE_ASM) -w -l -s $< && rm $*.tsr


# from elf file, first attempt

$(_DSR_TRS_ELF): %.dsr: %.elf
	pxe-elf-objcopy -O srec -j .data $< $@

$(patsubst %.dsr,%.elf,$(_DSR_TRS_C)): %.elf: %.c $(DSR_DEPENDS)
	pxe-elf-gcc -march=sne2 -nostartfiles -Xlinker --no-check-sections \
	-Xlinker -N -Xlinker -Tdata -Xlinker 0 $(DSR_INCS) \
	-Xlinker -e -Xlinker 0x42 -o $@ $<

$(patsubst %.dsr,%.elf,$(_DSR_TRS_S)): %.elf: %.S $(DSR_DEPENDS)
	pxe-elf-gcc -march=sne2 -nostartfiles -Xlinker --no-check-sections \
	-Xlinker -N -Xlinker -Tdata -Xlinker 0 $(DSR_INCS) \
	-Xlinker -e -Xlinker 0x42 -o $@ $<


##############################################################################
# variables required by other make packages
##############################################################################

HDEP_SRCS +=	$(DSR_SRCS)

ifneq ($(strip $(_DSR_TRS_MAS) $(_DSR_TRS_ASM)),)
ifeq ($(shell [ -f $(dir $(IMPE_ASM))/Makefile ] && echo true),true)
SUB_MAKES +=	$(dir $(IMPE_ASM))
endif
endif
SUB_DIRS +=		$(subst -I,,$(DSR_INCS)) $(TOOLS)/nmex


##############################################################################
# submakes necessary for bootstrapping
##############################################################################

ifeq ($(_IMPE_MK),)
$(IMPE_ASM):
	make -C $(dir $@) $(notdir $@)
endif

endif
