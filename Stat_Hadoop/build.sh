if [ ! -d classes ]; then
        mkdir classes;
fi

# Compile BasicStat
javac -classpath $HADOOP_HOME/hadoop-core-1.1.2.jar:$HADOOP_HOME/lib/commons-cli-1.2.jar -d ./classes BasicStat.java

# Create the Jar
jar -cvf BasicStat.jar -C ./classes/ .
 
# Copy the jar file to the Hadoop distributions
cp BasicStat.jar $HADOOP_HOME/bin/ 

