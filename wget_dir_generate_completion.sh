#!/usr/bin/env bash

# Source the optparse.bash file ---------------------------------------------------
source optparse.bash

# Define options
optparse.define short=r long=recursive desc="Turn on recursive retrieving." variable=recursive value=true default=false required=true
optparse.define short=c long=continue desc="Resume getting a partially-downloaded file." variable=continue value=true default=false
optparse.define short=o long=no-directories desc="Do not preserve directory hierarchy" variable=no_dirs value=true default=false
optparse.define short=h long=no-host-directories desc="Disable generation of host-prefixed directories" variable=no_host_dirs value=true default=false
optparse.define short=n long=no-parent desc="Do not ever ascend to the parent directory" variable=no_parent value=true default=false required=true
optparse.define short=x long=directory-prefix desc="Destination directory to save all files" variable=directory file=true required=true
optparse.define short=d long=progress desc="Progress indicator you wish to use." variable=progress list="bar dot"
optparse.define short=U long=user-agent desc="Identify as agent-string to the HTTP server." variable=agent list="Mozilla"
optparse.define short=i long=cut-dirs desc="Ignore number remote directory components." variable=ignore_dirs
optparse.define short=u long=user desc="User to use" variable=user
optparse.define short=p long=password desc="User password." variable=password

# Generate optparse and autocompletion scripts
script_name="wget_dir.sh"
optparse.build $script_name

exit 0

