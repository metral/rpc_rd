//==============================================================================
package org.myorg;
import java.io.IOException;
import java.util.*;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamReader;
import java.io.ByteArrayInputStream;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.*;
import org.apache.hadoop.mapreduce.lib.output.*;
import org.apache.hadoop.util.*;

import org.myorg.Performance;
//------------------------------------------------------------------------------
public class FlightCarrierPerformance extends Configured implements Tool {
//------------------------------------------------------------------------------
    public static class Map
        extends Mapper<LongWritable, Text, Text, IntWritable> {
            private Text map_key = new Text();
//------------------------------------------------------------------------------
            public void map(LongWritable key, Text value, Context context)
                throws IOException, InterruptedException {
                    String line = value.toString();
                    String[] line_list = line.split(",");

                    Performance perf = new Performance(line_list);

                    if (!perf.DepDelay.equals("NA")) {
                        IntWritable depdelay = 
                            new IntWritable(Integer.parseInt(perf.DepDelay));

                        // Tokenize & write the key out
                        map_key.set(perf.UniqueCarrier);
                        context.write(map_key, depdelay);
                    }
                }
        }
//------------------------------------------------------------------------------
    public static class Reduce
        extends Reducer<Text, IntWritable, Text, DoubleWritable> {
//------------------------------------------------------------------------------
        public void reduce(Text key, Iterable<IntWritable> values,
                Context context) throws IOException, InterruptedException {

            int delay_count = 0;
            int delay_total = 0;

            for (IntWritable val : values) {
                delay_count += 1;
                delay_total += val.get();
            }

            double avg_delay = delay_total / (double) delay_count; 
            context.write(key, new DoubleWritable(avg_delay));
        }
    }
//------------------------------------------------------------------------------
    public int run(String [] args) throws Exception {

        Job job = new Job(getConf());
        job.setJarByClass(FlightCarrierPerformance.class);
        job.setJobName("flight_carrier_performance");
        
        // Map Output Format for Key & Value
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        job.setMapperClass(Map.class);
        job.setReducerClass(Reduce.class);

        job.setNumReduceTasks(1);

        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);

        FileInputFormat.setInputPaths(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        boolean success = job.waitForCompletion(true);
        return success ? 0 : 1;
    }
//------------------------------------------------------------------------------
    public static void main(String[] args) throws Exception {
        int ret = ToolRunner.run(new FlightCarrierPerformance(), args);
        System.exit(ret);
    }
//------------------------------------------------------------------------------
}
//==============================================================================
