#!/bin/bash
## /**
## * @file CorridorStack.sh
## * @brief Create corridor stack
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @param input_decon_enh_up Input is final upgoing wavefield (after decon)
## * @param output_cstack Corridor Stack Output
## * @param tt ASCII file of Transit Time picks data
## */

#input
input_decon_enh_up=../data/pef_up_enh.su.align
output_cstack=../data/corr_stack.su

#set parameter
corridor=0.08 #s
except_last_trace=5;

tmin=0
tmax=4

#gettime pick from header
sugethw < $input_decon_enh_up key=lagb,gelev,scalel,tracr \
	| sed -e 's/scalel=//' -e 's/gelev=//' -e 's/lagb=//' -e 's/tracr=//'| sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %2f\n", $1/1000, ($2/(10^($3*-1))) }' tt-header.tmp > tt-header.txt
tt_picks=tt-header.txt

#housekeeping
nrec=($(wc -l $tt_picks | awk '{print $1}')) #housekeeping
last_rec=$(($nrec - $except_last_trace))

awk -v corridor=$corridor -v last_rec=$last_rec \
	'BEGIN {i=1}{if (i<=last_rec){print (($1*2)+corridor), $2} else {print 9,$2} i++}' $tt_picks \
	| awk '{ printf "%4f %d\n", $1, $2 }' > $tt_picks.inside 

awk '{ printf "%4f %d\n", $1*2, $2 }' $tt_picks > $tt_picks.outside

#apply enhancement to pef up
awk '{print $4}' tt-header.tmp > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin

awk '{print $1}' $tt_picks.inside > tfile.inside.tmp
a2b < tfile.inside.tmp n1=$nrec> tfile.inside.bin

awk '{print $1}' $tt_picks.outside > tfile.outside.tmp
a2b < tfile.outside.tmp n1=$nrec> tfile.outside.bin

#display corridor window
sumute < $input_decon_enh_up key=tracr nmute=$nrec xfile=xfile.bin tfile=tfile.outside.bin mode=0 \
	| suwind tmin=$tmin tmax=$tmax \
	| suxwigb perc=99.9 title="Enhanced Deconvolved Upgoing"  key=gelev \
	curve=$tt_picks.inside,$tt_picks.outside npair=$nrec,$nrec curvecolor=red label1='TWT (s)' label2='depth'&

#mute, change word, stack
sumute < $input_decon_enh_up key=tracr nmute=$nrec xfile=xfile.bin tfile=tfile.outside.bin mode=0 \
	| sumute  key=tracr nmute=$nrec xfile=xfile.bin tfile=tfile.inside.bin mode=1 \
	| sustack repeat=12 normpow=1.0 > $output_cstack
#display	
suwind <  $output_cstack tmin=$tmin tmax=$tmax \
	| suxwigb perc=99.9 xbox=610 wbox=200 label1='TWT (s)' title='Corridor Stack'&

#clean up
#rm *.tmp
