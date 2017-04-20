#!/bin/bash

echo "Please finsih <Load data to HBase> lab before running this script."
echo "Otherwise, please press Ctrl + C to exit."
echo "-----------------------------------------"
echo "If you'd like to continue, please wait for 10 seconds."
sleep 10

# cd /root/software/hadoop-1.1.2/
# . ./MultiNodesOneClickStartUp.sh /root/software/jdk1.6.0_33/ nodes
# cd /root/software/hbase-0.94.7/
# ./bin/start-hbase.sh

#cp /root/software/hbase-0.94.7/conf/hbase-site.xml /root/software/hadoop-1.1.2/conf/
#cd /root/software/hadoop-1.1.2/
#echo "export HADOOP_CLASSPATH=`/root/software/hbase-0.94.7/bin/hbase classpath`" >> ~/.bashrc
#source ~/.bashrc


# create hbase tables
#hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.clueweb09.TableCreatorClueWeb09

# create two directories for data input
#mkdir -p /root/data/clueweb09/files
#mkdir -p /root/data/clueweb09/mrInput

# create inputs metadata for HBbase data loader 
#hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.clueweb09.Helpers create-mr-input /root/data/clueweb09/files/ /root/data/clueweb09/mrInput/ 1

# copy metadata to Hadoop HDFS
#hadoop dfs -copyFromLocal /root/data/clueweb09/mrInput/ /cw09LoadInput
#hadoop dfs -ls /cw09LoadInput

# load data into HBase (takes 10-20 minutes to finish)
# hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.clueweb09.DataLoaderClueWeb09 /cw09LoadInput

# cd /root/hbaseMoocAntProject

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
hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.clueweb09.WordCountClueWeb09

# capture the standard output
mkdir -p output
hadoop jar /root/software/hadoop-1.1.2/lib/cglHBaseMooc.jar iu.pti.hbaseapp.HBaseTableReader WordCountTable frequencies string string string long 10 > output/project1.txt


echo "WordCount Finished execution, see output in output/project1.txt."
