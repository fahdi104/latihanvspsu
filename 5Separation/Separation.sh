#!/bin/bash
## /**
## * @file Separation.sh
## * @brief Run wavefield separation based on TT using median velocity filter
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo clean up please
## * @param input SU file to separate after PreProcessing
## * @param output_dn Downgoing wavefield
## * @param output_res Residual Wavefield after downgoing wavefield subtraction
## * @param output_up Upgoing wavefield (Enhanced Residual)
## * @param output_res2 2nd Residual after Upgoing extraction
## * @param timePicks ASCII file containing transit time picking 
## * @param level_down number median level for downngoing extraction
## * @param level_up number median level for upgoing extraction
## */

#input
input=Z_prepro.su
output_dn=velf_dn.su
output_res=velf_res.su
output_up=velf_up.su
output_res2=velf_res2.su
timePicks=tt-header.txt

#set parameter
level_down=9
level_up=7


#housekeeping
nrec=($(wc -l $timePicks | awk '{print $1}')) #housekeeping, check number of receiver

awk '{print $2}' $timePicks > xfile.tmp
a2b < xfile.tmp n1=$nrec> xfile.bin

awk '{print $1}' $timePicks > tfile.tmp
a2b < tfile.tmp n1=$nrec> tfile.bin

#processing

sumedian < $input xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=0 median=1 nmed=$level_down sign=-1> $output_dn
sumedian < $input xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=1 median=1 nmed=$level_down sign=-1> $output_res
sumedian < $output_res xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=0 median=1 nmed=$level_up sign=+1> $output_up
sumedian < $output_res xfile=xfile.bin tfile=tfile.bin key=gelev nshift=$nrec subtract=1 median=1 nmed=$level_up sign=+1> $output_res2

#suxwigb < HMX.su title="HMX" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $input title="Z" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_dn title="Downgoing" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_res title="Residual-1" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_up title="Upgoing" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&
suxwigb < $output_res2 title="Residual-2" perc=97 style=vsp key=gelev curve=$timePicks npair=$nrec,1 curvecolor=red label2="depth" label1="twt (s)"&

rm *.tmp