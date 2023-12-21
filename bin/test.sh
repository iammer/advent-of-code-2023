#!/usr/bin/env bash

set -e

tests=${@-day*}

for day in $tests; do
	pushd $day
	part_1=$(find -executable -name '*a.*')
	echo "Running $part_1"
	diff answer1 <($part_1 < input)
	echo "Success"

	part_2=$(find -executable -name '*b.*')
	echo "Running $part_2"
	diff answer2 <($part_2 < input)
	echo "Success"
	popd
done
