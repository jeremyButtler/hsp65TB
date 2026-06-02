#!/bin/sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# k2ReadScan.sh -db <k2_database> -fq <fq>,<prefix>
#   - uses kraken2 to scan for species and build reports
# Input:
#   -db <k2_database>:
#     o database to use with kraken2
#   -fq <fq>,<prefix>:
#     o format <fq>,<prefix>
#       * fq: fastq files or direcotry of fastq files to
#         scan
#       * prefix: what to name to output fastq file data
#     o can be input multiple times
#   -csv <file>.tsv: [Optional]
#    o csv file to get get files from; format is
#      - <prefix>,<file_or_directory>
#   -lev O:
#     o taxanomic level to get read counts for from the
#       kraken2 report (K, P, C, O, F, G, S)
#     o root (R) and unclassified (U) is always  printed
# Output:
#   - prefix-k2-output.tsv:
#     o output kraken2 file with read ids
#   - prefix-k2-report.tsv:
#     o output kraken2 report
#   - stdout (terminal):
#     o tsv file listing prefix_<number> in column one,
#       order classified in column two, and number reads
#       in column three
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# k2ReadScan.sh SOF: Start Of File
#   o sec01:
#     - variable declarations
#   o sec02:
#     - get user input
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec01:
#   - variable declarations
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

fqNumSI=0;

prefixAryStr="";
fqAryStr="";
dirAryBl="";
gzAryBl="";

dbStr=""; # database for kraken2
levStr="O"; # kraken2 level to get read counts for

tmpStr="";
versionStr="2026-06-01";

helpStr="$(basename "$0") -db <database> -fq <fq>,<prefix>
    - uses kraken2 to scan for species and build reports
  Input:
    -db <database>: [Required]
      o database to use with kraken2
    -fq <fq>,<prefix>: [Required]
      o fq: fastq files or direcotry of fastq files to
            scan
      o prefix: what to name to output fastq file data
        * this is optional
      o can be input multiple times
    -csv <file>.tsv: [Optional]
     o csv file to get get files from; format is
       - <prefix>,<file_of_directory>
    -lev $levStr:
      o taxanomic level to get read counts for from the
        kraken2 report (K, P, C, O, F, G, S)
      o root (R) and unclassified (U) is always  printed
    -h: print this help message and exit
    -v: print last updated date and exist
  Output:
    - prefix-k2-output.tsv:
      o output kraken2 file with read ids
    - prefix-k2-report.tsv:
      o output kraken2 report (default, out_<number>)
    - stdout (terminal):
      o tsv file listing prefix_<number> in column one,
        order classified in column two, and number reads
        in column three
";

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec02:
#   - get user input
#   o sec02 sub01:
#     - check help message and version number + start loop
#   o sec02 sub02:
#     - read in fastq files and prefixs
#   o sec02 sub03:
#     - csv file; read in fastq files and prefixs
#   o sec02 sub04:
#     - read in kraken2 database and handel errors
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec02 Sub01:
#   - check help message and version number + start loop
#*********************************************************

