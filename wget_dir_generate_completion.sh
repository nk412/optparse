#!/usr/bin/env bash

# Source the optparse.bash file ---------------------------------------------------
source optparse.bash

# Define options
optparse.define short=r long=recursive desc="turn on recursive retrieving." variable=recursive value=true default=false required=true
optparse.define short=c long=continue desc="resume getting a partially-downloaded file." variable=continue value=true default=false
optparse.define short=o long=no-directories desc="Do not preserve directory hierarchy" variable=no_dirs value=true default=false
optparse.define short=h long=no-host-directories desc="Disable generation of host-prefixed directories" variable=no_host_dirs value=true default=false
optparse.define short=n long=no-parent desc="Destination directory to save all files" variable=no_parent value=true default=false required=true
optparse.define short=x long=directory-prefix desc="Destination directory to save all files" variable=directory required=true
optparse.define short=d long=progress desc="Progress indicator you wish to use." variable=progress list="bar dot"
optparse.define short=U long=user-agent desc="identify as agent-string to the HTTP server." variable=agent list="Mozilla"
optparse.define short=i long=cut-dirs desc="ignore number remote directory components." variable=ignore_dirs
optparse.define short=u long=user desc="user to use" variable=user
optparse.define short=p long=password desc="user password." variable=password

# Generate optparse and autocompletion scripts
script_name="wget_dir.sh"
optparse.build $script_name

exit 0

