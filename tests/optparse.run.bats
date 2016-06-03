#!/usr/bin/env bats

###############################################################################
# These test cases use the RUN bats keyword.  This is equivalent to running
# the 'run' script right from the shell. The return status is saved as $status, 
# while output is under $output and each line is saved in the $lines array.
#
# For optparse, this requires a wrapper script, which just prints our input
# back to us, so we can verify optparse did everything correctly.  This method
# is for light / simple tests. For more advanced testing, see the 'load' test 
# suite.
# 
# See *tests/interface.bash* for more documentation. Currently supported 
# arguments (from tests/interface.bash --help) are:
#    -i --input:                  The input file. No default
#    -o --output:                 Output file. Default is default_value 
#                                 [default:default_value]
#    -a --attrib:                 Boolean style attribute. [default:false]
#    -d --default-value-with-spaces: An argument which has spaces in it's 
#                     default value [default:default value with spaces]
#    -s --default-value-with-specials: An argument with a few special 
#                     characters in it. A single quote should be handled ok 
#                     [default:this is ' the !@#$%^&*( ${P\} special values]

###############################################################################

# This sets our global mode' nounset should be used instead of print.
#export OPTPARSE_TEST_MODE="nounset"

@test "run with no arguments" {
    run ./tests/interface.bash
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=" ]
    [ "${lines[1]}" = "OUTPUT=default_value" ]
    [ "${lines[2]}" = "ATTRIB=false" ]
}

@test "specify short input argument" {
    run ./tests/interface.bash -i DEADBEEF
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=DEADBEEF" ]
    [ "${lines[1]}" = "OUTPUT=default_value" ]
    [ "${lines[2]}" = "ATTRIB=false" ]
}

@test "specify long input argument" {
    run ./tests/interface.bash --input DEADBEEF
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=DEADBEEF" ]
    [ "${lines[1]}" = "OUTPUT=default_value" ]
    [ "${lines[2]}" = "ATTRIB=false" ]
}

@test "override default argument with shortopt" {
    run ./tests/interface.bash --input DEADBEEF -o OVERRIDDEN 
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=DEADBEEF" ]
    [ "${lines[1]}" = "OUTPUT=OVERRIDDEN" ]
    [ "${lines[2]}" = "ATTRIB=false" ]
}

@test "override default argument with longopt" {
    run ./tests/interface.bash --input DEADBEEF --output OVERRIDDEN 
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=DEADBEEF" ]
    [ "${lines[1]}" = "OUTPUT=OVERRIDDEN" ]
    [ "${lines[2]}" = "ATTRIB=false" ]
}

@test "test boolean value with shortname" {
    run ./tests/interface.bash -a
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=" ]
    [ "${lines[1]}" = "OUTPUT=default_value" ]
    [ "${lines[2]}" = "ATTRIB=true" ]
}

@test "test boolean value with longname" {
    run ./tests/interface.bash --attrib
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=" ]
    [ "${lines[1]}" = "OUTPUT=default_value" ]
    [ "${lines[2]}" = "ATTRIB=true" ]
}

@test "use an invalid argument" {
    run ./tests/interface.bash --unspecified_argument
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Unrecognized long option: --unspecified_argument" ]
}

@test "test if -- stops argument processing" {
    run ./tests/interface.bash -o one -- -o two
    [ "$status" -eq 0 ]
}

@test "test bash set -o nounset - fail when accessing undefined variables" {
    export OPTPARSE_TEST_MODE="nounset"
    run ./tests/interface.bash --input afile -a
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT=afile" ]
    [ "${lines[1]}" = "OUTPUT=default_value" ]
    [ "${lines[2]}" = "ATTRIB=true" ]
}
