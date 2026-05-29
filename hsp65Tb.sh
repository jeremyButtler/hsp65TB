#!/bin/sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# hsp65Tb.sh SOF: Start Of File
#   - detect hsp65 species in tb
#   o sec01:
#     - variable declarations
#   o sec02:
#     - install command
#   o sec04:
#     - build the output tsv file
#   o sec05:
#     - find program and file locations
#   o sec06:
#     - get hsp65 lineages
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec01:
#   - variable declarations
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

fileStr="$1";

hsp65TBStr="${HOME}/Downloads/hsp65TB/";

refStr="$hsp65TBStr/NC000962.fa";
hsp65CoordsStr="$hsp65TBStr/hsp65-coord.tsv";
simpDbStr="$hsp65TBStr/hsp65-db-simple.tsv";
compDbStr="$hsp65TBStr/hsp65-db-complex.tsv";


mapCmdStr=""
versionStr="2026-05-29";

helpStr="$(basename "$0") samples.tsv > output.tsv
         or $(basename "$0") install
         or $(basename "$0") help
   - detects hsp65 species in barcodes
Version:
   $versionStr
Input:
   - samples.tsv:
     o tsv (tab delminated) file with the frist colmun
       having what to name the sample and the second
       column having the sampe file path
       - run1_barcode01 /path/to/run1/fastq_pass/barcode01
       - the path must be from your current location to
         your barcode directories
       - you can quickly make the file with this command
         line command
   - mkfile prefix /path/to/fastq_pass
   - or mkfile /path/to/fastq_pass
     o makes the file with barcode paths to run through
       this program and prints to terminal
     o prefix is the prefix for the output barcode names
     o /path/to/fastq_fass is the path to the directory
       with the barcodes
     o commad used:
       * find /path/to/barcodes -name barcode* |
           sed 's/.*barcode\([0-9]*\)/bar\1\t&/;'
   - install:
     o install programs to run this script and exit
   - help:
     o print this help message and exit
Output:
   - prints tsv to terminal:
     o name gene1:species1:depth1 gene2:species2:depth2 ...
"

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec02:
#   - help message; version print; install command
#   o sec02 sub01:
#     - help message print
#   o sec02 sub02:
#     - version number print
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec02 Sub01:
#   - help message print
#*********************************************************

if [ "$1" = "help" ]; then
   printf "%s\n" "$helpStr";
   exit;
elif [ "$1" = "-h" ]; then
   printf "%s\n" "$helpStr";
   exit;
elif [ "$1" = "--h" ]; then
   printf "%s\n" "$helpStr";
   exit;
elif [ "$1" = "-help" ]; then
   printf "%s\n" "$helpStr";
   exit;
elif [ "$1" = "--help" ]; then
   printf "%s\n" "$helpStr";
   exit;
fi;

#*********************************************************
# Sec02 Sub02:
#   - version number print
#*********************************************************

if [ "$1" = "-v" ]; then
   printf "%s version %s:\n" \
          "$(basename "$0")" \
          "$versionStr";
   exit;
elif [ "$1" = "--v" ]; then
   printf "%s version %s:\n" \
          "$(basename "$0")" \
          "$versionStr";
   exit;
elif [ "$1" = "version" ]; then
   printf "%s version %s:\n" \
          "$(basename "$0")" \
          "$versionStr";
   exit;
elif [ "$1" = "-version" ]; then
   printf "%s version %s:\n" \
          "$(basename "$0")" \
          "$versionStr";
   exit;
elif [ "$1" = "--version" ]; then
   printf "%s version %s:\n" \
          "$(basename "$0")" \
          "$versionStr";
   exit;
fi;

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec03:
#   - install programs subcommand
#   o sec03 sub01:
#     - install bioTools programs
#   o sec03 sub02:
#     - download the hsp65TB script
#   o sec03 sub03:
#     - copy needed programs and databases to the hsp65
#       script
#   o sec03 sub04:
#     - minimap2 install
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec03 Sub01:
#   - install bioTools programs
#*********************************************************

