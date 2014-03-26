# Optparse - a BASH wrapper for getoptions
# @author : nk412 / nagarjuna.412@gmail.com

optparse_usage=""
optparse_contractions=""
optparse_defaults=""
optparse_process=""
optparse_arguments_string=""
optparse_process_completion=""
options=""

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
                elif [ "$key" = "list" ]; then
                        local list="$value"
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
                optparse_defaults="${optparse_defaults}#NL${variable}=${default}"
        fi
        optparse_arguments_string="${optparse_arguments_string}${shortname}"
        if [ "$val" = "\$OPTARG" ]; then
                optparse_arguments_string="${optparse_arguments_string}:"
        fi
        optparse_process="${optparse_process}#NL#TB#TB${shortname})#NL#TB#TB#TB${variable}=\"$val\";;"

        # Complete options
        options="${options} ${long}"
        # Complete command arguments
        if [ "$list" != "" ]; then
                optparse_process_completion="${optparse_process_completion}#NL#TB#TB--${variable})#NL#TB#TB#TB${variable}_list=\"$list\"#NL#TB#TB#TBCOMPREPLY=( \$(compgen -W \"\${${variable}_list}\" -- \${cur}) )#NL#TB#TB#TBreturn 0;;"
        fi

}

# -----------------------------------------------------------------------------------------------------------------------------
function optparse.build(){
        local script=${1:?}
        local build_file="${script}_optparse"
        local completion_dir="$HOME/.bash_completion.d/"
        local completion_file="${completion_dir}${script}"

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

EOF

# Create completion script
mkdir -p $completion_dir
        cat << EOF > $completion_file
_$script(){
        local cur prev options
        COMPREPLY=()
        cur=\${COMP_WORDS[COMP_CWORD]}
        prev=\${COMP_WORDS[COMP_CWORD-1]}

        # The basic options we'll complete.
        options="${options}"

        # Complete the arguments to some of the basic commands.
        case \$prev in
                $optparse_process_completion
                *)
        esac
        COMPREPLY=(\$(compgen -W "\${options}" -- \${cur}))
        return 0
}
complete -F _$script $script
EOF

        local -A o=( ['#NL']='\n' ['#TB']='\t' )

        for i in "${!o[@]}"; do
                sed -i "s/${i}/${o[$i]}/g" $build_file
                sed -i "s/${i}/${o[$i]}/g" $completion_file
        done

        # Unset global variables
        unset optparse_usage
        unset optparse_process
        unset optparse_arguments_string
        unset optparse_defaults
        unset optparse_contractions
        unset options
}
# -----------------------------------------------------------------------------------------------------------------------------
