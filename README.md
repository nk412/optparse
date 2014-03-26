#Optparse
A BASH wrapper for getopts and compgen, for simple command-line argument parsing an bash completion.

##What is this?
A wrapper that provides a clean and easy way to parse arguments and create Tab completion to your BASH scripts. It lets you define short and long option names, handle flag variables, set default values for optional arguments and an optional list of posible values for options to complete, all while aiming to be as minimal as possible: *One line per argument definition*.

##Usage
###1. Install bash-completion package.
###2. Create a script to generate completion and option parsing files.
###3. Source file optparse.bash in the script.
###4. Define your arguments in the script.

Each argument to the script is defined with `optparse.define`, which specifies the option names, a short description, the variable it sets, the default value (if any) and a list of posible values (if any).

```bash
optparse.define short=f long=file desc="The input file" variable=filename
```

Flags are defined in exactly the same way, but with an extra parameter `value` that is assigned to the variable. 

```bash
optparse.define short=v long=verbose desc="Set flag for verbose mode" variable=verbose_mode value=true default=false
```

```bash
optparse.define short=f long=file desc="The input file" variable=filename list="string1 string2 string3"
```

```bash
optparse.define short=f long=file desc="The input file" variable=filename list="\$(my_command)"
```

###5. Evaluate your arguments
The `optparse.build` function creates a header script and a configuration file in $HOME/.bash_completion.d/ based on the provided argument definitions.

```bash
optparse.build script_name
```

###5. Allow execution to the script and execute it.
##### See `sample_event_generate_completion.sh` for a demonstration.
###6. Source profile bash completion configuration, example:
```bash
$ source  $HOME/.bash_completion.d/*
```

###7. In your command script( The script to parse arguments and generate completion ) source the optparse generated file to parse and evaluate arguments.

####That's it!
The script can now show completion and make use of the variables. Running the script (without any arguments) should give you a neat usage description.
    
    usage: ./script.sh [OPTIONS]
    
    OPTIONS:
    
        -n --name  :  The event name
    	-c --country  :  The country name
    	-y --year  :  The year
    
    	-? --help  :  usage

##### See `sample_event.sh` for a demonstration.
### Now to use the command script we can write:
```bash
$ ./sample_event.sh [TAB][TAB]
$ --name --country --year
$ ./sample_event.sh --country [TAB][TAB]
$ USA Canada Japan Brasil
$ ./sample_event.sh --name "Football World Cup" --country Brasil --year 2014
$ The Football World Cup will be in Brasil in 2014.
```

     
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

