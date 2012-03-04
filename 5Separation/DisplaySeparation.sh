#!/bin/bash
## /**
## @file DisplaySeparation.sh
## @brief Display wavefield separation result
## @author fahdi@gm2001.net
## @date February 2012
## */

#input
input=Z_prepro.su
output_dn=velf_dn.su
output_res=velf_res.su
output_up=velf_up.su
output_res2=velf_res2.su
timePicks=tt-header.txt

# a little house keeping
nrec=($(wc -l $timePicks | awk '{print $1}')) #housekeeping, check number of receiver
awk '{print $1*1000}' $timePicks > tt.tmp 
a2b <tt.tmp > tt_header.bin
awk '{print $1*0+0.200,$2}' $timePicks > minustt.tmp
awk '{print $1*2,$2}' $timePicks > twt.tmp

#TT alignment
tmin=0
tmax=5

sushw < $input infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=200 b=-1 | sushift tmin=$tmin tmax=$tmax|suwind tmin=0.0 tmax=1.0> $input.tmp
sushw < $output_dn infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=200 b=-1 | sushift tmin=$tmin tmax=$tmax|suwind tmin=0.0 tmax=1.0> $output_dn.tmp
sushw < $output_res infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=0 b=1 | sushift tmin=$tmin tmax=$tmax|suwind tmin=0.4 tmax=1.5> $output_res.tmp
sushw < $output_up infile=tt_header.bin key=delrt | suchw key1=delrt key2=delrt a=0 b=1 | sushift tmin=$tmin tmax=$tmax|suwind tmin=0.4 tmax=1.5> $output_up.tmp

#suxwigb < $input.tmp title="Z Component aligned at +200 ms" key=gelev curve=minustt.tmp npair=$nrec,1 curvecolor=red  perc=92 label2="depth" label1="twt (s)" wbox=500 xbox=10 style=vsp key=gelev&
#suxwigb < $output_dn.tmp title="Downgoing aligned at +200 ms" key=gelev curve=minustt.tmp npair=$nrec,1 curvecolor=red  perc=92 label2="depth" label1="twt (s)" wbox=500 xbox=520 style=vsp key=gelev &
suxwigb < $output_res.tmp title="Residual after Downgoing Removal aligned at +TT (TWT)" key=gelev curve=twt.tmp npair=$nrec,1 curvecolor=red  perc=95 label1="depth" label2="twt (s)" wbox=500 xbox=10 & 
suxwigb < $output_up.tmp title="Upgoing Wavefield aligned at +TT (TWT)" key=gelev curve=twt.tmp npair=$nrec,1 curvecolor=red perc=95 label1="depth" label2="twt (s)" wbox=500 xbox=520 &

#clean up
#rm *.tmp