if [ "$1" = "install" ];
then # If: user wanted to install
   bioToolsStr="${HOME}/Downloads/bioTools-buttler/";

   if [ ! -d "$bioToolsStr" ];
   then
      git clone \
         "https://github.com/jeremyButtler/bioTools" \
         "$bioToolsStr";
   else
      cd "$bioToolsStr" || exit;
      git pull;
   fi;

   cd "$bioToolsStr/getLinSrc" || exit;
   make -f mkfile.unix;

   cd "$bioToolsStr/ampDepthSrc" || exit;
   make -f mkfile.unix;

   cd "$bioToolsStr/mapReadSrc" || exit;
   make -f mkfile.unix;

   cd "$bioToolsStr/tbConSrc" || exit;
   make -f mkfile.unix;

   cd "$bioToolsStr/filtsamSrc" || exit;
   make -f mkfile.unix;

   #******************************************************
   # Sec03 Sub02:
   #   - download the hsp65TB script
   #******************************************************

   if [ ! -d "$hsp65TBStr" ];
   then
      git clone \
         "https://github.com/jeremyButtler/hsp65TB" \
         "$hsp65TBStr";
   else
      cd "$hsp65TBStr" || exit;
      git pull;
   fi;

   gunzip -c < "$hsp65TBStr/NC000962.fa.gz" > "$refStr";

   #******************************************************
   # Sec03 Sub03:
   #   - copy needed programs and databases to the hsp65
   #     script
   #******************************************************

   #__________________getLin______________________________
   cp \
       "$bioToolsStr/getLinSrc/getLin" \
       "$hsp65TBStr/getLin";
   chmod a+x "$hsp65TBStr/getLin";

   #__________________ampDepth____________________________
   cp \
       "$bioToolsStr/ampDepthSrc/ampDepth" \
       "$hsp65TBStr/ampDepth";
   chmod a+x "$hsp65TBStr/ampDepth";

   #__________________mapRead_____________________________
   # fall back read mapper
   cp \
       "$bioToolsStr/mapReadSrc/mapRead" \
       "$hsp65TBStr/mapRead";
   chmod a+x "$hsp65TBStr/mapRead";

   #__________________tbCon_______________________________
   cp \
       "$bioToolsStr/tbConSrc/tbCon" \
       "$hsp65TBStr/tbCon";
   chmod a+x "$hsp65TBStr/tbCon";

   #__________________filtsam_____________________________
   cp \
       "$bioToolsStr/filtsamSrc/filtsam" \
       "$hsp65TBStr/filtsam";
   chmod a+x "$hsp65TBStr/filtsam";

   #_________________databases____________________________
   cpStr="$bioToolsStr/getLinSrc/hsp65-databases/";
   cpStr="$cpStr/2026-05-26/";
   cp "$cpStr/09-hsp65-simple.tsv" "$simpDbStr";
   cp "$cpStr/10-hsp65-complex.tsv"  "$compDbStr";

   #******************************************************
   # Sec03 Sub04:
   #   - minimap2 install
   #******************************************************

   if [ ! -d "${HOME}/Downloads/minimap2" ];
   then
      git clone \
         "https://github.com/lh3/minimap2" \
         "${HOME}/Downloads/minimap2";
      cd "${HOME}/Downloads/minimap2" || exit;
   else
      cd "${HOME}/Downloads/minimap2" || exit;
      git pull;
   fi;

   archStr="$( \
      uname -m |
      sed '
            s/arm64/-arm-64/;  # 64 bit arm cpu (MAC)
            s/aarch64/-arm-64/;# 64 bit arm cpu (PI)
            s/arm[Vv]*8.*/-arm-64/; # arm8 is 64 bit
            s/arm[Vv]*[0-7].*/arm32/; # 32bit arm
            s/^arm.*/arm32/;  # assume 32bit arm
            s/x86.*/x86/;      # often 64 bit intel/amd
            s/i386.*/x86/;     # older intel/amd
            s/i686.*/x86/;     # enhanced intel/AMD
            s/-arm-64/arm64/; # here to avoid overwrite
          '
   )";

   if [ "$archStr" = "arm64" ]; then
      make arm_neon=1 aarch64=1 || exit;
   elif [ "$archStr" = "arm32" ]; then
      make arm_neon=1 || exit;
   elif [ "$archStr" = "x86" ]; then
      make || exit; # x86 cpu
   else
     printf "could not install minimap2; using mapRead\n";
     exit;
   fi;  # compile for various cpus

   cp \
       "minimap2" \
       "$hsp65TBStr/minimap2";
   chmod a+x "$hsp65TBStr/minimap2";

   exit;
