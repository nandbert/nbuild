# -*- tab-width: 4 -*-
#
#  CONTENT
#    generate a package with core specific names from the common _core
#    template
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2011-04-04
#
#  LANGUAGE
#    make
#


$(NBUILD)/base/.%.mk: $(NBUILD)/base/_core.mk
	@echo core.mk: generating $@
	$(NBQ)echo "# don't edit, generated from $(notdir $^)" > $@
	$(NBQ)sed >> $@ < $^ "s/&core&/$*/g"
	$(NBQ)rm -f .makefile.d # invalid if created before corelib
