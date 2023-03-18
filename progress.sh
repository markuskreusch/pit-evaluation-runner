#!/bin/bash

FILE=$(ls -t | grep "pit.commons-lang.3.*.out" | head -n1)
echo $FILE
while true; do echo -en "\r" $(grep "Analysis progress" "$FILE" | tail -n1 | sed -E 's/.*Analysis progress (.*)/\1/'); sleep 1; done
