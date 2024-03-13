#!/bin/sh

cd /var/core
perf record -a -F 123 --call-graph dwarf,32768 sleep 10
chmod a+r perf.data
