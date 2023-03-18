#!/bin/bash

cd results
grep '> run mutation analysis : ' pit.commons-lang.3.*.*.*.out \
	| sed -E 's/pit\.commons-lang\.3\.([0-9]+)\.([a-zA-Z]+)\.([0-9]+).out:> run mutation analysis : /\3;3.\1;\2;/' \
	| awk -F ';' 'match($4,/([0-9]+) minutes and ([0-9]+) seconds/,m) { OFS=";"; print $1,$2,$3,(m[1]*60+m[2]) }' \
	| grep -v ';init;'
