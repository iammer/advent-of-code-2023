#!/bin/bash
echo $( sed -e 's/one/on1e/g' \
		-e 's/two/tw2o/g' \
		-e 's/three/thr3ee/g' \
		-e 's/four/fo4ur/g' \
		-e 's/five/fi5ve/g' \
		-e 's/six/si6x/g' \
		-e 's/seven/sev7en/g' \
		-e 's/eight/eig8ht/g' \
		-e 's/nine/ni9ne/g' | \
		sed -n -e 's/^[^0-9]*\([0-9]\).*\([0-9]\)[^0-9]*$/\1\2+/p' \
			-e 's/^[^0-9]*\([0-9]\)[^0-9]*$/\1\1+/p'
	) 0 | bc
