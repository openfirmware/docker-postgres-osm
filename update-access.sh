# Modify auth file to allow all from any host. This is okay with a
# container that doesn't publish its ports.
#!/bin/bash
set -e

{ echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf

