#!/bin/bash

## /**
## * @file Preprocessing.sh
## * @brief Do Preprocessing: BPF, Normalize, TVG
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo Normalize basd on RMS value of Downgoing at certain window
## * @param input SU file to process
## * @param output_bpf output SU file after BPF filter
## * @param bpf Four points of BPF filter
## * @param output_norm output SU file after normalization (RMS whole window operation)
## * @param output_tvg SU file after TimeVaryingGain (
## * @param tpow TVG constant
## * @param final_output Output after all preprocessing workflow in SU format
## */

#input
input=realZ.su
output_bpf=Z_picked_bpf.su # output after BPF
output_norm=Z_picked_bpf_norm.su #output after BPF followed RMS Normalization
output_tvg=Z_picked_bpf_norm_tvg.su #output after BPF followed RMS Normalization followed by TimeVaryingGain
final_output=Z_prepro.su #housekeeping to make naming convention
tt=tt-header.txt

#set parameter
bpf=3,5,130,150 #4 points bandpass specification
tpow=1.1 #multiply data by t^tpow

#bpf
sufilter < $input f=$bpf > $output_bpf

#normalize by dividing with RMS
sugain < $output_bpf pbal=1 > $output_norm

#run exponential gain
sugain < $output_norm tpow=$tpow > $output_tvg
cp $output_tvg $final_output #housekeeping to make naming convention

#display
nrec=($(wc -l $tt | awk '{print $1}')) #housekeeping, check number of receiver

suxwigb < $input title="Input" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)" x1beg=0.0 x1end=1.4 xbox=10 wbox=500 curve=$tt npair=$nrec,1 curvecolor=red &
#suxwigb < $output_bpf title="BPF: $bpf" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)" x1beg=0.0 x1end=1.4 xbox=520 wbox=500&
#suxwigb < $output_norm title="BPF: $bpf + Normalize by RMS" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)" x1beg=0.0 x1end=1.4 xbox=10 wbox=500&
suxwigb < $output_tvg title="BPF: $bpf + Normalize by RMS + Gain ($tpow)" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)" x1beg=0.0 x1end=1.4 xbox=520 wbox=500 curve=$tt npair=$nrec,1 curvecolor=red &