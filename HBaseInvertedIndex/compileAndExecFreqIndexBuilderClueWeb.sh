#!/bin/bash

#make sure you have finish practice 1 and project 1
echo "make sure you have finish practice 1 and project 1, otherwise press control+C"
sleep 5


# clean existing compiled class
echo "Clean built java class and jar"
ant clean

# compile your code and shows errors if any
echo "Compiling source code with ant"
ant

if [ -f dist/lib/cglHBaseMooc.jar ]
then
    echo "Source code compiled!"
else
    echo "There may be errors in your source code, please check the debug message."
    exit 255
fi

echo "Copy dist/lib/cglHBaseMooc.jar file to hadoop lib under /root/software/hadoop-1.1.2/lib/"
cp dist/lib/cglHBaseMooc.jar /root/software/hadoop-1.1.2/lib/

if [ -f /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar ]
then
    echo "File copied!"
else
    echo "There may be errors when copying file, please check if directory /root/software/hadoop-1.1.2/lib exists."
    exit 254
fi

export HADOOP_CLASSPATH=`/root/software/hbase-0.94.7/bin/hbase classpath`
#echo "export HADOOP_CLASSPATH=`/root/software/hbase-0.94.7/bin/hbase classpath`" >> ~/.bashrc
#source ~/.bashrc

# run wordcount
hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.clueweb09.FreqIndexBuilderClueWeb09

# capture the standard output
mkdir -p output
hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.HBaseTableReader clueWeb09IndexTable frequencies string string string int 30 > output/project2.txt

echo "FreqIndexBuilderClueWeb09 Finished execution, see output in output/project2.txt."
