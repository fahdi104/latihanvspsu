#!/bin/bash

## /**
## * @brief Convert SEGY to SU format, setting required VSP headers
## * @brief Clean.sh can be used to clean up 
## * @file ImportSEGY.sh
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @todo ouput ascii geometry, consistent filenaming
## * @param input Specify your input SEGY file
## * @param output Specify your output SU file
## * @param tmin Minimum Output time
## * @param tmax Maximum Output time
## */

# Input
input=realZ.segy
output=realZ.su

# set parameter
tmin=0 #start time
tmax=4 #output time

segyread tape=$input verbose=1 endian=0 | segyclean > $output.tmp

#housekeeping, just to make output SU available for XWIGB
#get geometry to ascii
sugethw < $output.tmp key=lagb,gelev,scalel \
	| sed -e 's/scalel=//' -e 's/gelev=//' -e 's/lagb=//'| sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %2f\n", $1/1000, ($2/$3)*-1 }' tt-header.tmp > tt-header.txt
nrec=($(wc -l tt-header.txt | awk '{print $1}'))

#I don't know what's the correct convention for scalel & scalco?
#I recomputed gelev to be 1 decimal and reset scalel acordingly
#furthermore scalel and scalco will be treated differently
awk '{print $2*10}' tt-header.txt | a2b n1=$nrec > gelev.bin
sushw < $output.tmp key=gelev infile=gelev.bin> $output.tmp2
sushw < $output.tmp2 key=scalel a=-1> $output

#display
nrec=($(wc -l tt-header.txt | awk '{print $1}'))
suxwigb < $output title=$input perc=99 style=vsp key=gelev curve=tt-header.txt npair=$nrec,1 curvecolor=red &

#clean up
rm *.tmp*
rm *.bin

