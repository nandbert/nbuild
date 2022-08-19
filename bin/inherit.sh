#!/bin/bash
##############################################################################
#
#  CONTENT
#    inherit build flavors
#
#  AUTHOR
#    Norbert Stoeffler
#
#  DATE
#    2016
#
#  LANGUAGE
#    bash
#
##############################################################################

makefiles="Makefile GNUmakefile makefile"

##############################################################################

usage()
{
    setvars
    echo usage: `basename $0` "[<options>] <flavor pattern>"
    echo "options:"
    echo "       -l: local, search flavors outside nbuild (on same level)"
    echo "       -g: global, ignore NBFLAVORS"
    echo "       -f: force, overwrite existing Makefile"
    echo "       -c: copy template Makefile instead of generating include"
    echo "       -n <file>: update the NBUILD path in <file>"
    echo "       -u: update Makefile in the current dir"
    echo available flavors in $src:
    ls $src | grep "^o-" | sed 's/o-/  /g'
    echo inherited flavors in current dir:
    ls | grep "^o-" | sed 's/o-/  /g'
    exit 1
}


##############################################################################

DLOG()
{
    [ "$debug" = yes ] && echo "	DLOG> $@"
}


##############################################################################


# nbuild
fnb()
{
    if [ "$NBUILD" = "" ]
    then
	me=`readlink -f "$1"`
	NBUILD=`readlink -m $me/../..`
    fi
    nb=$(realpath --relative-to $(pwd) "$NBUILD")
    DLOG using nbuild in: "$nb"
}


# set nb and src
setvars()
{
    # find nbuild
    fnb $0

    if [ "$NBFLAVORS" != "" -a "$global" != "yes" ]
    then
	src=$(realpath --relative-to $(pwd) $NBFLAVORS)
    else
	src=$nb$local/flavors
    fi
}


# create forward makefiles
forward()
{
    # cleanup the arguments
    arg=`echo "$@" | awk '{gsub("o-","",$0); for(i=1;i<=NF;i++) printf("o-%s ",$i); }'`
    	DLOG forward / cleaned args: "$arg"
    # find flavors matching the argument
    ff=`cd $src ; ls -d $arg` ; DLOG forward / found flavors: "$ff"
    for i in $ff
    do
	(
	    # not only updating? then create the flavor dir
	    if [ "$up" != yes ]
	    then
	        if [ ! -d $i ]
	        then
	    	    echo creating $i
	    	    mkdir $i
	        fi

		# step into flavor dir
       		cd $i
       		src=../$src
	    fi

       	    # remove old dependency files, might have changed when updating
       	    rm -f .*.d
       	    
       	    # tell what we do
       	    if [ "$copy" = yes ]
       	    then
       	        echo creating copies in $i
       	    else
       	        echo creating forward in $i
       	    fi
       	    
       	    DLOG forward / pwd: `pwd`
       	    
       	    # now do the actual job: link or copy all makefiles found in the src flavor dir
       	    for j in $makefiles
       	    do
       	        DLOG forward / j: "$j"
       	        DLOG forward / src/i/j "$src/$i/$j"
       	        if [ -f $src/$i/$j ]
       	        then
       	    	printf "  %s" $j
       	    	if [ -f $j -a "$force" != yes ]
       	    	then
       	    	    printf " -> exists, skipping\n"
       	    	else
       	    	    if [ -f $j ] ; then printf " (forced)"; fi
       	    	    echo
       	    	    if [ "$copy" = yes ]
       	    	    then
       	    		cp "$src/$i/$j" $j
       	    	    else
       	    		echo "include $src/$i/$j" > $j
       	    	    fi
       	    	fi
       	        fi
       	    done
       	    
       	    # leave the flavor dir
    	)
    done
}


# insert or update the NBUILD variable into (Make)file $1
nbset()
{
    nb="$nb" # was ../$nb, lets see
    if grep -q "^NBUILD.*=" "$1" 2>/dev/null
    then
	echo $1: resetting NBUILD to $nb
	sed -i "s|NBUILD[[:blank:]]*=[[:blank:]]*.*|NBUILD =	$nb|g" $1
    else
	echo $1: inserting NBUILD to $nb after header
	awk -i inplace -vnb=$nb '{
	   	if( $0 !~ "[[:blank:]]*#" && !done) 
            	{ 
                    printf("NBUILD =\t%s\n",nb);
                    done=1 ;
	        }
	        print;
            }' $1
    fi
}


##############################################################################
# MAIN

# called w/o parameters
if [ $# = 0 ] ; then
    usage
    exit 1
fi

# parse options
while getopts hde:fclgr:n:u opt
do
    case "$opt" in
	\?) # unknown flag
	    usage;;
	h)  usage;;
	d)  debug=yes;;
	e)  echo $OPTARG ;;
	f)  force=yes ;;
	c)  copy=yes ;;
	l)  local=/.. ;;
	g)  global=yes ;;
	r)  recursive=$OPTARG ;;
	n)
	    setvars
	    nbset $OPTARG
	    exit 0
	    ;;
	u)
	    up=yes;
	    force=yes;
	    dir=`pwd`
	    flavors=`basename $dir`
	    ;;
    esac
done
shift `expr $OPTIND - 1`

setvars
flavors=${flavors:-"$@"}

DLOG "nb: $nb src: $src flavors: $flavors"

if [ "$recursive" = "" ]
then
    [ "$flavors" != "" ] && forward "$flavors"
else
    find . -name "$recursive" |
	while read d
	do
	    (
		cd `dirname $d`
		pwd
		setvars
		forward "$flavors"
	    )
	done
fi




