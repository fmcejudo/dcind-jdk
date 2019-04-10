#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- docker "$@"
fi

# if our command is a valid Docker subcommand, let's invoke it through Docker instead
# (this allows for "docker run docker ps", etc)
if docker help "$1" > /dev/null 2>&1; then
	set -- docker "$@"
fi

# if we have "--link some-docker:docker" and not DOCKER_HOST, let's set DOCKER_HOST automatically
if [ -z "$DOCKER_HOST" -a "$DOCKER_PORT_2375_TCP" ]; then
	export DOCKER_HOST='tcp://docker:2375'
fi

if [ "$1" = 'dockerd' ]; then
	cat >&2 <<-'EOW'

		📎 Hey there!  It looks like you're trying to run a Docker daemon.

		   You probably should use the "dind" image variant instead, something like:

		     docker run --privileged --name some-overlay-docker -d docker:stable-dind --storage-driver=overlay

		   See https://hub.docker.com/_/docker/ for more documentation and usage examples.

	EOW
	sleep 3
fi

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	# add our default arguments
	set -- dockerd \
		--host=unix:///var/run/docker.sock \
		--host=tcp://0.0.0.0:2375 \
		"$@"
fi

if [ "$1" = 'dockerd' ]; then
	# if we're running Docker, let's pipe through dind
	set -- "$(which dind)" "$@"

	# explicitly remove Docker's default PID file to ensure that it can start properly if it was stopped uncleanly (and thus didn't clean up the PID file)
	find /run /var/run -iname 'docker*.pid' -delete
fi

exec "$@"
