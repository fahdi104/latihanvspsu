#!/bin/bash
## /**
## * @file Separation.sh
## * @brief Run wavefield separation based on TT using median velocity filter
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @param input SU file to separate after PreProcessing
## * @param output_dn Downgoing wavefield
## * @param output_res Residual Wavefield after downgoing wavefield subtraction
## * @param output_up Upgoing wavefield (Enhanced Residual)
## * @param output_res2 2nd Residual after Upgoing extraction
## * @param tt_picks ASCII file containing transit time picking 
## * @param level_down number median level for downngoing extraction
## * @param level_up number median level for upgoing extraction
## */

#input
input=../data/Z_prepro.su
output_dn=../data/velf_dn.su
output_res=../data/velf_res.su
output_up=../data/velf_up.su
output_res2=../data/velf_res2.su

tmin=0
tmax=4

#get tt pick from header
#tt_picks=../data/tt_picks_auto.txt
#gettime pick from header
sugethw < $input key=lagb,gelev,scalel,tracr \
	| sed -e 's/scalel=//' -e 's/gelev=//' -e 's/lagb=//' -e 's/tracr=//' | sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %2f\n", $1/1000, ($2/(10^($3*-1))) }' tt-header.tmp > tt-header.txt
tt_picks=tt-header.txt

#set parameter
level_down=13
level_up=7

#housekeeping
nrec=($(wc -l $tt_picks | awk '{print $1}')) 
awk '{print $4}' tt-header.tmp > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin
awk '{print $1}' $tt_picks > tfile.tmp
a2b < tfile.tmp n1=$nrec> tfile.bin

#processing
#@todo output tmax need to be read from data
suwind < $input tmin=$tmin tmax=10\
	| sumedian xfile=xfile.bin tfile=tfile.bin key=tracr nshift=$nrec subtract=0 median=1 nmed=$level_down sign=-1 \
	| suwind tmin=$tmin tmax=$tmax > $output_dn
suwind < $input tmin=$tmin tmax=10\
	| sumedian xfile=xfile.bin tfile=tfile.bin key=tracr nshift=$nrec subtract=1 median=1 nmed=$level_down sign=-1 \
	| suwind tmin=$tmin tmax=$tmax > $output_res
suwind < $output_res $input tmin=$tmin tmax=10\
	| sumedian xfile=xfile.bin tfile=tfile.bin key=tracr nshift=$nrec subtract=0 median=1 nmed=$level_up sign=+1 \
	| suwind tmin=$tmin tmax=$tmax > $output_up
suwind < $output_res $input tmin=$tmin tmax=10\
	| sumedian xfile=xfile.bin tfile=tfile.bin key=tracr nshift=$nrec subtract=1 median=1 nmed=$level_up sign=+1 \
	| suwind tmin=$tmin tmax=$tmax > $output_res2

#display
suwind < $input tmin=$tmin tmax=$tmax | suxwigb title="Z after Preprocessing" perc=99 style=vsp key=gelev curve=$tt_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_dn title="Downgoing" perc=99 style=vsp key=gelev curve=$tt_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_res title="Residual-1" perc=99 style=vsp key=gelev curve=$tt_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_up title="Upgoing" perc=99 style=vsp key=gelev curve=$tt_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_res2 title="Residual-2" perc=99 style=vsp key=gelev curve=$tt_picks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&

#clean up
rm *.tmp
rm *.bin