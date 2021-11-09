# Optparse - a BASH wrapper for getopts
# https://github.com/nk412/optparse

# Copyright (c) 2015 Nagarjuna Kumarappan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Author: Nagarjuna Kumarappan <nagarjuna.412@gmail.com>

optparse_usage=""
optparse_contractions=""
optparse_defaults=""
optparse_process=""
optparse_arguments_string=""

# -----------------------------------------------------------------------------------------------------------------------------
function optparse.throw_error(){
  local message="$1"
        echo "OPTPARSE: ERROR: $message"
        exit 1
}

# -----------------------------------------------------------------------------------------------------------------------------
function optparse.define(){
        if [ $# -lt 3 ]; then
                optparse.throw_error "optparse.define <short> <long> <variable> [<desc>] [<default>] [<value>]"
        fi
        for option_id in $( seq 1 $# ) ; do
                local option="$( eval "echo \$$option_id")"
                local key="$( echo $option | awk -F "=" '{print $1}' )";
                local value="$( echo $option | awk -F "=" '{print $2}' )";

                #essentials: shortname, longname, description
                if [ "$key" = "short" ]; then
                        local shortname="$value"
                        if [ ${#shortname} -ne 1 ]; then
                                optparse.throw_error "short name expected to be one character long"
                        fi
                        local short="-${shortname}"
                elif [ "$key" = "long" ]; then
                        local longname="$value"
                        if [ ${#longname} -lt 2 ]; then
                                optparse.throw_error "long name expected to be atleast one character long"
                        fi
                        local long="--${longname}"
                elif [ "$key" = "desc" ]; then
                        local desc="$value"
                elif [ "$key" = "default" ]; then
                        local default="$value"
                elif [ "$key" = "variable" ]; then
                        local variable="$value"
                elif [ "$key" = "value" ]; then
                        local val="$value"
                fi
        done

        if [ "$variable" = "" ]; then
                optparse.throw_error "You must give a variable for option: ($short/$long)"
        fi

        if [ "$val" = "" ]; then
                val="\$OPTARG"
        fi

        # build OPTIONS and help
		optparse_usage="${optparse_usage}#NL#TB${short} $(printf "%-25s %s" "${long}:" "${desc}")"
        if [ "$default" != "" ]; then
                optparse_usage="${optparse_usage} [default:$default]"
        fi
        optparse_contractions="${optparse_contractions}#NL#TB#TB${long})#NL#TB#TB#TBparams=\"\$params ${short}\";;"
        if [ "$default" != "" ]; then
                default=${default//\'/\'\\\'\'};
                optparse_defaults="${optparse_defaults}#NL${variable}='${default}'"
        else
                optparse_defaults="${optparse_defaults}#NL${variable}=''"
        fi
        optparse_arguments_string="${optparse_arguments_string}${shortname}"
        if [ "$val" = "\$OPTARG" ]; then
                optparse_arguments_string="${optparse_arguments_string}:"
        fi
        optparse_process="${optparse_process}#NL#TB#TB${shortname})#NL#TB#TB#TB${variable}=\"$val\";;"
}

# -----------------------------------------------------------------------------------------------------------------------------
function optparse.build(){
        local build_file="$(mktemp -t "optparse-XXXXXX.tmp")"

        # Building getopts header here

        # Function usage
        cat << EOF > $build_file
function usage(){
cat << XXX
usage: \$0 [OPTIONS]

OPTIONS:
        $optparse_usage

        -? --help  :  usage

XXX
}

# Contract long options into short options
params=""
while [ \$# -ne 0 ]; do
        param="\$1"
        shift

        case "\$param" in
                $optparse_contractions
                "-?"|--help)
                        usage
                        exit 0;;
                *)
                        if [[ "\$param" == --* ]]; then
                                echo -e "Unrecognized long option: \$param"
                                usage
                                exit 1
                        fi
                        params="\$params \"\$param\"";;
        esac
done

eval set -- "\$params"

# Set default variable values
$optparse_defaults

# Process using getopts
while getopts "$optparse_arguments_string" option; do
        case \$option in
                # Substitute actions for different variables
                $optparse_process
                :)
                        echo "Option - \$OPTARG requires an argument"
                        exit 1;;
                *)
                        usage
                        exit 1;;
        esac
done

# Clean up after self
rm $build_file

EOF

        local -A o=( ['#NL']='\n' ['#TB']='\t' )

        for i in "${!o[@]}"; do
                sed -i "s/${i}/${o[$i]}/g" $build_file
        done

        # Unset global variables
        unset optparse_usage
        unset optparse_process
        unset optparse_arguments_string
        unset optparse_defaults
        unset optparse_contractions

        # Return file name to parent
        echo "$build_file"
}
# -----------------------------------------------------------------------------------------------------------------------------
