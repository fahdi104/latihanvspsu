#!/bin/bash
## /**
## * @file ApplyDecon.sh
## * @brief Apply PEF to upgoing wavefield
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo this is not optimum yet :(
## * @todo output muted align wave
## * @param input_up Upgoing wavefield to be deconvolved
## * @param tt ASCII file of Transit Time picks data
## * @param output_pef_up Upgoing Wavefield after predictive decon
## * @param output_pef_up_enh Enhancement of Upgoing Wavefield after predictive decon
## * @param enhc_up Number of median level for upgoing enhancement
## * @param minlag First lag of prediction filter (sec)
## * @param maxlag lag
## * @param pnoise relative additive noise level
## * @param bpf Four points of BPF filter
## */

#input
input_up=velf_up.su
tt=tt-header.txt
output_pef_up=pef_up.su
output_pef_up_enh=pef_up_enh.su
enhc_up=5

#set parameter
minlag=0.015 #s
maxlag=0.4 #s
pnoise=0.0005
bpf=3,5,120,140 #4 points bandpass specification

#housekeeping-start
awk '{print $1*0+0.200,$2}' $tt > minustt.tmp
awk '{print $1*2,$2}' $tt > twt.tmp

#align 
fac=1 # (+1) aligned TWT upgoing , (-1) aligned downgoing
al=0 # 0 for TWT upgoing, 200 for aligned at 200 msec
tmin=0
tmax=5
awk '{print $1*1000}' $tt > tt.tmp 
a2b <tt.tmp > tt_header.bin
##

nrec=($(wc -l $tt | awk '{print $1}')) #housekeeping

#apply enhancement to pef up
awk '{print $2}' $tt > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin

awk '{print $1}' $tt > tfile.tmp
a2b < tfile.tmp n1=$nrec> tfile.bin
#housekeeping-end

#check autocorrelation before PEF
#sugain < $input_up tpow=1 | suacor sym=1 norm=1 \
#	| suxwigb perc=95 label1="Time (sec)" label2="Level Number"  title="Autocorrelation" &

#Apply PEF
supef < $input_up minlag=$minlag maxlag=$maxlag pnoise=$pnoise  | sufilter f=$bpf > $output_pef_up
#sugain < $output_pef_up tpow=1 | suacor  sym=1 norm=1  \
#	| suxwigb title="Autocor after PEF minlag:$minlag s, maxlag:$maxlag s" perc=95 &

sumedian < $output_pef_up xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=0 median=1 nmed=$level_up sign=+1 \
	| sumute key=gelev nmute=$nrec xfile=xfile.bin tfile=tfile.bin mode=0 > $output_pef_up_enh

#display pef application on upgoing signal
sushw < $input_up infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0 tmax=$tmax> $input_up.align
sushw < $output_pef_up infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0 tmax=$tmax> $output_pef_up.align
sushw < $output_pef_up_enh infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0 tmax=$tmax> $output_pef_up_enh.align

suwind < $input_up.align tmin=0.4 tmax=1.4 | suxwigb perc=95 title="Upgoing Before PEF Decon" key=gelev curve=twt.tmp npair=$nrec,1 curvecolor=red style=vsp key=gelev &
suwind < $output_pef_up.align tmin=0.4 tmax=1.4 | suxwigb perc=95 title="Upgoing After PEF Decon (minlag:$minlag s, maxlag:$maxlag s)"  key=gelev curve=twt.tmp npair=$nrec,1 curvecolor=red style=vsp key=gelev  &
suwind < $output_pef_up_enh.align tmin=0.4 tmax=1.4 | suxwigb perc=95 title="Enhanced Upgoing After PEF Decon (minlag:$minlag s, maxlag:$maxlag s)"  key=gelev curve=twt.tmp npair=$nrec,1 curvecolor=red  style=vsp key=gelev &

#clean up
#rm *.bin
#rm *.tmp