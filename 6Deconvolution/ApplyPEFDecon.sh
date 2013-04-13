#!/bin/bash
## /**
## * @file ApplyPEFDecon.sh
## * @brief Apply PEF to upgoing wavefield
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @todo this is not optimum yet :(
## * @param input_up Upgoing wavefield to be deconvolved
## * @param tt_picks ASCII file of Transit Time picks data
## * @param output_pef_up Upgoing Wavefield after predictive decon
## * @param output_pef_up_enh Enhancement of Upgoing Wavefield after predictive decon
## * @param enhc_up Number of median level for upgoing enhancement
## * @param minlag First lag of prediction filter (sec)
## * @param maxlag lag
## * @param pnoise relative additive noise level
## * @param bpf Four points of BPF filter
## */

#input
input_up=../data/velf_up.su
output_pef_up=../data/pef_up.su
output_pef_up_enh=../data/pef_up_enh.su
enhc_up=5

#set parameter
minlag=0.015 #s
maxlag=0.4 #s
pnoise=0.0005
bpf=3,5,40,60 #4 points bandpass specification
tmin=0
tmax=5

#get tt pick from header
sugethw < $input_up key=lagb,gelev,scalel,tracr \
	| sed -e 's/scalel=//' -e 's/gelev=//' -e 's/lagb=//' -e 's/tracr=//'| sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %2f\n", $1/1000, ($2/(10^($3*-1))) }' tt-header.tmp > tt-header.txt
tt_picks=tt-header.txt

# a little house keeping
nrec=($(wc -l $tt_picks | awk '{print $1}'))
awk '{print $1*1000}' $tt_picks > tt.tmp 
a2b <tt.tmp n1=$nrec> tt_header.bin
awk '{print $1*2,$2}' $tt_picks > twt.tmp
a2b < twt.tmp n1=$nrec> twt.bin
##

#apply enhancement to pef up
awk '{print $4}' tt-header.tmp > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin

awk '{print $1}' $tt_picks > tfile.tmp
a2b < tfile.tmp n1=$nrec> tfile.bin
#housekeeping-end

#check autocorrelation before PEF
#sugain < $input_up tpow=1 | suacor sym=1 norm=1 \
#	| suxwigb perc=95 label1="Time (sec)" label2="Level Number"  title="Autocorrelation" &

#Apply PEF
supef < $input_up minlag=$minlag maxlag=$maxlag pnoise=$pnoise | sufilter f=$bpf > $output_pef_up
#sugain < $output_pef_up tpow=1 | suacor  sym=1 norm=1  \
#	| suxwigb title="Autocor after PEF minlag:$minlag s, maxlag:$maxlag s" perc=95 &

suwind < $output_pef_up tmin=0.0 tmax=10.0 \
	| sumedian xfile=xfile.bin tfile=tfile.bin key=tracr nshift=$nrec subtract=0 median=1 nmed=$level_up sign=+1 \
	| suwind tmin=0.0 tmax=5.0> $output_pef_up_enh

#display pef application on upgoing signal
sushw < $input_up infile=tt_header.bin key=delrt \
	| sushift tmin=$tmin tmax=$tmax \
	| suwind tmin=0.0 tmax=$tmax > $input_up.align
sushw < $output_pef_up infile=tt_header.bin key=delrt \
	| sushift tmin=$tmin tmax=$tmax \
	| suwind tmin=0.0 tmax=$tmax > $output_pef_up.align
sushw < $output_pef_up_enh infile=tt_header.bin key=delrt \
	| sushift tmin=$tmin tmax=$tmax \
	| suwind tmin=0.0 tmax=$tmax > $output_pef_up_enh.align

suwind < $input_up.align tmin=$tmin tmax=$tmax \
	| suxwigb perc=99 title="Upgoing Before PEF Decon" key=gelev curve=twt.tmp npair=$nrec,1 curvecolor=red  &
suwind < $output_pef_up.align tmin=$tmin tmax=$tmax \
	| suxwigb perc=99 title="Upgoing After PEF Decon (minlag:$minlag s, maxlag:$maxlag s)" key=gelev \
	curve=twt.tmp npair=$nrec,1 curvecolor=red &
suwind < $output_pef_up_enh.align tmin=$tmin tmax=$tmax \
	| suxwigb perc=99 title="Enhanced Upgoing After PEF Decon (minlag:$minlag s, maxlag:$maxlag s)" key=gelev \
	curve=twt.tmp npair=$nrec,1 curvecolor=red &

#clean up
#rm *.bin
#rm *.tmp