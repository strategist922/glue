###########################
#
# Start the glue server
# e.g. glue.sh
#!/usr/bin/env bash


abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
GLUE_BIN_HOME=`dirname $abspath`

GLUE_HOME=$GLUE_BIN_HOME/../

export GLUE_CONF_DIR=$GLUE_HOME/conf

#source environment variables
port= 8025
glue_conf=$GLUE_CONF_DIR/exec.groovy
module_conf=$GLUE_CONF_DIR/modules.groovy

# some Java parameters
if [ "$JAVA_HOME" != "" ]; then
    #echo "run java in $JAVA_HOME"
   JAVA_HOME=$JAVA_HOME
fi

if [ "$JAVA_HOME" = "" ]; then
     echo "Error: JAVA_HOME is not set."
     exit 1
fi

JAVA=$JAVA_HOME/bin/java


if [ -z $JAVA_HEAP ]; then
 export JAVA_HEAP="-Xmx1024m"
fi

# check envvars which might override default args
# CLASSPATH initially contains $GLUE_CONF_DIR
CLASSPATH=${CLASSPATH}:$JAVA_HOME/lib/tools.jar

# for developers, add Pig classes to CLASSPATH

# so that filenames w/ spaces are handled correctly in loops below
IFS=
# add libs to CLASSPATH.
for f in $GLUE_HOME/lib/*.jar; do
  CLASSPATH=${CLASSPATH}:$f;
done

LAUNCH_CLASS="org.apache.glue.rest.Launcher"
CLIENT_CLASS="org.apache.glue.rest.Client"

CLASSPATH=$GLUE_CONF_DIR:$GLUE_CONF_DIR/META-INF:$CLASSPATH
if [ "$1" == "start" ]; then
	echo "starting glue server"
	exec "$JAVA" -Xss128k -XX:MaxDirectMemorySize=2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:SurvivorRatio=6 -XX:NewRatio=3 -XX:+DisableExplicitGC $JAVA_HEAP $JAVA_OPTS -Djava.library.path="$STREAMS_HOME/lib/native/Linux-amd64-64/" -classpath "$CLASSPATH" $LAUNCH_CLASS $glue_conf $module_conf $port
	echo "server started"
fi
if [ "$1" == "stop" ]; then
	echo "stopping glue server"
	exec "$JAVA" -Xss128k -XX:MaxDirectMemorySize=2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:SurvivorRatio=6 -XX:NewRatio=3 -XX:+DisableExplicitGC $JAVA_HEAP $JAVA_OPTS -Djava.library.path="$STREAMS_HOME/lib/native/Linux-amd64-64/" -classpath "$CLASSPATH" $CLIENT_CLASS "localhost:$port" stop
	echo "shutdown request sent, waiting for the server to finish" 
	nc localhost $port
	echo "glue server stopped"
	
	
fi

if [ "$1" == "restart" ]; then
	echo "stopping glue server"
	exec "$JAVA" -Xss128k -XX:MaxDirectMemorySize=2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:SurvivorRatio=6 -XX:NewRatio=3 -XX:+DisableExplicitGC $JAVA_HEAP $JAVA_OPTS -Djava.library.path="$STREAMS_HOME/lib/native/Linux-amd64-64/" -classpath "$CLASSPATH" $CLIENT_CLASS "localhost:$port" stop
	echo "shutdown request sent, waiting for the server to finish"
	nc localhost $port
	echo "glue server stopped, restarting it"
	exec "$JAVA" -Xss128k -XX:MaxDirectMemorySize=2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:SurvivorRatio=6 -XX:NewRatio=3 -XX:+DisableExplicitGC $JAVA_HEAP $JAVA_OPTS -Djava.library.path="$STREAMS_HOME/lib/native/Linux-amd64-64/" -classpath "$CLASSPATH" $LAUNCH_CLASS $glue_conf $module_conf $port
	echo "glue server started"
fi
 