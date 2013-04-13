#!/bin/bash

## /**
## * @file
## * @brief Automatic FB picking
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @param input SU file to be picked
## * @param window_pick searching window for break time pick
## * @param output SU file after picked
## * @param output_picks ASCII file for automatic Transit Time pick result
## */

#input
input=../data/Z.su
output=../data/Z_picked.su #breaktime will saved at unscale header in this file
output_picks=../data/tt_picks_auto.txt #ASCII output of breaktime picking 
window_pick=0.03 #you need to test this
#process
sufbpickw < $input window=$window > out.tmp

#a little housekeeping 
sugethw < out.tmp key=unscale,gelev,scalel \
	| sed -e 's/unscale=//' -e 's/gelev=//' -e 's/scalel=//' | sed '/^$/d' | sort -bn -k 2 | uniq | awk '{print $1,($2/(-1*10*$3))}' > $output_picks

#smoothing
#octave --silent --eval "ttSmoothing('$output_picks')";

#reinject to $input under header lagb (units ms)
nrec=($(wc -l $output_picks | awk '{print $1}')) #calculate number of receiver

awk '{print $1*1000," ",$1}' $output_picks > tt.tmp
a2b < tt.tmp n1=$nrec> tt.bin
sushw < $input key=lagb,unscale infile=tt.bin > $output

#display data and picks
suxwigb < $output title="Z Component" perc=99.5 style=vsp key=gelev \
	curve=$output_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&

#clean up
rm test.su
rm *.bin *.tmp


