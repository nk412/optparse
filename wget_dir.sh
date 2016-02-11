#!/usr/bin/env bash

# Source the sample_event_optparse file ---------------------------------------------------
source wget_dir.sh_optparse

# Command
cmd="wget"

# Take options enter by user
tr ' ' '\n' <<< "$@" | grep "\-" | sed -e 's/=.*//g' | sort > /tmp/options_entered

# Compare options defined as required with options enter by user to obtain missing options
missing_options=$( tr ' ' '\n' <<< "$required_short_options" | sort | comm -32 - /tmp/options_entered | tr '\n' ' ' )

if [ -n "$missing_options" ]; then
   echo "Missing required option: $missing_options"
   usage;
   exit 1;
else
    # Add options and parameters to command
    for option in "$@"
    do
        if [ -z "${hash_options[$option]}" ]; then
            cmd="$cmd $option"
        else
            cmd="$cmd ${hash_options[$option]}"
        fi
    done
    # Execute command
    echo "Executing command: "
    echo "$cmd"
    eval "$cmd"
    exit 0
fi

