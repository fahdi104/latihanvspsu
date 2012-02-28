#!/bin/bash
## @file BreakTimePick.sh
## @brief Manually break time picking
## @author fahdi@gm2001.net
## @date February 2012

##define model dimension
nx=100
dx=10
nz=300
dz=10

input=Z.su

#suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev mpicks=tt_picks.txt &

sort -n -k 2 tt_picks.txt > tt_picks.tmp
mv tt_picks.tmp tt_picks.txt

suxwigb < $input title="Z Component" perc=97 style=vsp key=gelev curve=tt_picks.txt npair=89 curvecolor=red &