fi; # If: user wanted to install

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec04:
#   - build the output tsv file
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if [ "$1" = "mkfile" ];
then
   if [ "$3" = "" ];
   then # If second entry is the file pathIf
      if [ ! -d "$2" ]; then
         printf "%s does not exist\n" "$2" >&2;
      else
         find "$2" -name "barcode*" |
           sed "s/.*barcode\([0-9]*\)/bar\1\t&/;";
      fi;
   elif [ ! -d "$3" ]; then
      printf "%s does not exist\n" "$3" >&2;
   else
      find "$3" -name "barcode*" |
        sed "s/.*barcode\([0-9]*\)/$2-bar\1\t&/;";
   fi;

   exit;
fi;

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec05:
#   - find program and file locations
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if [ ! -f "$refStr" ]; then
   printf "no reference; do sh hsp65Tb.sh install\n" >&2;
   exit;
elif [ ! -f "$hsp65CoordsStr" ]; then
   printf "no hsp65 coordinates; do hsp65Tb.sh install\n"\
     >&2;
   exit;
elif [ ! -f "$simpDbStr" ]; then
   printf "no simple databse; do sh hsp65Tb.sh install\n"\
      >&2;
   exit;
elif [ ! -f "$compDbStr" ]; then
  printf "no complex databse; do sh hsp65Tb.sh install\n"\
     >&2;
  exit;
fi; # check for databases

#________________bioTools_programs________________________
if [ ! -f "$hsp65TBStr/ampDepth" ]; then
  printf "no ampDepth; do sh hsp65Tb.sh install\n" >&2;
  exit;
elif [ ! -f "$hsp65TBStr/getLin" ]; then
  printf "no getLin; do sh hsp65Tb.sh install\n" >&2;
  exit;
elif [ ! -f "$hsp65TBStr/tbCon" ]; then
  printf "no tbCon; do sh hsp65Tb.sh install\n" >&2;
  exit;
fi; # get for biotools programs

#________________read_mapper_check________________________
if [ ! -f "$hsp65TBStr/minimap2" ]; then
   if [ ! -f "$hsp65TBStr/mapRead" ]; then
     printf "no read mapper; do sh hsp65Tb.sh install \n"\
       >&2;
     exit;
   else
      mapCmdStr="hsp65TBStr/mapRead -ref $refStr";
   fi;
else
   mapCmdStr="$hsp65TBStr/minimap2 -a $refStr";
   mapVersionStr="$(minimap2 --version)";
fi;

#__________________check_if_input_exists__________________
if [ ! -f "$fileStr" ]; then
   printf "could not open input (%s)\n" "$fileStr" >&2;
   exit;
fi;

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Sec06:
#   - get hsp65 lineages
#   o sec06 sub01:
#     - print the header and for loop check input
#   o sec06 sub02:
#     - map reads and get mean depth
#   o sec06 sub03:
#     - get species in hsp65
#   o sec06 sub04:
#     - get fragment species
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#*********************************************************
# Sec06 Sub01:
#   - print the header and for loop check input
#*********************************************************

{ # print the header
   printf "sample\tmean_depth\tperc_cover\tsource";
   printf "\tgene\tname";
   printf "\tsupport\tclassifiable";
   printf "\tpercent_support\ttotal_reads\n";
}; # print the header

