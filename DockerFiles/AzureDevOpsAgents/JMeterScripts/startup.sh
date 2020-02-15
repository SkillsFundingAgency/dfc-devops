#!/bin/bash
#Developed from https://github.com/justb4/docker-jmeter/blob/master/entrypoint.sh (commit 6aa034c6c362f8e29cb81f7d51637560d29b2f24)
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "JVM_ARGS=${JVM_ARGS}"