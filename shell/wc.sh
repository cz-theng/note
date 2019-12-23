#!/usr/bin/env bash

DS=`find . -type d -maxdepth 1 | sed 's%./%%' | sed 's%\.%%'`
for D in $DS
do
	cd $D
	G=`cloc . | grep "Go" | awk '{print $5}'`
	echo $D":"$G
	cd ..
done
