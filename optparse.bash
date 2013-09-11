optparse_usage="" 
optparse_contractions=""
optparse_defaults=""
optparse_process=""
optparse_arguments_string=""

function optparse.throw_error(){
  local message="$1"
	echo "OPTPARSE: ERROR: $message"
	exit 1
}

function optparse.define(){
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
			short="-${shortname}"
		elif [ "$key" = "long" ]; then
			local longname="$value"
			if [ ${#longname} -lt 2 ]; then 
				optparse.throw_error "long name expected to be atleast one character long"
			fi
			long="--${longname}"
		elif [ "$key" = "desc" ]; then
			local desc="$value"
		elif [ "$key" = "default" ]; then
			local default="$value"
		elif [ "$key" = "variable" ]; then
			local variable="$value"
		elif [ "$key" = "value" ]; then
			local val="$value"
			if [ "$val" = "optarg" ]; then
				val="\$OPTARG"
			fi
		fi
	done;

  if [ "$variable" = "" ]; then
		optparse.throw_error "You're supposed to give a variable, dummy! ($short/$long)"
	fi
	if [ "$val" = "" ]; then
		optparse.throw_error "Give a value to set, silly! ($short/$long)"
	fi
	
	# build OPTIONS and help
	optparse_usage="${optparse_usage}\n\t${short} ${long}  :  ${desc}"
	optparse_contractions="${optparse_contractions}\n\t\t${long})\n\t\t\tparams=\"\$params ${short}\";;"
	if [ "$default" != "" ]; then
		optparse_defaults="${optparse_defaults}\n${variable}=${default}"
	fi
	optparse_arguments_string="${optparse_arguments_string}${shortname}"
	if [ "$val" = "\$OPTARG" ]; then
		optparse_arguments_string="${optparse_arguments_string}:"
	fi
	optparse_process="${optparse_process}\n\t${shortname})\n\t\t${variable}=\"$val\";;"
}

function optparse.build(){
  local build_file="/tmp/optparse-${RANDOM}.tmp"

	# Building getopts header here
 
	# Function usage
	echo -e "function usage(){\n\tcat << EOF\nusage: \$0 [OPTIONS]\n\nOPTIONS:" > $build_file
	echo -e "$optparse_usage" >> $build_file
	echo -e "\n\t-? --help  :  usage" >> $build_file
	echo -e "\nEOF\n}\nif [ \$# -eq 0 ]; then usage ; exit 1 ; fi\n" >> $build_file
	
	# Contract long options into short options
	echo -e "params=\"\"\nfor param in \$*; do\ncase \"\$param\" in\n" >> $build_file
	echo -e "$optparse_contractions" >> $build_file
	echo -e "\"-?\"|--help)\nusage\nexit 0;;" >> $build_file
	echo -e "*)\nif [[ \"$param\" == --* ]]; then" >> $build_file
	echo -e "echo -ne \"Unrecognized long option: \$param\n\n\"" >> $build_file
	echo -e "usage; exit 1;" >> $build_file
	echo -e "fi\nparams=\"\$params \$param\";;\nesac\ndone\neval set -- \"\$params\"" >> $build_file

	# Set default variable values
	echo -e "$optparse_defaults" >> $build_file
	
	# Process using getopts
	echo -e "while getopts \"$optparse_arguments_string\" option; do" >> $build_file
	echo -e "case \$option in" >> $build_file
	# Substitute actions for different variables
	echo -e "$optparse_process" >> $build_file
	echo -e ":)\necho \"Option - \$OPTARG requires an argument\";exit 1;;" >> $build_file
	echo -e "*)\nusage ; exit 1;; esac ; done" >> $build_file
	
	# Unset global variables
	unset $optparse_usage
	unset $optparse_process
	unset $optparse_arguments_string
	unset $optparse_defaults
	unset $optparse_contractions
	
	# Return file name to parent
	echo "$build_file"	
}
