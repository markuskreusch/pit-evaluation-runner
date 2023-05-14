#!/bin/bash

set -xe
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function runAnalysis() {
	project=$1
	version=$2
	index=$3
	typ=$4
	out=$SCRIPT_DIR/pit.$project.$version.$typ.$index.out
	metaMutationUnitSize=1
	if [ "$typ" = "metaMutationAnalysisSingle" ]; then
		metaMutationAnalysis=true
	elif [ "$typ" = "metaMutationAnalysisGroup" ]; then
		metaMutatonAnalysis=true
		metaMutationUnitSize=999999
	else
		metaMutationAnalysis=false
	fi
	if [ "$typ" = "prioritiseKillingTests" ]; then
		prioritiseTestsStrategy=DEFAULT_WITH_KILLING_FIRST
	elif [ "$typ" = "prioritiseKillingTestsRandom" ]; then
	  prioritiseTestsStrategy=RANDOM_WITH_KILLING_FIRST
  elif [ "$typ" = "randomTestOrder" ]; then
    prioritiseTestsStrategy=RANDOM
	else
		prioritiseTestsStrategy=DEFAULT
	fi
	git checkout pit/$version >>"$out" 2>&1
	mvn -e clean install >>"$out" 2>&1 || { return 0; }
	date >>"$out"
	set +e
	mvn -e pitest:mutationCoverage -Dpit.metaMutationAnalysis=$metaMutationAnalysis -Dpit.metaMutationUnitSize=$metaMutationUnitSize -Dpit.prioritiseTestsStrategy=$prioritiseTestsStrategy -Dpit.verbose=false >>"$out" 2>&1 || { return 0; }
	set -e
	date >>"$out"
}

# remove old output files
cd "$SCRIPT_DIR"
rm -f pit.*.out

# run analysis

cd commons-lang

for i in $(seq 1 100);
do
	echo "Normal run #$i"
	date
	runAnalysis commons-lang 3.10 $i normal
	runAnalysis commons-lang 3.11 $i normal
	runAnalysis commons-lang 3.12 $i normal
	date

	#echo "Meta Mutation Analysis Single Optimized run #$i"
	#date
	#runAnalysis commons-lang 3.10 $i metaMutationAnalysisSingle
	#runAnalysis commons-lang 3.11 $i metaMutationAnalysisSingle
	#runAnalysis commons-lang 3.12 $i metaMutationAnalysisSingle
	#date

	#echo "Meta Mutation Analysis Group Optimized run #$i"
	#date
	#runAnalysis commons-lang 3.10 $i metaMutationAnalysisGroup
	#runAnalysis commons-lang 3.11 $i metaMutationAnalysisGroup
	#runAnalysis commons-lang 3.12 $i metaMutationAnalysisGroup
	#date

	#echo "Killing Test Priority Optimized run #$i"
	#date
	#runAnalysis commons-lang 3.10 $i prioritiseKillingTests
	#runAnalysis commons-lang 3.11 $i prioritiseKillingTests
	#runAnalysis commons-lang 3.12 $i prioritiseKillingTests
	#date

	echo "Killing Test Priority Random Optimized run #$i"
  date
  runAnalysis commons-lang 3.10 $i prioritiseKillingTestsRandom
  runAnalysis commons-lang 3.11 $i prioritiseKillingTestsRandom
  runAnalysis commons-lang 3.12 $i prioritiseKillingTestsRandom
  date

  echo "Random Test Priority run #$i"
  date
  runAnalysis commons-lang 3.10 $i randomTestOrder
  runAnalysis commons-lang 3.11 $i randomTestOrder
  runAnalysis commons-lang 3.12 $i randomTestOrder
  date
done
