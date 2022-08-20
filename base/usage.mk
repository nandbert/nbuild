# -*- tab-width: 4 -*-
#
#  CONTENT
#    make package to create usage() functions from CmdLineOpt matches
#
#  PARAMETERS
#	 none, just add foo-usage.c to your SRCS to get foo.{c|cpp} parsed
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2022-08-02
#
#  LANGUAGE
#    make
#


define _USAGE_GEN
	@echo generating: $@
	@echo -e > $@ "#include <stdio.h>\nvoid $*_usage(FILE *out){static const char *alines[]={\
	\"$* usage:\","
	@awk < $< >> $@ '/CmdLineOpt/ {\
		split($$0,a,"\""); opt=a[2]; if($$0~"//") {\
			split($$0,a,"/"); arg=a[3]; }\
		else{\
			split(a[3],a,"[,)]"); arg=" ("a[2]" args)";}\
		 print "\"-" opt arg "\",";}'
	@echo -e "};\nfor(int i=0;i<sizeof(alines)/sizeof(alines[0]);i++) fprintf(out,\"%s\\\\n\",alines[i]);\n}" >> $@
endef


%-usage.c: ../%.cpp
	$(_USAGE_GEN)

%-usage.c: ../%.c
	$(_USAGE_GEN)

%-usage.c: %.cpp
	$(_USAGE_GEN)

%-usage.c: %.c
	$(_USAGE_GEN)

clean::
	rm -f *-usage.c

