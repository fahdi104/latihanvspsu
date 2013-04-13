#!/bin/bash
## /**
## @file DisplaySeparation.sh
## @brief Display wavefield separation result
## @author fahdi@gm2001.net
## @date April 2013 [update]
## */

#input
input=../data/Z_prepro.su
output_dn=../data/velf_dn.su
output_res=../data/velf_res.su
output_up=../data/velf_up.su
output_res2=../data/velf_res2.su

#get tt pick from header
#tt_picks=../data/tt_picks_auto.txt
#gettime pick from header
sugethw < $input key=lagb,gelev,scalel,tracr | sed -e 's/scalel=//' -e 's/gelev=//' -e 's/lagb=//' -e 's/tracr=//'\ \
	| sed '/^$/d' > tt-header.tmp
awk '{ printf "%4f %2f\n", $1/1000, ($2/(10^($3*-1))) }' tt-header.tmp > tt-header.txt
tt_picks=tt-header.txt

# a little house keeping
nrec=($(wc -l $tt_picks | awk '{print $1}'))
awk '{print $1*1000}' $tt_picks > tt.tmp 
a2b <tt.tmp n1=$nrec> tt_header.bin
awk '{print $1*0+0.200,$2}' $tt_picks > minustt.tmp
awk '{print $1*2,$2}' $tt_picks > twt.tmp
a2b < twt.tmp n1=$nrec> twt.bin

#TT alignment
tmin=0
tmax=8

sushw < $input infile=tt_header.bin key=delrt \
	| suchw key1=delrt key2=delrt a=200 b=-1 \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0.0 tmax=1.0> $input.tmp
sushw < $output_dn infile=tt_header.bin key=delrt \
	| suchw key1=delrt key2=delrt a=200 b=-1 | sushift tmin=$tmin tmax=$tmax|suwind tmin=0.0 tmax=1.0> $output_dn.tmp
sushw < $output_res infile=tt_header.bin key=delrt \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0.0 tmax=2 > $output_res.tmp
sushw < $output_up infile=tt_header.bin key=delrt  \
	| sushift tmin=$tmin tmax=$tmax|suwind tmin=0.0 tmax=2 > $output_up.tmp

suxwigb < $input.tmp title="Z Component aligned at +200 ms" key=gelev \
	curve=minustt.tmp npair=$nrec,1 curvecolor=red  perc=92 label2="depth" label1="twt (s)" wbox=500 xbox=10 style=vsp key=gelev&
suxwigb < $output_dn.tmp title="Downgoing aligned at +200 ms" key=gelev \
	curve=minustt.tmp npair=$nrec,1 curvecolor=red  perc=92 label2="depth" label1="twt (s)" wbox=500 xbox=520 style=vsp key=gelev &
suxwigb < $output_res.tmp title="Residual after Downgoing Removal aligned at +TT (TWT)" key=gelev \
	curve=twt.tmp npair=$nrec,1 curvecolor=red  perc=99 label1="twt (s)" label2="depth" wbox=500 xbox=10 & 
suxwigb < $output_up.tmp title="Upgoing Wavefield aligned at +TT (TWT)" key=gelev \
	curve=twt.tmp npair=$nrec,1 curvecolor=red perc=99 label1="twt (s)" label2="depth" wbox=500 xbox=520 &

#clean up
#rm *.tmp