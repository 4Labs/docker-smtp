#!/bin/bash


suffix='_FILE'


# Find all env variables that have a matching env var with the suffix:
#   1) 'env -0' returns the env, separated by null chars instead of newlines (necesssary so that
#      variables that contain newlines and equal signs are handled properly),
#   2) 'grep' with '-z' delimits lines by null chars instead of newlines,
#   3) 'grep' with '-o' returns only the matching portion of a line,
#   4) in PCREs, '(?=...)' is a lookahead: it matches '...' but is not captured,
#   5) 'tr' replaces all null characters in the output with newlines so that we end up with a
#      proper bash array.
env_vars_with_suffix=$(env -0 | grep -Poz "^([^=]+)(?=${suffix}=)" | tr '\0' '\n')


for env_var in $env_vars_with_suffix
do
    suffixed_var="${env_var}_FILE"
    # Using the '!' is bash's parameter extension, meaning filename is now the value of the
    # variable whose name is the value of suffixed_var.
    filename="${!suffixed_var}"
    if [ -f "${filename}" ]; then
        # TODO: handle the case where the file exists but we don't have the permission to access it
        echo "Defined env var ${env_var} using content of ${suffixed_var}=${filename}"
        export $env_var="$(cat "${filename}")"
    else
        echo "Found env var ${suffixed_var} pointing to ${filename} but no such file exists"
    fi
done


if [ -z "${DOCKER_ORIGINAL_ENTRYPOINT}" ]
then
    # If there was no entrypoint in the original image, we just run the "$@", which is basically
    # docker's CMD:
    exec "$@"
else
    # If there was an entrypoint in the original image, we define a DOCKER_ORIGINAL_ENTRYPOINT
    # variable pointing to it, and run it this way:
    exec "${DOCKER_ORIGINAL_ENTRYPOINT}" "$@"
fi
