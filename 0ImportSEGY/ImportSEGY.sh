#!/bin/bash

## /**
## * @brief Convert SEGY to SU format, setting required VSP headers
## * @brief Clean.sh can be used to clean up 
## * @file ImportSEGY.sh
## * @author fahdi@gm2001.net
## * @date February 2012
## * @param input Specify your input SEGY file
## * @param output Specify your output SU file
## * @param tmin Minimum Output time
## * @param tmax Maximum Output time
## * @todo incorporate scalel for gelev recomputation
## */

# Input
input=VSI_007_A_gac_wavefield_z.sgy
output=realZ.su

# set parameter
tmin=0 #start time
tmax=4 #output time

segyread tape=$input verbose=1 endian=0 | suwind tmin=$tmin tmax=$tmax > $output.tmp1

#housekeeping, just to make output SU available for XWIGB
#this is not a good practice, because I have to strip SEGY headers, will think about this later
sugethw < $output.tmp1 key=lagb,gelev | sed -e 's/unscale=//' -e 's/gelev=//' -e 's/lagb=//'| sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %4d\n", $1/1000, $2/100 }' tt-header.tmp > tt-header.txt
nrec=($(wc -l tt-header.txt | awk '{print $1}'))

awk '{print $2}' tt-header.txt | a2b n1=$nrec > gelev.bin
sushw < $output.tmp1 key=d1,scalel,scalco > $output.tmp2
sushw < $output.tmp2 key=gelev infile=gelev.bin> $output

#display
nrec=($(wc -l tt-header.txt | awk '{print $1}'))

suxwigb < $output title=$input perc=97 style=vsp key=gelev curve=tt-header.txt npair=$nrec,1 curvecolor=red &

#clean up
rm *.tmp*
rm *.bin
