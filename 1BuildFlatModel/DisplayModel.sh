#!/bin/bash
## @file DisplayModel.sh
## @brief Display Created Model
## @author fahdi@gm2001.net
## @date February 2012

##define model dimension
nx=100
dx=10
nz=300
dz=10
nrcv=($(wc -l receiver_list.txt | awk '{print $1}'))

#display
ximage < vel_P.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=rgb1 npair=$nrcv,1 curve=receiver_list.txt,source_list.txt title="Vp"&
ximage < vel_S.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=rgb1 npair=$nrcv,1 curve=receiver_list.txt,source_list.txt title="Vs"&
ximage < density.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=rgb1 npair=$nrcv,1 curve=receiver_list.txt,source_list.txt title="Density"&
