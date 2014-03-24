#!/bin/bash

# Source the optparse.bash file ---------------------------------------------------
source optparse.bash

# Define options
optparse.define short=n long=name desc="The event name" variable=name list="fgh"
optparse.define short=c long=country desc="The event country" variable=country list="USA Canada Japan Brasil"
optparse.define short=d long=year desc="The event year" variable=year list="2006 2010 2014 2020"

# Generate optparse and autocompletion scripts
script_name="sample_event.sh"
optparse.build $script_name

# Source completion configuration
bash

exit 0
