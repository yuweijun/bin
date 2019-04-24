#!/bin/sh

UMASK="0022"

JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=prod -Dfile.encoding=UTF-8 -Xmx1500m -Xms1500m -XX:+PrintCommandLineFlags -XX:+PrintTenuringDistribution -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -verbose:gc -Xloggc:${CATALINA_BASE}/logs/gc-$(date +%Y-%m-%d).log -XX:GCLogFileSize=100M -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${CATALINA_BASE}/logs/heapdump.hprof"
