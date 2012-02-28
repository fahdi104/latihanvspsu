#!/bin/bash
## @file Separation.sh
## @brief Run wavefield separation based on TT using median velocity filter
## @author fahdi@gm2001.net
## @date February 2012
## @todo clean up please

#wavefield separation
input=realZ.su
output_dn=velf_dn.su
output_res=velf_res.su
output_up=velf_up.su
level_down=9
level_up=7

timePicks=tt_picks_auto_smooth.txt
nrec=($(wc -l $timePicks | awk '{print $1}'))

awk '{print $2}' $timePicks > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin

awk '{print $1}' $timePicks > tfile.tmp
a2b < tfile.tmp n1=$nrec> tfile.bin


#processing
#tmin=0 
#tmax=5
#mix=1,1,1,1,1,1,1,1,1

sumedian < $input xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=0 median=1 nmed=$level_down sign=-1> $output_dn
sumedian < $input xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=1 median=1 nmed=$level_down sign=-1> $output_res
sumedian < $output_res xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=0 median=1 nmed=$level_up sign=+1> $output_up

suxwigb < HMX.su title="HMX" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red &
suxwigb < $input title="Z" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red &
suxwigb < $output_dn title="Downgoing" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red &
suxwigb < $output_res title="Residual-1" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red &
suxwigb < $output_up title="Upgoing" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red &

rm *.tmp