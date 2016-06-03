#!/usr/bin/env bash
#
# This is a command line interface to optparse for testing. 
# It just prints the input that was parsed after calling optparse.build
# 3 arguments are currently available. INPUT, OUTPUT and ATTRIB
#
# MODES
# Different modes can be activated using the environment variable
# OPTPARSE_TEST_MODE. Use export OPTPARSE_TEST_MODE="mode" to change.
# Possible values are:
# print - Just print input to output, with no requirements (Default)
# nounset - Set the nounset option (fail when accessing undefined variables), 
#       then call *print* like default
# require - Use some required options (not implemented yet...)

# Path variables
SCRIPT_FILE=${0};
TESTS_DIR=$(dirname $(realpath "${SCRIPT_FILE}"));
SRC_FILE=$(realpath "${TESTS_DIR}/../optparse.bash");
source "${SRC_FILE}" || { echo "ERROR: Could not load script source." && exit 1; }

# Check environment variable OPTPARSE_TEST_MODE for requested mode, 
# and call mode_{requested_mode} function
main() {

    case "${OPTPARSE_TEST_MODE:=print}" in
        require)
            mode_require
            ;;
        nounset)
            set -o nounset
            mode_print "$@"
            ;;
        *)
            mode_print "$@"
    esac
}

mode_require() {
    echo "Mode require"
}

mode_print() {
    optparse.define short=i long=input desc="The input file. No default" required="true" variable=INPUT value=""
    optparse.define short=o long=output desc="Output file. Default is default_value" variable=OUTPUT default="default_value"
    optparse.define short=a long=attrib desc="Boolean style attribute." variable="ATTRIB" value="true" default="false"
#    optparse.define short=d long=default-value-with-spaces desc="An argument which has spaces in it's default value" variable=DEFAULT_WITH_SPACES default="default value with spaces"
#    optparse.define short=s long=default-value-with-specials desc="An argument with a few special characters in it. A single quote should be handled ok" variable=DEFAULT_WITH_SPECIALS default="this is ' the !@#$%^&*( \${P\} special values"    
    source $(optparse.build);

    echo "INPUT=${INPUT}";
    echo "OUTPUT=${OUTPUT}";
    echo "ATTRIB=${ATTRIB}";
    echo "DEFAULT_WITH_SPACES=${DEFAULT_WITH_SPACES}";
    echo "DEFAULT_WITH_SPECIALS=${DEFAULT_WITH_SPECIALS}"
}

main "$@"






