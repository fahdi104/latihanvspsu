#!/bin/bash
## /**
## * @file CorridorStack.sh
## * @brief Create corridor stack
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo this is not optimum yet :(
## * @todo output muted align wave
## * @param input_decon_enh_up Input is final upgoing wavefield (after decon)
## * @param output_cstack Corridor Stack Output
## * @param tt ASCII file of Transit Time picks data
## */

#input
input_decon_enh_up=pef_up_enh.su.align
output_cstack=corr_stack.su
tt=tt-header.txt

#set parameter
corridor=0.08 #s
except_last_trace=5;

#housekeeping
nrec=($(wc -l $tt | awk '{print $1}')) #housekeeping
last_rec=$(($nrec - $except_last_trace))

awk -v corridor=$corridor -v last_rec=$last_rec \
	'BEGIN {i=1}{if (i<=last_rec){print (($1*2)+corridor), $2} else {print 9,$2} i++}' $tt \
	| awk '{ printf "%4f %d\n", $1, $2 }' > $tt.inside 

awk '{ printf "%4f %d\n", $1*2, $2 }' $tt > $tt.outside

#apply enhancement to pef up
awk '{print $2}' $tt > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin

awk '{print $1}' $tt.inside > tfile.inside.tmp
a2b < tfile.inside.tmp n1=$nrec> tfile.inside.bin

awk '{print $1}' $tt.outside > tfile.outside.tmp
a2b < tfile.outside.tmp n1=$nrec> tfile.outside.bin

#housekeeping-end

#display corridor window
suwind < $input_decon_enh_up tmin=0.4 tmax=1.6 | suxwigb perc=95 title="Enhanced Deconvolved Upgoing"  key=gelev curve=$tt.inside,$tt.outside npair=$nrec,$nrec curvecolor=red &

#mute, change word, stack
sumute < $input_decon_enh_up key=gelev nmute=$nrec xfile=xfile.bin tfile=tfile.inside.bin mode=1 \
	| sustack repeat=12 normpow=1.0 > $output_cstack
#display	
suwind <  $output_cstack tmin=0.4 tmax=1.6 \
	| suxwigb perc=99 xbox=610 wbox=200 label1='TWT (s)' title='Corridor Stack'&

#clean up
rm *.tmp