while [ $# -gt 0 ];
do   # Loop: get user input
   if [ "$1" = "-h" ]; then
      printf "%s\n" "$helpStr"; exit;
   elif [ "$1" = "--h" ]; then
      printf "%s\n" "$helpStr"; exit;
   elif [ "$1" = "help" ]; then
      printf "%s\n" "$helpStr"; exit;
   elif [ "$1" = "-help" ]; then
      printf "%s\n" "$helpStr"; exit;
   elif [ "$1" = "--help" ]; then
      printf "%s\n" "$helpStr"; exit;

   elif [ "$1" = "-v" ]; then
      printf "%s version %s\n" \
             "$(basename "$0")" \
             "$versionStr";
      exit;
   elif [ "$1" = "--v" ]; then
      printf "%s version %s\n" \
             "$(basename "$0")" \
             "$versionStr";
      exit;
   elif [ "$1" = "version" ]; then
      printf "%s version %s\n" \
             "$(basename "$0")" \
             "$versionStr";
      exit;
   elif [ "$1" = "-version" ]; then
      printf "%s version %s\n" \
             "$(basename "$0")" \
             "$versionStr";
      exit;
   elif [ "$1" = "--version" ]; then
      printf "%s version %s\n" \
             "$(basename "$0")" \
             "$versionStr";
      exit;

   #******************************************************
   # Sec02 Sub02:
   #   - read in fastq files and prefixs
   #******************************************************

   elif [ "$1" = "-fq" ];
   then # Else If: fastq file and prefix combination
      shift;
      tmpStr="${1%%,*}";
 
      if [ ! -f "$tmpStr" ];
      then # If: not a file
         if [ ! -d "$tmpStr" ]; then
            printf " -fq %s is not a director or file\n" \
                "$1" \
                >&2;
            exit;
         else
            dirAryBl="$dirAryBl True";
            testStr="$(find "$tmpStr" -name "*.gz")";

            if [ "$testStr" != "" ]; then
               gzAryBl="$gzAryBl True";
            else
               gzAryBl="$gzAryBl False";
            fi; # check if gziped
         fi; # check if is a directory or error

      else
         dirAryBl="$dirAryBl False";

         if [ "${tmpStr##*.}" = "gz" ]; then
            gzAryBl="$gzAryBl True";
          else
            gzAryBl="$gzAryBl False";
         fi;
      fi; # If: check if is a file

      fqAryStr="$fqAryStr $tmpStr";
      prefixAryStr="$prefixAryStr ${1##*,}";
      fqNumSI="$((fqNumSI + 1))";

   #******************************************************
   # Sec02 Sub03:
   #   - csv file; read in fastq files and prefixs
   #******************************************************

   elif [ "$1" = "-csv" ];
   then # Else If: fastq file and prefix combination
      shift;

      if [ ! -f "$1" ];
      then
         printf "file from -tsv %s could not be opened\n"\
                "$1";
         exit;
      fi;

      siLine=1;
      while read -r lineStr;
      do # Loop: read in tsv file entries
         tmpStr="${lineStr##*,}";

         if [ ! -f "$tmpStr" ];
         then # If: not a file
            if [ ! -d "$tmpStr" ]; then
               { # print the error message
                  printf "line %s in -csv %s is not a" \
                         "$siLine" \
                         "$1";
                  printf " file or directory\n";
               } >&2; # print error message

               exit;
            else
               dirAryBl="$dirAryBl True";
               testStr="$(find "$tmpStr" -name "*.gz")";

               if [ "$testStr" != "" ]; then
                  gzAryBl="$gzAryBl True";
               else
                  gzAryBl="$gzAryBl False";
               fi; # check if gziped
            fi; # check if is a directory or error

         else
            dirAryBl="$dirAryBl False";

            if [ "${tmpStr##*.}" = "gz" ]; then
               gzAryBl="$gzAryBl True";
             else
               gzAryBl="$gzAryBl False";
            fi;
         fi; # If: check if is a file

         fqAryStr="$fqAryStr $tmpStr";
         prefixAryStr="$prefixAryStr ${lineStr%%,*}";
         siLine="$((siLine + 1))";
      done < "$1" # Loop: read in tsv file entries

   #******************************************************
   # Sec02 Sub04:
   #     - read in kraken2 database and handel errors
   #******************************************************

   elif [ "$1" = "-db" ];
   then # Else If: kraken2 database
      shift;
      if [ ! -d "$1" ]; then
         printf "could not open -db %s\n" "$1"; exit;
      else
         dbStr="$1";
      fi; # check if could open the database

   else
      printf "%s is not recognized\n" "$1"; exit;
   fi; # check user input
      

   shift;
done # Loop: get user input

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec03:
#   - run kraken2 on fastq files
#   o sec03 sub01:
#     - set up the input arrays and print header
#   o sec03 sub02:
#     - get the data to run
#   o sec03 sub03:
#     - run kraken2
#   o sec03 sub04:
#     - merege kraken2 results into a report
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec03 Sub01:
#   - set up the input arrays and print header
#*********************************************************

fqAryStr="${fqAryStr# }";
prefixAryStr="${prefixAryStr# }";
dirAryBl="${dirAryBl# }";
gzAryBl="${gzAryBl# }";

fqAryStr="$fqAryStr ";
prefixAryStr="$prefixAryStr ";
dirAryBl="$dirAryBl ";
gzAryBl="$gzAryBl ";

#*********************************************************
# Sec03 Sub02:
#   - get the data to run
#*********************************************************

while [ "$fqAryStr" != "" ];
do # Loop: run kraken2 on all input
   prefixStr="${prefixAryStr%% *}";
   prefixAryStr="${prefixAryStr#* }";

   fqStr="${fqAryStr%% *}";
   fqAryStr="${fqAryStr#* }";

   dirBl="${dirAryBl%% *}";
   dirAryBl="${dirAryBl#* }";

   gzBl="${gzAryBl%% *}";
   gzAryBl="${gzAryBl#* }";

   printf "on file prefix %s\n" "$prefixStr" >&2;

   #******************************************************
   # Sec03 Sub03:
   #   - run kraken2
   #******************************************************

   if [ "$gzBl" = "True" ]; then
      zipFlagStr="--gzip-compressed";
   else
      zipFlagStr="";
   fi;

   if [ "$dirBl" = "True" ]; then
      kraken2 \
         --db "$dbStr" "$zipFlagStr" \
         --output "$prefixStr-k2-output.tsv" \
         --report "$prefixStr-k2-report.tsv" \
         "$fqStr/"*;
   else
      kraken2 \
         --db "$dbStr" "$zipFlagStr" \
         --output "$prefixStr-k2-output.tsv" \
         --report "$prefixStr-k2-report.tsv" \
         "$fqStr";
   fi;

   if [ ! -f "$prefixStr-k2-report.tsv" ]; then
      printf "kraken2 could not classify %s\n" \
             "$prefixStr" \
             >&2;
      continue;
   fi; # kraken2 failed to build a report

   #******************************************************
   # Sec03 Sub04:
   #   - merege kraken2 results into a report
   #******************************************************

   tmpStr="${prefixStr##*/}";
   awk \
       -v levStr="$levStr" \
       -v prefixStr="$tmpStr" \
       '
         BEGIN{OFS="\t";};
         { # MAIN
            if($4 == levStr)
            { # If: order level
               nameStr=$6;
               for(siCol = 7; siCol <= NF; ++siCol)
                  nameStr=nameStr "_" $6;

               print prefixStr, $2, nameStr, $1;
            } # If: order level

            else if($4 == "U")
               print prefixStr, $2, "unclassified", $1;

            else if($4 == "R")
               print prefixStr, $2, "classified", $1;
         }; # MAIN
       ' "$prefixStr-k2-report.tsv";
done # Loop: run kraken2 on all input