while read -r lineStr;
do # Loop: read in databases
   if [ "$lineStr" = "" ]; then
      continue; # blank line
   fi;

   tmpStr="$(printf "%s" "$lineStr" | sed 's/^#.*//;')";
   if [ "$tmpStr" = "" ]; then
      continue; # commented out
   fi;

   printf "on %s\n" "$lineStr" >&2;

   nameStr="$(\
      printf "%s" "$lineStr" | awk '{print $1;};' \
   )";
   dirStr="$(\
      printf "%s" "$lineStr" | awk '{print $2;};' \
   )";

   if [ ! -d "$dirStr" ];
   then
     printf "could not find directory %s\n" "$dirStr" >&2;
     printf "ERROR-%s\tNA\tNA\n" "$nameStr";
     continue;
   fi;

   #******************************************************
   # Sec06 Sub02:
   #   - map reads and get mean depth
   #******************************************************

   $mapCmdStr "$dirStr/"* > "del.sam" 2>/dev/null;

   if [ ! -f "del.sam" ];
   then
      printf "no reads in %s mapped\n" "$dirStr" >&2;
      printf "%s\tNA\tNA\n" "$nameStr";
      continue;
   fi;

   meanDepthF="$(
      "$hsp65TBStr/ampDepth" \
           -gene-tbl "$hsp65CoordsStr" \
           -p-gene-cover \
           -min-depth 1 \
           -sam "del.sam" |
         awk 'BEGIN{getline;}; {print $2 " " $4;};'
   )"; # get mean depth

   percCoverF="${meanDepthF%% *}";
   meanDepthF="${meanDepthF##* }";

   #******************************************************
   # Sec06 Sub03:
   #   - get species in hsp65
   #******************************************************

   "$hsp65TBStr/getLin" \
        -simple "$simpDbStr" \
        -complex "$compDbStr" \
        -bin-prefix "$nameStr-bin" \
        -bin-call \
        -bin-unkown \
        -bin-fragment \
        -bin-fq \
        -sam "del.sam" |
     awk \
         -v nameStr="$nameStr" \
         -v meanDepthF="$meanDepthF" \
         -v percCoverF="$percCoverF" \
         '
           BEGIN{
              OFS="\t";
              getline;
              if(NF < 4)
              { # If: nothing in the report
                 printf "%s\t%0.2f", nameStr, meanDepthF;
                 printf "\t%0.2f", percCoverF;
                 printf "\tNA\tNA\tNA\tNA\tNA\tNA\n";
                 exit;
              } # If: nothing in the report

              for(siCol = 3; siCol < NF; ++siCol)
              { # Loop: get the gene and name
                 geneAryStr[siCol - 2] = $siCol;
                 sub(/:.*/, "", geneAryStr[siCol - 2]);

                 nameAryStr[siCol - 2] = $siCol;
                 sub(/.*:/, "", nameAryStr[siCol - 2]);
              } # Loop: get the gene and name

              getline;

              for(siCol = 3; siCol < NF; ++siCol)
              { # Loop: get the deths
                 gsub(/[a-zA-Z]*=/, "", $siCol);
                 split($siCol, depthArySI, ":");

                 printf "%s\treads\t%0.2f\t%0.2f",
                        nameStr,
                        meanDepthF,
                        percCoverF;
                 printf "\t%s\t%s\t%s\t%s\t%s\t%s\n",
                        geneAryStr[siCol - 2],
                        nameAryStr[siCol - 2],
                        depthArySI[1], # number supporting
                        depthArySI[3], # usabel reads
                        depthArySI[2], # percent support
                        depthArySI[4]; # total depth
              } # Loop: get the deths

              exit;
           } # BEGIN
        ';
   rm "del.sam";

   #******************************************************
   # Sec06 Sub04:
   #   - get fragment species
   #******************************************************

   if [ -f "$nameStr-bin-fragments.fq" ];
   then
      $mapCmdStr "$nameStr-bin-fragments.fq" \
          2>/dev/null |
        "$hsp65TBStr/tbCon" -sam - \
        > "$nameStr-bin-fragments-con.sam";

      "$hsp65TBStr/getLin" \
           -simple "$simpDbStr" \
           -complex "$compDbStr" \
           -pmode-genome \
           -sam "$nameStr-bin-fragments-con.sam" |
        awk \
            -v nameStr="$nameStr" \
            '
              BEGIN{OFS="\t"; getline;};
              { # MAIN
                 if($3 == "*")
                    next;

                 geneStr = $3;
                 sub(/:.*/, "", geneStr);

                 speciesStr = $3;
                 sub(/.*:/, "", speciesStr);

                 printf "%s\tfragments\tNA\tNA", nameStr;
                 printf "\t%s\t%s\tNA\tNA\tNA\tNA\n",
                        geneStr,
                        speciesStr;
                 exit;
              }; # MAIN
            '
      "$hsp65TBStr/filtsam" \
          -out-fasta \
          -sam "$nameStr-bin-fragments-con.sam" |
        sed "s/^>[^ ]*/>$nameStr-fragments/;" \
        > "$nameStr-bin-fragments-con.fa";

      rm "$nameStr-bin-fragments-con.sam";
      linesSI="$(\
         wc -l "$nameStr-bin-fragments-con.fa" |
           awk '{print $1};' \
      )";
      if [ "$linesSI" -lt 2 ];
      then
        rm "$nameStr-bin-fragments-con.fa";
      fi;
   fi;

   #******************************************************
   # Sec06 Sub05:
   #   - build consensus for unkown reads
   #******************************************************

   if [ -f "$nameStr-bin-fragments.fq" ];
   then
      $mapCmdStr "$nameStr-bin-hsp65-unkown.fq" \
        2>/dev/null |
        "$hsp65TBStr/tbCon" -sam - |
        "$hsp65TBStr/filtsam" -out-fasta |
        sed "s/^>[^ ]*/>$nameStr-unkown/;" \
        > "$nameStr-bin-hsp65-unkow-con.fa";
      linesSI="$( \
        wc -l "$nameStr-bin-hsp65-unkow-con.fa" |
           awk '{print $1};' \
      )";

      if [ "$linesSI" -lt 2 ];
      then
        rm "$nameStr-bin-hsp65-unkow-con.fa";
      fi;
   fi;
  
