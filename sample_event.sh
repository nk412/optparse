#!/usr/bin/env bash

# Source the sample_event_optparse file ---------------------------------------------------
source sample_event.sh_optparse

# Take options enter by user
tr ' ' '\n' <<< "$@" | grep "\-" | sed -e 's/=.*//g' | sort > /tmp/options_entered

# Compare options defined as required with options enter by user to obtain missing options
missing_options=$( tr ' ' '\n' <<< "$required_short_options" | sort | comm -32 - /tmp/options_entered | tr '\n' ' ' )

if [ -n "$missing_options" ]; then
   echo "Missing required option: $missing_options"
   usage;
   exit 1;
else

    # Display event information
    if [[ "$say_hello" == "true" ]]; then
        salute="Hello!!! "
    fi
	echo $salute "The $name event will be in $country in $year."
    exit 0
fi



	
