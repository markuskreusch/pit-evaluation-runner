#!/bin/bash

set -xe
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function runAnalysis() {
	project=$1
	version=$2
	index=$3
	typ=$4
	out=$SCRIPT_DIR/pit.$project.$version.$typ.$index.out
	if [ "$typ" = "combinedMutantAnalysis" ]; then
		combinedMutantAnalysis=true
	else
		combinedMutantAnalysis=false
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
	mvn -e pitest:mutationCoverage -Dpit.combinedMutantAnalysis=combinedMutantAnalysis -Dpit.prioritiseTestsStrategy=$prioritiseTestsStrategy -Dpit.verbose=false >>"$out" 2>&1 || { return 0; }
	set -e
	date >>"$out"
}

# remove old output files
cd "$SCRIPT_DIR"
rm -f pit.*.out

# run analysis

cd commons-lang


for i in $(seq 1 50);
do
	echo "NonIncremental run #$i"
	date
	rm -f /tmp/pit-history-commons-lang-*.bin
	runAnalysis commons-lang 3.10 $i non-incremental
	rm -f /tmp/pit-history-commons-lang-*.bin
	runAnalysis commons-lang 3.11 $i non-incremental
	rm -f /tmp/pit-history-commons-lang-*.bin
	runAnalysis commons-lang 3.12 $i non-incremental
	rm -f /tmp/pit-history-commons-lang-*.bin
	runAnalysis commons-lang 3.12-1 $i non-incremental
	rm -f /tmp/pit-history-commons-lang-*.bin
	runAnalysis commons-lang 3.12-2 $i non-incremental
	rm -f /tmp/pit-history-commons-lang-*.bin
	runAnalysis commons-lang 3.12-3 $i non-incremental
	date
done

runAnalysis commons-lang 3.9 0 normal

for i in $(seq 1 50);
do
	echo "Normal run #$i"
	date
	runAnalysis commons-lang 3.10 $i normal
	runAnalysis commons-lang 3.11 $i normal
	runAnalysis commons-lang 3.12 $i normal
	runAnalysis commons-lang 3.12-1 $i normal
	runAnalysis commons-lang 3.12-2 $i normal
	runAnalysis commons-lang 3.12-3 $i normal
	date

	echo "Combined Mutation Analysis Optimized run #$i"
	date
	runAnalysis commons-lang 3.10 $i combinedMutantAnalysis
	runAnalysis commons-lang 3.11 $i combinedMutantAnalysis
	runAnalysis commons-lang 3.12 $i combinedMutantAnalysis
	runAnalysis commons-lang 3.12-1 $i combinedMutantAnalysis
	runAnalysis commons-lang 3.12-2 $i combinedMutantAnalysis
	runAnalysis commons-lang 3.12-3 $i combinedMutantAnalysis
	date

	echo "Killing Test Priority Optimized run #$i"
	date
	runAnalysis commons-lang 3.10 $i prioritiseKillingTests
	runAnalysis commons-lang 3.11 $i prioritiseKillingTests
	runAnalysis commons-lang 3.12 $i prioritiseKillingTests
	runAnalysis commons-lang 3.12-1 $i prioritiseKillingTests
	runAnalysis commons-lang 3.12-2 $i prioritiseKillingTests
	runAnalysis commons-lang 3.12-3 $i prioritiseKillingTests
	date

	echo "Killing Test Priority Random Optimized run #$i"
	date
	runAnalysis commons-lang 3.10 $i prioritiseKillingTestsRandom
	runAnalysis commons-lang 3.11 $i prioritiseKillingTestsRandom
	runAnalysis commons-lang 3.12 $i prioritiseKillingTestsRandom
	runAnalysis commons-lang 3.12-1 $i prioritiseKillingTestsRandom
	runAnalysis commons-lang 3.12-2 $i prioritiseKillingTestsRandom
	runAnalysis commons-lang 3.12-3 $i prioritiseKillingTestsRandom
	date

	echo "Random Test Priority run #$i"
	date
	runAnalysis commons-lang 3.10 $i randomTestOrder
	runAnalysis commons-lang 3.11 $i randomTestOrder
	runAnalysis commons-lang 3.12 $i randomTestOrder
	runAnalysis commons-lang 3.12-1 $i randomTestOrder
	runAnalysis commons-lang 3.12-2 $i randomTestOrder
	runAnalysis commons-lang 3.12-3 $i randomTestOrder
	date
done
