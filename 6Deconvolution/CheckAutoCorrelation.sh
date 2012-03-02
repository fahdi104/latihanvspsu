#!/bin/bash
## /**
## * @file CheckAutoCorrelation.sh
## * @brief Check auto correlation to determine optimum lag and prediction on downgoing wavefield
## * @author fahdi@gm2001.net
## * @date February 2012
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
input_dn=velf_dn.su
tt=tt-header.txt
output_pef_dn=pef_dn.su

#set parameter
minlag=0.015 #s
maxlag=0.4 #s
pnoise=0.0005
bpf=3,5,120,140 #4 points bandpass specification

#align downgoing
fac=-1 # (+1) aligned TWT upgoing , (-1) aligned downgoing
al=200 # 0 for TWT upgoing, 200 for aligned at 200 msec
tmin=0
tmax=5
awk '{print $1*1000}' $tt > tt.tmp 
a2b <tt.tmp > tt_header.bin

#check autocorrelation before PEF
sugain < $input_dn tpow=1 | suacor sym=1 norm=1 \
	| suxwigb perc=95 label1="Time (sec)" label2="Level Number"  title="Autocorrelation" wbox=550 xbox=10&
#Apply to Attack Reveberations
supef < $input_dn minlag=$minlag maxlag=$maxlag pnoise=$pnoise  | sufilter f=$bpf > $output_pef_dn
sugain < $output_pef_dn tpow=1 | suacor  sym=1 norm=1  \
	| suxwigb title="Autocor after PEF minlag:$minlag s, maxlag:$maxlag s" perc=95 label1="Time (sec)" label2="Level Number" wbox=550 xbox=570&


#display pef application on downgoing signal
sushw < $input_dn infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0.1 tmax=0.8> $input_dn.align.tmp
sushw < $output_pef_dn infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=$al b=$fac \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0.1 tmax=0.8> $output_pef_dn.align.tmp

suxwigb < $input_dn.align.tmp perc=95 title="Downgoing Before PEF Decon" label1="Time (sec)" label2="Level Number"  wbox=550 xbox=10&
suxwigb < $output_pef_dn.align.tmp perc=95 title="Downgoing  After PEF Decon (minlag:$minlag s, maxlag:$maxlag s)"  label1="Time (sec)" label2="Level Number"  wbox=550 xbox=570&

