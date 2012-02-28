#!/bin/bash
## @file CreateElasticSynthetic.sh
## @brief Do elastic synthetic modeling using ela2d
## @author fahdi@gm2001.net
## @date February 2012
## @todo set scalco & scalel for decimal number
## @todo read and convert receiver list from flat model building for elastic modeling purposes

#define model dimension
nx=100
dx=10
nz=300
dz=10
outputX=HMX.su
outputZ=Z.su

#Ela2D FD setup
## @todo this dt is for FD timestep modeling, should use appropriate dt for time step modeling
## @todo implement resampling for final su data
dt=0.002
tmax=3
f_cent=30

#source
#setting source
a2b < source_list.txt > source_list.bin
src_x=($(awk '{print $1}' source_list.txt))
src_z=($(awk '{print $2}' source_list.txt))
#load receiver
a2b < receiver_list.txt > receiver_list.bin
nrec=($(wc -l receiver_list.txt | awk '{print $1}'))
ns=($(echo $tmax/$dt+1 |bc -l))
#---------***** STOP HERE ****-------#####

#substitute
sed -e "s/src_x/$src_x/" -e "s/src_z/$src_z/" \
-e "s/seddt/$dt/" -e "s/sedtmax/$tmax/" -e "s/sedf_cent/$f_cent/" \
-e "s/nrec/$nrec/" \
 < ./template/ela2d.in.template > ela2d.in.tmp

sed -e "s/seddx/$dx/" -e "s/seddz/$dz/" \
-e "s/sednx/$nx/" -e "s/sednz/$nz/" \
 < ./template/grid.param.template > grid.param
 
cat ela2d.in.tmp receiver_list.txt > ela2d.in

#start ela2d
echo "Start Ela2D"
ela2d

echo "Convert Ela2D output to SU Format"
dtms=($(echo $dt*1000000 |bc -l))
suaddhead < seismicX.H@ ns=$ns |
sushw key=dt a=$dtms |
sushw key=gx,gelev infile=receiver_list.bin |
sushw key=sx a=$src_x b=0 j=$nrec |
sushw key=selev a=$src_z b=0 j=$nrec > $outputX

suaddhead < seismicZ.H@ ns=$ns |
sushw key=dt a=$dtms |
sushw key=gx,gelev infile=receiver_list.bin |
sushw key=sx a=$src_x b=0 j=$nrec  |
sushw key=selev a=$src_z b=0 j=$nrec > $outputZ

#clean Up

mv *.H* *.out ela2d_dir 
rm *.tmp *.bin 

echo "Ela2D Finished"

#display

suxwigb < $outputX title="X Component" perc=97 style=vsp key=gelev &
suxwigb < $outputZ title="Z Component" perc=97 style=vsp key=gelev &



