#!/bin/bash
## /**
## * @file CheckAutoCorrelation.sh
## * @brief Check auto correlation to determine optimum lag and prediction on downgoing wavefield
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @todo this is not optimum yet :(
## * @param input_dn Downgoing wavefield
## * @param tt ASCII file of Transit Time picks data
## * @param output_pef_dn Downgoing wavefield after predictive deconvolution
## * @param minlag First lag of prediction filter (sec)
## * @param maxlag lag
## * @param pnoise relative additive noise level
## * @param bpf Four points of BPF filter
## */

#input
input_dn=../data/velf_dn.su
output_pef_dn=../data/velf_dn.supef_dn.su

#set parameter
minlag=0.015 #s
maxlag=0.4 #s
pnoise=0.0005
bpf=3,5,120,140 #4 points bandpass specification

#get tt pick from header
#tt_picks=../data/tt_picks_auto.txt
#gettime pick from header
sugethw < $input_dn key=lagb,gelev,scalel,tracr \
	| sed -e 's/scalel=//' -e 's/gelev=//' -e 's/lagb=//' -e 's/tracr=//'\ | sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %2f\n", $1/1000, ($2/(10^($3*-1))) }' tt-header.tmp > tt-header.txt
tt_picks=tt-header.txt

# a little house keeping
nrec=($(wc -l $tt_picks | awk '{print $1}'))
awk '{print $1*1000}' $tt_picks > tt.tmp 
a2b <tt.tmp n1=$nrec> tt_header.bin
awk '{print $1*0+0.200,$2}' $tt_picks > minustt.tmp
awk '{print $1*2,$2}' $tt_picks > twt.tmp
a2b < twt.tmp n1=$nrec> twt.bin

#align downgoing
tmin=0
tmax=5

nrec=($(wc -l $tt_picks | awk '{print $1}')) #calculate number of receiver
awk '{print $1*1000}' $tt_picks > tt.tmp 
a2b <tt.tmp n1=$nrec > tt_header.bin

#check autocorrelation before PEF
sugain < $input_dn tpow=1 | suacor sym=1 norm=1 \
	| suxwigb perc=95 label1="Time (sec)" label2="Level Number"  title="Autocorrelation" wbox=550 xbox=10&

#Apply to Attack Reveberations
supef < $input_dn minlag=$minlag maxlag=$maxlag pnoise=$pnoise  | sufilter f=$bpf > $output_pef_dn
sugain < $output_pef_dn tpow=1 | suacor  sym=1 norm=1  \
	| suxwigb title="Autocor after PEF minlag:$minlag s, maxlag:$maxlag s" perc=95 \
	label1="Time (sec)" label2="Level Number" wbox=550 xbox=570&

#display pef application on downgoing signal
#sushw < $input_dn infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
#	| sushift tmin=$tmin tmax=$tmax | suwind tmin=0.1 tmax=0.8> $input_dn.align.tmp
#sushw < $output_pef_dn infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
#	| sushift tmin=$tmin tmax=$tmax | suwind tmin=0.1 tmax=0.8> $output_pef_dn.align.tmp

sushw < $input_dn infile=tt_header.bin key=delrt \
	| suchw key1=delrt key2=delrt a=200 b=-1 \
	| sushift tmin=$tmin tmax=$tmax \
	|suwind tmin=0.0 tmax=0.5> $input_dn.align.tmp
sushw < $output_pef_dn infile=tt_header.bin key=delrt \
	| suchw key1=delrt key2=delrt a=200 b=-1 \
	| sushift tmin=$tmin tmax=$tmax \
	|suwind tmin=0.0 tmax=0.5> $output_pef_dn.align.tmp

suxwigb < $input_dn.align.tmp perc=99 title="Downgoing Before PEF Decon" \
	label1="Time (sec)" label2="Level Number"  wbox=550 xbox=10&
suxwigb < $output_pef_dn.align.tmp perc=99 title="Downgoing  After PEF Decon (minlag:$minlag s, maxlag:$maxlag s)"  \
	label1="Time (sec)" label2="Level Number"  wbox=550 xbox=570&

#clean up
rm *.bin
rm *.tmp

