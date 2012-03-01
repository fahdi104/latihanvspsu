#!/bin/bash

## /**
## * @file BreakTimePick.sh
## * @brief Manually break time picking, using ximage picking utility
## * @author fahdi@gm2001.net
## * @date February 2012
## * @param input SU file to be picked
## * @param output_picks ASCII file for automatic Transit Time pick result
## */

input=Z.su
output_picks=tt_picks_auto.txt #ASCII output of breaktime picking 

#display data, move your cursor on break time and hit S on your keyboard
suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev mpicks=$output_picks

# a little house keeping
sort -n -k 2 $output_picks > tt_picks.tmp
mv tt_picks.tmp $output_picks
nrec=($(wc -l $output_picks | awk '{print $1}')) #calculate number of receiver

#display
suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev curve=$output_picks npair=$nrec curvecolor=red &


