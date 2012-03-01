#!/bin/bash

## /**
## * @file
## * @brief Automatic FB picking
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo reinput TT pick back to SU file header
## * @param input SU file to be picked
## * @param output SU file after picked
## * @param output_picks ASCII file for automatic Transit Time pick result
## */

#input
input=Z.su
output=Z_picked.su #breaktime will saved at unscale header in this file
output_picks=tt_picks_auto.txt #ASCII output of breaktime picking 

#process
#do automatic picking
sufbpickw < $input > $output
#a little housekeeping 
sugethw < $output key=unscale,gelev | sed -e 's/unscale=//' -e 's/gelev=//'| sed '/^$/d' | sort -bn -k 2 | uniq > $output_picks
nrec=($(wc -l tt_picks_auto.txt | awk '{print $1}')) #calculate number of receiver

#display data and picks
suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev curve=$output_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&

#smoothing
octave --silent --eval "ttSmoothing('$output_picks')";

#clean up
rm test.su


