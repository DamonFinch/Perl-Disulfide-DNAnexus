#!/bin/bash -x
# Bismark-ENCODE-WGBS 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of  pair 1 reads: '$pair1_reads'"
    echo "Value of  pair 2 reads: '$pair2_reads'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    filename1=`dx describe "$pair1_reads" --name | cut -d'.' -f1`
    dx download "$pair1_reads" -o "$filename1".fq.gz
    echo "uncompressing read file 1 ($filename1)"
    gunzip $filename1.fq.gz

    filename2=`dx describe "$pair2_reads" --name | cut -d'.' -f1`
    dx download "$pair2_reads" -o "$filename2".fq.gz
    echo "uncompressing read file 2 ($filename2)"
    gunzip $filename2.fq.gz
    echo "Reads  downloaded"

    mkdir input
    outfile1="$filename1.trimmed-reads.1.fq"
    outfile2="$filename2.trimmed-reads.2.fq"
    mott-trim.py -q 3 -m 30 -t sanger $outfile1,$outfile2 $filename1.fq,$filename2.fq
    gzip *trimmed-reads*.fq


    echo `ls /home/dnanexus`
    trimmed_reads1=$(dx upload /home/dnanexus/$outfile1.gz --brief)
    trimmed_reads2=$(dx upload /home/dnanexus/$outfile2.gz --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output trimmed_reads1 "$trimmed_reads1" --class=file
    dx-jobutil-add-output trimmed_reads2 "$trimmed_reads2" --class=file
}
