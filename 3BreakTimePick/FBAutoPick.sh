#!/bin/bash
## @file FBAutoPick,sh
## @brief Automatic FB picking
## @author fahdi@gm2001.net
## @date February 2012
## @todo reinput TT pick back to SU file header

##define model dimension
nx=100
dx=10
nz=300
dz=10

input=realZ.su
output=realZ_picked.su
output_picks=tt_picks_auto.txt

sufbpickw < $input > $output
sugethw < $output key=unscale,gelev | sed -e 's/unscale=//' -e 's/gelev=//'| sed '/^$/d' | sort -bn -k 2 | uniq > $output_picks
nrec=($(wc -l tt_picks_auto.txt | awk '{print $1}'))

suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev curve=$output_picks npair=$nrec,1 curvecolor=red &
#smoothing
octave --silent --eval "ttSmoothing('$output_picks')";
#clean up
#rm *.tmp
rm test.su


