#!/bin/bash

if [ "$1" == "" ]; then
	cd results
else
	cd "$1"
fi

echo "run;version;scenario;time;mutants;killed;incremental;combinedTime;combined;filteredConflicts;killingPrioritized"
for file in pit.commons-lang.*.*.*.out; do
	version=$(echo "$file" | sed -E 's/pit\.commons-lang\.(3\.[^.]+)\..*/\1/g')
	scenario=$(echo "$file" | sed -E 's/pit\.commons-lang\.3\.[^.]+\.([a-zA-Z-]+)\..*/\1/g')
	run=$(echo "$file" | sed -E 's/.*\.([0-9]+)\.out$/\1/g')
	time=$(grep '> run mutation analysis : ' "$file" \
		| awk 'match($0,/([0-9]+) minutes and ([0-9]+) seconds/,m) { print (m[1]*60+m[2]) }')
	mutantsAndKilled=$(grep -E '>> Generated [0-9]+ mutations Killed [0-9]+' "$file")
	mutants=$(echo "$mutantsAndKilled" \
		| sed -E 's/>> Generated ([0-9]+) mutations.*/\1/g')
	killed=$(echo "$mutantsAndKilled" \
		| sed -E 's/>> Generated [0-9]+ mutations Killed ([0-9]+) .*/\1/g')
	incremental=$(grep 'Incremental analysis reduced number of mutations by ' "$file" \
		| tail -n 1 \
		| sed -E 's/.*Incremental analysis reduced number of mutations by ([0-9]+).*/\1/g')
	combinedTime=$(grep 'Meta mutation analysis took' "$file" \
		| sed -E 's/.*Meta mutation analysis took ([0-9]+)s.*/\1/g')
	combined=$(grep -E 'mutations marked as SURVIVED by (meta|combined) mutation analysis' "$file" \
		| sed -E 's/.* ([0-9]+) mutations marked .*/\1/g')
	filteredConflicts=$(grep 'conflicting, choosing one at random' "$file" \
		| sed -E 's/.*([0-9]+) conflicting.*/\1/g' \
		| awk 'BEGIN { sum = 0 }; { sum += $1 - 1 }; END { print sum }')
	killingPrioritized=$(grep 'Prioritized killing test' "$file" | wc -l)

	if [ "$mutants" != "" ]; then
		echo "$run;$version;$scenario;$time;$mutants;$killed;$incremental;$combinedTime;$combined;$filteredConflicts;$killingPrioritized"
	fi
done
