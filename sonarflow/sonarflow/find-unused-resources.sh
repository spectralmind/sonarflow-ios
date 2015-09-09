#!/bin/bash
find Graphics/ -name "*.png" | xargs basename > resources.list

RESOURCES=`for i in $(cat resources.list) ; do Y=${i%.png} ; Z=${Y%~ipad} ; echo ${Z%@2x} ; done | uniq`
for i in $RESOURCES ; do
	#echo $i
	grep -R $i src/* Interface/* > /dev/null
	NOTFOUND=$?
	if [ $NOTFOUND != 0 ] ; then
		echo $i not found
	fi
done