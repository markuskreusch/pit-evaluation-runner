#!/bin/bash

set -xe

function runAnalysis() {
	version=$1
	out=../pit-commons-lang-$version.out
	git checkout pit/$version 2>&1 >$out
	mvn -e clean install 2>&1 >$out
	date >$out
	mvn -e pitest:mutationCoverage 2>&1 >$out
	date >$out
}

cd commons-lang

runAnalysis 3.9
runAnalysis 3.10
runAnalysis 3.11
runAnalysis 3.12
