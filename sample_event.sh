#!/usr/bin/env bash

# Source the sample_event_optparse file ---------------------------------------------------
source sample_event.sh_optparse

if [ -z "$name" ] || [ -z "$country" ] || [ -z "$year" ]; then
   usage; exit 1
fi

# Display event information
echo "The $name event will be in $country in $year."	

exit 0
	
