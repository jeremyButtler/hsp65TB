#!/bin/awk -f

##########################################################
# awk -f tbMergeK2Reports.awk report_1.tsv report_2.tsv ...
#   - merges kraken2 reports for my TB kraken2 run
# Input:
#    - report_<number>.tsv
#      o report to extract mycobacterium reads from
# Output:
#   - tsv file with the kraken2 mycobacterium and any
#     faimly with at least 10% of reads
#   - each file is separated by a row of dashes
##########################################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# tbMergeK2Reports.awk SOF: Start Of File
#   - merges kraken2 reports for my TB kraken2 run
#   o sec01:
#     - get the first line of the kraken2 report and
#       extract the meta data
#   o sec02:
#     - main; get target taxa and dominant taxa from each
#       file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec01:
#   - get the first line of the kraken2 report and extract
#     the meta data
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

BEGIN{
   OFS = "\t";
   print "year",
         "country",
         "barcode",
         "bin",
         "name",
         "taxanomic_rank",
         "reads",
         "perc_reads",
         "total_classified_reads",
         "total_unclassifed_reads";
};

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec02:
#   - main; get target taxa and dominant taxa from each
#     file
#   o sec02 sub01:
#     - get values for new files
#   o sec02 sub02:
#     - find taxa above 10% and mycobateriales
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec02 Sub01:
#   - get values for new files
#*********************************************************

{ # MAIN
   if(fileStr != FILENAME)
   { # If: a new file
      if(fileStr)
      { # If: need to add the file spacer
         print "---",
               "---",
               "---",
               "---",
               "---",
               "---",
               "---",
               "---",
               "---",
               "---";
      } # If: need to add the file spacer

      fileStr = FILENAME;

      typeStr = FILENAME;
      sub(/.*\//, "", typeStr);

      if(typeStr ~ /^[0-9]/)
      { # If: have a year
         yearStr = typeStr;
         sub(/-.*/, "", yearStr);
         sub(/^[0-9][0-9]*-/, "", typeStr); # remove year
      } # If: have a year

      else
         yearStr = 2026; # assume 2026

      # get the country of origin
      countryStr = typeStr;
      sub(/-.*/, "", countryStr);
      sub(/[^-]*-/, "", typeStr);

      # get the barcode
      barStr = typeStr;
      sub(/-.*/, "", barStr);
      sub(/[^-]*-/, "", typeStr);

      # get the type
      if(typeStr ~ /unkown/)
         typeStr = "unclassified";
      else
         typeStr = "all";

      if($4 != "U")
      { # If: all reads were classified
         numUnclassSI = 0;
         percUnclassSI = 0;

         totalSI = $2;
         totalPercSI = $1;
      } # If: all reads were classified

      else
      { # Else: have unclassified reads
         numUnclassSI = $2;
         percUnclassSI = $1;

         getline;

         totalSI = $2;
         totalPercSI = $1;
      } # Else: have unclassified reads

      next;
   } # If: a new file

   #******************************************************
   # Sec02 Sub02:
   #   - find taxa above 10% and mycobateriales
   #******************************************************

   if($4 == "G" && $6 == "Mycobacterium")
   { # If: mycobacterium family
      print yearStr,
            countryStr,
            barStr,
            typeStr,
            "Mycobacterium",
            "genus",
            $2,
            $1,
            totalSI,
            numUnclassSI;
   } # If: mycobacterium family

   else if($4 == "G1" && $7 == "tuberculosis")
   { # If: mycobacterium family
      print yearStr,
            countryStr,
            barStr,
            typeStr,
            "TB_complex",
            "genus1",
            $2,
            $1,
            totalSI,
            numUnclassSI;
   } # If: mycobacterium family


   else if($4 == "S" && $6 == "Mycobacterium")
   { # Else If: mycobacterium species
      if($7 == "sp.")
         speciesStr = $8;
      else
         speciesStr = $7;

      print yearStr,
            countryStr,
            barStr,
            typeStr,
            speciesStr,
            "species",
            $2,
            $1,
            totalSI,
            numUnclassSI;
   } # Else If: mycobacterium species

   else if($1 > 10 && $4 == "F")
   { # Else If: more dominaint taxa
      print yearStr,
            countryStr,
            barStr,
            typeStr,
            $6,
            "family",
            $2,
            $1,
            totalSI,
            numUnclassSI;
   } # Else If: more dominaint taxa
}; # MAIN
