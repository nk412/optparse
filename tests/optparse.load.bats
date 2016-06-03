#!/usr/bin/env bats

###############################################################################
# These tests use the LOAD method bats to include optparse here and we add 
# options in each test case. 
# Command line arguments are specified by using ```eval set -- <arguments>```
# Example:
#
#     eval set -- -i "input" --output "whatever" -v
#
# **NOTE**: If your testcase fails without any output from bats, then there's
# likely syntax errors on an included file. Check under /tmp for bats.* files.
# The error output will be there. (Also might check for optparse.* files too)
###############################################################################

@test "include optparse from test script" {
    load ../optparse
    #optparse.define short=t long=testing desc="Test attribute" variable="TESTATTRIB" value="true" default="false"
    #eval set --            # Our command line arguments go here
    file=$(optparse.build)
    echo "${file}"  # This echo will show filename if the tests fail
    [ -e "${file}" -a -r "${file}" ]

    # Optparse file was created ok. Run bash -n to lint the file & verify we don't have any errors
    run bash -n "${file}" # Lint check
    [ "$status" -eq 0 ]

    # Looks good. Now we could just rm it, but let's just source it, and let it remove itself, eh?
    source "${file}"

    # Make sure it removed itself
    [ ! -e "${file}" ]
}

@test "verify basic usage output with --help" {
    load ../optparse
    optparse.define short=t long=testing desc="Test_attribute_description" variable="TESTATTRIB" value="true" default="false"
    eval set -- --help
    file=$(optparse.build)
    output=`source <(cat "${file}")`;
    [[ "$output" == usage:* && "$output" == *--testing* && "$output" == *Test_attribute_description* ]]
}
