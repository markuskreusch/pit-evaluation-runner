#!/bin/bash
while true; do echo -en "\r" $(grep "Analysis progress" "$1" | tail -n1 | sed -E 's/.*Analysis progress (.*)/\1/'); sleep 1; done
