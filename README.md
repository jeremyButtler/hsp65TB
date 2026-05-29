# Use:

A script used to detect hsp65 speices in tuberculosis
  samples. The sensitivity is not the best, but it does
  detect some species.

# License:

Creative commons 0

# Usage:

# Install:

The hsp65Tb.sh script has an install command to install
  the needed programs for you. The programs and missing
  databases will be installed in your Downloads folder in
  the `hsp65TB` directory.

```
if [ ! "${HOME}/Downloads/hsp65TB" ];
then
   git clone \
      https://github.com/jeremyButtler/hsp65TB \
      "${HOME}/Downloads/hsp65TB";
fi;

cd "${HOME}/Downloads/hsp65TB";
sh hsp65TB.sh install;
```

# Use:

Set up a spread sheet with you sample ids. The easy way
  is to use hsp65Tb's intneral system. The internall
  system will add all directories named barcode to the
  file.

```
sh hsp65Tb.sh mkfile out /path/to/fastq_pass > out.tsv;
```

After making the file you can then run it with

```
sh hsp65Tb.sh out.tsv > out-report.tsv;
```

For the help message do `hsp65Tb.sh -h`.
