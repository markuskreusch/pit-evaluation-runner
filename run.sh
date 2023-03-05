#!/bin/bash

set -xe
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function runAnalysis() {
	project=$1
	version=$2
	index=$3
	typ=$4
	out=$SCRIPT_DIR/pit.$project.$version.$typ.$index.out
	if [ "$typ" = "metaMutationAnalysis" ]; then
		metaMutationAnalysis=true
	else
		metaMutationAnalysis=false
	fi
	pushd $project
	git checkout pit/$version >>"$out" 2>&1
	mvn -e clean install >>"$out" 2>&1
	date >>"$out"
	mvn -e pitest:mutationCoverage -Dpit.metaMutationAnalysis=$metaMutationAnalysis >>"$out" 2>&1
	date >>"$out"
	popd
}

# remove old output files
cd "$SCRIPT_DIR"
rm -f pit.*.out

# run analysis


for i in $(seq 1 100);
do
	echo "Init run #$i"
	date
	runAnalysis commons-lang 3.9 $i init
	date

	echo "Normal run #$i"
	date
	runAnalysis commons-lang 3.10 $i normal
	runAnalysis commons-lang 3.11 $i normal
	runAnalysis commons-lang 3.12 $i normal
	date

	echo "Meta Mutation Analysis Optimized run #$i"
	date
	runAnalysis commons-lang 3.10 $i metaMutationAnalysis
	runAnalysis commons-lang 3.11 $i metaMutationAnalysis
	runAnalysis commons-lang 3.12 $i metaMutationAnalysis
	date
done
