#!/bin/bash

set -xe
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function runAnalysis() {
	project=$1
	version=$2
	out=$SCRIPT_DIR/pit.$project.$version.out
	pushd $project
	git checkout pit/$version 2>&1 >>"$out"
	mvn -e clean install 2>&1 >>"$out"
	date >>"$out"
	mvn -e pitest:mutationCoverage 2>&1 >>"$out"
	date >>"$out"
	popd
}

# remove old output files
cd "$SCRIPT_DIR"
rm -f pit.*.out

# run analysis
runAnalysis commons-lang 3.9
runAnalysis commons-lang 3.10
runAnalysis commons-lang 3.11
runAnalysis commons-lang 3.12