done < "$fileStr"; # Loop: read in databases
# for report have: name-barcode\thsp65\tdepth

printf "minimap2 version: %s\n" "$mapVersionStr" >&2;
printf "bioTools version: %s\n" \
    "$(getLin -v | sed 's/.*: //;')" \
  >&2;

#*=======================================================\
# License:
# 
# Creative Commons Legal Code
# 
# CC0 1.0 Universal
# 
#     CREATIVE COMMONS CORPORATION IS NOT A LAW FIRM AND
#     DOES NOT PROVIDE LEGAL SERVICES. DISTRIBUTION OF
#     THIS DOCUMENT DOES NOT CREATE AN ATTORNEY-CLIENT
#     RELATIONSHIP. CREATIVE COMMONS PROVIDES THIS
#     INFORMATION ON AN "AS-IS" BASIS. CREATIVE COMMONS
#     MAKES NO WARRANTIES REGARDING THE USE OF THIS
#     DOCUMENT OR THE INFORMATION OR WORKS PROVIDED
#     HEREUNDER, AND DISCLAIMS LIABILITY FOR DAMAGES
#     RESULTING FROM THE USE OF THIS DOCUMENT OR THE
#     INFORMATION OR WORKS PROVIDED HEREUNDER.
# 
# Statement of Purpose
# 
# The laws of most jurisdictions throughout the world
# automatically confer exclusive Copyright and Related
# Rights (defined below) upon the creator and subsequent
# owner(s) (each and all, an "owner") of an original work
# of authorship and/or a database (each, a "Work").
# 
# Certain owners wish to permanently relinquish those
# rights to a Work for the purpose of contributing to a
# commons of creative, cultural and scientific works
# ("Commons") that the public can reliably and without
# fear of later claims of infringement build upon, modify,
# incorporate in other works, reuse and redistribute as
# freely as possible in any form whatsoever and for any
# purposes, including without limitation commercial
# purposes. These owners may contribute to the Commons to
# promote the ideal of a free culture and the further
# production of creative, cultural and scientific works,
# or to gain reputation or greater distribution for their
# Work in part through the use and efforts of others.
# 
# For these and/or other purposes and motivations, and
# without any expectation of additional consideration or
# compensation, the person associating CC0 with a Work
# (the "Affirmer"), to the extent that he or she is an
# owner of Copyright and Related Rights in the Work,
# voluntarily elects to apply CC0 to the Work and publicly
# distribute the Work under its terms, with knowledge of
# his or her Copyright and Related Rights in the Work and
# the meaning and intended legal effect of CC0 on those
# rights.
# 
# 1. Copyright and Related Rights. A Work made available
#    under CC0 may be protected by copyright and related
#    or neighboring rights ("Copyright and Related
#    Rights"). Copyright and Related Rights include, but
#    are not limited to, the following:
# 
#   i. the right to reproduce, adapt, distribute, perform,
#      display, communicate, and translate a Work;
#  ii. moral rights retained by the original author(s)
#      and/or performer(s);
# iii. publicity and privacy rights pertaining to a
#      person's image or likeness depicted in a Work;
#  iv. rights protecting against unfair competition in
#      regards to a Work, subject to the limitations in
#      paragraph 4(a), below;
#   v. rights protecting the extraction, dissemination,
#      use and reuse of data in a Work;
#  vi. database rights (such as those arising under
#      Directive 96/9/EC of the European Parliament and of
#      the Council of 11 March 1996 on the legal
#      protection of databases, and under any national
#      implementation thereof, including any amended or
#      successor version of such directive); and
# vii. other similar, equivalent or corresponding rights
#      throughout the world based on applicable law or
#      treaty, and any national implementations thereof.
# 
# 2. Waiver. To the greatest extent permitted by, but not
#    in contravention of, applicable law, Affirmer hereby
#    overtly, fully, permanently, irrevocably and
#    unconditionally waives, abandons, and surrenders all
#    of Affirmer's Copyright and Related Rights and
#    associated claims and causes of action, whether now
#    known or unknown (including existing as well as
#    future claims and causes of action), in the Work (i)
#    in all territories worldwide, (ii) for the maximum
#    duration provided by applicable law or treaty
#    (including future time extensions), (iii) in any
#    current or future medium and for any number of
#    copies, and (iv) for any purpose whatsoever,
#    including without limitation commercial, advertising
#    or promotional purposes (the "Waiver"). Affirmer
#    makes the Waiver for the benefit of each member of
#    the public at large and to the detriment of
#    Affirmer's heirs and successors, fully intending that
#    such Waiver shall not be subject to revocation,
#    rescission, cancellation, termination, or any other
#    legal or equitable action to disrupt the quiet
#    enjoyment of the Work by the public as contemplated
#    by Affirmer's express Statement of Purpose.
# 
# 3. Public License Fallback. Should any part of the
#    Waiver for any reason be judged legally invalid or
#    ineffective under applicable law, then the Waiver
#    shall be preserved to the maximum extent permitted
#    taking into account Affirmer's express Statement of
#    Purpose. In addition, to the extent the Waiver is so
#    judged Affirmer hereby grants to each affected person
#    a royalty-free, non transferable, non sublicensable,
#    non exclusive, irrevocable and unconditional license
#    to exercise Affirmer's Copyright and Related Rights
#    in the Work (i) in all territories worldwide, (ii)
#    for the maximum duration provided by applicable law
#    or treaty (including future time extensions), (iii)
#    in any current or future medium and for any number of
#    copies, and (iv) for any purpose whatsoever,
#    including without limitation commercial, advertising
#    or promotional purposes (the "License"). The License
#    shall be deemed effective as of the date CC0 was
#    applied by Affirmer to the Work. Should any part of
#    the License for any reason be judged legally invalid
#    or ineffective under applicable law, such partial
#    invalidity or ineffectiveness shall not invalidate
#    the remainder of the License, and in such case
#    Affirmer hereby affirms that he or she will not (i)
#    exercise any of his or her remaining Copyright and
#    Related Rights in the Work or (ii) assert any
#    associated claims and causes of action with respect
#    to the Work, in either case contrary to Affirmer's
#    express Statement of Purpose.
# 
# 4. Limitations and Disclaimers.
# 
#  a. No trademark or patent rights held by Affirmer are
#     waived, abandoned, surrendered, licensed or
#     otherwise affected by this document.
#  b. Affirmer offers the Work as-is and makes no
#     representations or warranties of any kind concerning
#     the Work, express, implied, statutory or otherwise,
#     including without limitation warranties of title,
#     merchantability, fitness for a particular purpose,
#     non infringement, or the absence of latent or other
#     defects, accuracy, or the present or absence of
#     errors, whether or not discoverable, all to the
#     greatest extent permissible under applicable law.
#  c. Affirmer disclaims responsibility for clearing
#     rights of other persons that may apply to the Work
#     or any use thereof, including without limitation any
#     person's Copyright and Related Rights in the Work.
#     Further, Affirmer disclaims responsibility for
#     obtaining any necessary consents, permissions or
#     other rights required for any use of the Work.
#  d. Affirmer understands and acknowledges that Creative
#     Commons is not a party to this document and has no
#     duty or obligation with respect to this CC0 or use
#     of the Work.
#=======================================================*/
