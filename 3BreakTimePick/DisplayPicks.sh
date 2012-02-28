#!/bin/bash
## @file DisplayPicks.sh
## @brief Display T-D curve
## @author fahdi@gm2001.net
## @date February 2012
## @todo run cosine correction, compute tt correction to SRD, compute interval velocity, rms velocity
## @todo input well geometry for cosine correction
## @todo plotting velocity etc etc

input=realZ.su
input_tt=tt_picks_auto_smooth.txt
output_tt=tt_picks_correctionToSRD.txt

#dipslay pick
nrec=($(wc -l $input_tt | awk '{print $1}'))
suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev curve=$input_tt npair=$nrec,1 curvecolor=red &

#display TD
#TODO: reverse pick

#calculate interval velocity
octave --silent --eval "ttCorrection('$input_tt','$output_tt')"
xgraph $input_tt &
xgraph $output_tt &