#!/bin/bash

## /**
## * @file FrequencyAnalysis.sh
## * @brief Create FZ Spectrum & FK-Spectrum
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo Check synthetic model, because the amplitude spectrum is not correct
## * @param input SU file to analyze
## * @param output_fz Spectrum of Frequency vs Depth in SU format
## * @param output_fk Spectrum of Frequency vs Wavenumber in SU format
## */

#input
input=realZ.su
output_fz=z-spec-fz.su
output_fk=z-spec-fk.su

#compute fz
suspecfx < $input > $output_fz

#compute fk
suspecfk < $input > $output_fk

#display
nrec=($(wc -l tt-header.txt | awk '{print $1}'))
suxwigb < $input title=$input perc=97 style=vsp key=gelev curve=tt-header.txt npair=$nrec,1 curvecolor=red label2="Depth" label1="TWT(s)"&

#displayfz
suximage < $output_fz cmap=hsv2 perc=95 legend=1 title='FZ Spectrum' label1='Freq (Hz)' label2='Level Number' &

#displayfk
suximage < $output_fk cmap=hsv2 perc=95 legend=1 title='FK Spectrum' label1='Freq (Hz)' label2='Wavenumber (1/kFT)' & 

