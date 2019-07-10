#!/bin/sh
set -e

cd /opt/civetweb/bin
export PATH=/opt/civetweb/bin:$PATH
 
exec "$@" -run_as_user civetweb
