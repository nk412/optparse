#Optparse
A BASH wrapper for getopts and compgen, for simple command-line argument parsing an bash completion.

##What is this?
A wrapper that provides a clean and easy way to parse arguments and create Tab completion to your BASH scripts. It lets you define short and long option names, handle flag variables, set default values for optional arguments and define an optional list of posible values for options to complete, all while aiming to be as minimal as possible: *One line per argument definition*.

##Usage

###1. Source file optparse.bash
###2. Define your arguments
#### Generate scripts for completion an option parsing using optparse.bash.
#### Source profile configuration
##### See `sample_event_generate_completion.sh` for a demonstration.

#### Source the optparse generated file in your command script( The script to parse arguments and generate completion ).
##### See `sample_event.sh` for a demonstration.
### Demo
./sample_event.sh [TAB][TAB]
--name --country --year
./sample_event.sh --country [TAB][TAB]
USA Canada Japan Brasil
./sample_event.sh --name Football World Cup --country Brasil --year 2014
The Football World Cup will be in Brasil in 2014.

Each argument to the script is defined with `optparse.define`, which specifies the option names, a short description, the variable it sets and the default value (if any). 

```bash
optparse.define short=f long=file desc="The input file" variable=filename
```

Flags are defined in exactly the same way, but with an extra parameter `value` that is assigned to the variable. 

```bash
optparse.define short=v long=verbose desc="Set flag for verbose mode" variable=verbose_mode value=true default=false
```

```bash
optparse.define short=f long=file desc="The input file" variable=filename list="word1 word2 word3"
```

```bash
optparse.define short=f long=file desc="The input file" variable=filename list="\$(my_command)"
```

###2. Evaluate your arguments
The `optparse.build` function creates a temporary header script and a configuration file in /etc/bash_completion.d/ based on the provided argument definitions. Simply source the file the function returns and also pass a script name as argument, to parse the arguments and generate completion.

```bash
source $( optparse.build ) script_name
```

####That's it!
The script can now make use of the variables. Running the script (without any arguments) should give you a neat usage description.
    
    usage: ./script.sh [OPTIONS]
    
    OPTIONS:
    
        -f --file  :  The input file
    	-v --verbose  :  Set flag for verbose mode
    
    	-? --help  :  usage
        
##Supported definition parameters
All definition parameters for `optparse.define` are provided as `key=value` pairs, seperated by an `=` sign.
####`short`
a short, single-letter name for the option
####`long`
a longer expanded option name
####`variable`
the target variable that the argument represents
####`value`(optional)
the value to set the variable to. If unspecified, user is expected to provide a value.
####`desc`(optional)
a short description of the argument (to build the usage description)
####`default`(optional)
the default value to set the variable to if argument not specified
####`list`(optional)
the list of posible arguments for an option to autocomplete. It could be a list of strings or a command.

##Installation
1. Download/clone `optparse.bash`
2. Add 

```bash    
`source /path/to/optparse.bash` 
```
to `~/.bashrc`

