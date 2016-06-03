# Contributor / development notes

## Known issues

- ~~Breaks with nounset enabled~~
- ~~Default values containing spaces breaks script~~

## Unit tests

Tests are written using BATS (Bash Automated Testing System). On my Ubuntu 
box, bats was available in APT, so just an *apt-get install bats* set it up for
me. YYMV, but check your package manager before installing from source. 

Bash Automated Testing System:   
https://github.com/sstephenson/bats   

### Running test

Tests must be run from the project root. All paths used in testing must also be
from the project root. 

```bash
bats tests/
```

Should probably create a Makefile to do this someday...but it's pretty easy to
remember as is...   

### Debugging

Test assertion failures should be printed right to the screen when running bats. 
However, if bats encounters a syntax error when processing a sourced / included 
file (which is pretty frequent), then you won't get any output

#### If your test case fails, but you don't get a message

Check for /tmp/bats.* files.  If bats gets an error when sourcing / including other
files, it chokes & saves output under /tmp in a new file like bats.<random number>.out


## Execution Workflow

Just a description of how this script runs. It seemed a bit cryptic at first, but once you get
the idea, it's really straight forward. 

- Script is source and included as normal
- Calls to optparse.define are made:
  - Each call runs a parser loop to turn key=val assignments into local variables
  - local variables are short, shortname, long, longname, variable, default, val
  - Next we build multi line strings.  Which are actually bash code. They will later be written to a file and executed to do the parsing. 
  - **optparse_usage**
    - Generates each help line for each define method
  - **optparse_contrations**
    - This builds the lookup section of a CASE statement below
    - Used for converting longopts into shortopts
    - Triggers the call to **usage** when --help is found
    - Catch all / default will detect unrecognized options & throw an error
    - In future versions, this should handle variable assignment, instead of relying on getopts. Which will also add longname only support without a shortname.
  - **optparse_defaults**
    - Sets up our local variable defaults
    - In original optparse, only args with default values are specified here (No initializations)
    - In new version, all variables defined are initialized here, with an empty string if no default has been specified.  This fixes support for bash's nounset option
  - **optparse_arguments_string**
    - The getops shortname only argument string (like: "io:uay:p")
    - This should be removed in upcoming versions...
  - **optparse_process**
    - This is the assignment done inside the getopts CASE statement.
    - Handles assigning the user specified value to the local variable. 
    - In future versions, the logic here should be moved to the **optparse_contractions** segment.
- After all arguments are defined, we call .build or .run to do argument to variable assignments
  - ```source $(optparse.build)```
  - In older versions, the .build method is used, to create a local temp file of valid bash code, which is then executed. 
  - In future versions, we will just return the code to be executed and run it using process substitution. ```source <(optparse.run)```. This saves us from creating a temp file on every run. 
  - For backwards compatibility, the build method will still be available.
  - Currently, creates a temp file like /tmp/optparse.<randomnumber>.tmp:
    - usage() definition
    - optparse_contraction - assigns shortop codes when longopts are used 
    - ```eval set -- params``` # This sets our input parameters. Since our nested script isn't passed the shell arguments
    - optparse_defaults - Default assignments & local variable initilization
    - getopts processing (legacy)
      - Assigns local variables to user specified args via getops CASE statement
    - Removes the local optparse.tmp script, since it's not longer needed at this point.

