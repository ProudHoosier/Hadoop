import java.io.IOException;
import java.util.StringTokenizer;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;

import java.io.DataInput;
import java.io.DataOutput;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class BasicStat {

 public static class Map extends Mapper <LongWritable, Text, Text, CompositeWritable> {

  public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
   String a[] = value.toString().split(",");
   Double d[] = new Double[20];


   double partialSum = 0.0, partialSquareSum = 0.0, partialMin = 20.0, partialMax = 0.0, partialCount = 0.0;
   for (int i = 0; i < a.length; i++) {
    d[i] = Double.parseDouble(a[i]);
   }

   for (int i = 0; i < d.length; i++) {
    if (partialMin >= d[i])
     partialMin = d[i];
    if (partialMax <= d[i])
     partialMax = d[i];
    partialSum += d[i];
    partialCount++;
    partialSquareSum += d[i] * d[i];
   }

   CompositeWritable c = new CompositeWritable(partialSum, partialSquareSum, partialMin, partialMax, partialCount);
   context.write(new Text("partialvalues"), c);
  }
 }

 public static class Reduce extends Reducer < Text, CompositeWritable, Text, DoubleWritable > {

  private CompositeWritable result = new CompositeWritable();

  public void reduce(Text key, Iterable < CompositeWritable > values, Context context) throws IOException, InterruptedException {

   double globalSum = 0.0, globalSquareSum = 0.0, globalMin = 50.0, globalMax = 0.0, globalCount = 0.0, globalAvg, globalSD;

   for (CompositeWritable val: values) {
    globalSum += val.val1;
    globalSquareSum += val.val2;
    if (globalMin >= val.val3)
     globalMin = val.val3;
    if (globalMax <= val.val4)
     globalMax = val.val4;
    globalCount += val.val5;
   }

   globalAvg = globalSum / globalCount;

   globalSD = Math.sqrt((globalSquareSum / globalCount) - (2 * (globalAvg / globalCount) * globalSum) + (globalAvg * globalAvg));

   context.write(new Text("Minimum: "), new DoubleWritable(globalMin));
   context.write(new Text("Maximum: "), new DoubleWritable(globalMax));
   context.write(new Text("Average: "), new DoubleWritable(globalAvg));
   context.write(new Text("Standard deviation: "), new DoubleWritable(globalSD));
  }
 }

 public static class CompositeWritable implements Writable {
  double val1 = 0.0;
  double val2 = 0.0;
  double val3 = 0.0;
  double val4 = 0.0;
  double val5 = 0.0;

  public CompositeWritable() {}

  public CompositeWritable(double val1, double val2, double val3, double val4, double val5) {
   this.val1 = val1;
   this.val2 = val2;
   this.val3 = val3;
   this.val4 = val4;
   this.val5 = val5;
  }

  @Override
  public void readFields(DataInput in ) throws IOException {
   val1 = in .readDouble();
   val2 = in .readDouble();
   val3 = in .readDouble();
   val4 = in .readDouble();
   val5 = in .readDouble();
  }

  @Override
  public void write(DataOutput out) throws IOException {
   out.writeDouble(val1);
   out.writeDouble(val2);
   out.writeDouble(val3);
   out.writeDouble(val4);
   out.writeDouble(val5);
  }

  public void merge(CompositeWritable other) {
   this.val1 += other.val1;
   this.val2 += other.val2;
   this.val3 += other.val3;
   this.val4 += other.val4;
   this.val5 += other.val5;
  }

  @Override
  public String toString() {
   return this.val1 + "\t" + this.val2 + "\t" + this.val3 + "\t" + this.val4 + "\t" + this.val5;
  }
 }

 // Driver program
 public static void main(String[] args) throws Exception {
  Configuration conf = new Configuration();
  // getting all the arguments
  String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs(); 
  if (otherArgs.length != 2) {
   System.err.println("Usage: Project1 <in> <out>");
   System.exit(2);
  }

  // creating a job with name "Project1" and setting the mapper and reducer class
  Job job = new Job(conf, "Project1");
  job.setJarByClass(BasicStat.class);
  job.setMapperClass(Map.class);
  job.setReducerClass(Reduce.class);

  // setting key type for output   
  job.setOutputKeyClass(Text.class);
  // setting output value type
  job.setOutputValueClass(CompositeWritable.class);
  //setting HDFS path for input data
  FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
  // setting HDFS path for output
  FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));

  System.exit(job.waitForCompletion(true) ? 0 : 1);
 }
}

