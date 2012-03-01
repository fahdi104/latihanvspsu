#!/bin/bash

## /**
## * @brief Do elastic synthetic modeling using ela2d
## * @brief Clean.sh can be used to clean up 
## * @brief Model can be displayed by typing ./DisplayModel.sh
## * @file CreateElasticSynthetic.sh
## * @author fahdi@gm2001.net
## * @date February 2012
## * @todo set scalco & scalel for decimal number
##  * @todo read and convert receiver list from flat model building for elastic modeling purposes
## * @param nx Number of model sample in X direction
## * @param dx Model sampling rate in X direction
## * @param nz Number of model sample in Z direction
## * @param dz Model sampling rate in Z direction
## */

#input
#define model dimension
nx=100
dx=10
nz=300
dz=10
outputX=HMX.su #specify filename for horizontal component
outputZ=Z.su #specify filename for vertical component

#set parameter
#Ela2D FD setup
## * @todo this dt is for FD timestep modeling, should use appropriate dt for time step modeling
## * @todo implement resampling for final su data
dt=0.002 #set timestep and will also be samplin rate for out put data, @TODO CHECK!!
tmax=3  #maximum recording time
f_cent=30 #dominant frequency

#source
#setting source, use *.txt from 1BuildFlatModel, convert it to binary for SU header requirement
#DO NOT MODIFY LINE AFTER THIS, UNLESS YOU KNOW WHAT YOU ARE DOING

#copy receiver from 1BuildFlatModel
cp ../1BuildFlatModel/*.dat .
cp ../1BuildFlatModel/*.txt .

#flip receiver list for Ela2D requirement
awk '{print "\t", $2, "\t", $1}' receiver_list.txt > receiver_list.tmp 
awk '{print "\t", $2, "\t", $1}' source_list.txt > source_list.tmp
mv receiver_list.tmp receiver_list.txt
mv source_list.tmp source_list.txt

a2b < source_list.txt > source_list.bin
src_x=($(awk '{print $1}' source_list.txt))
src_z=($(awk '{print $2}' source_list.txt))
#load receiver
a2b < receiver_list.txt > receiver_list.bin
nrec=($(wc -l receiver_list.txt | awk '{print $1}'))
ns=($(echo $tmax/$dt+1 |bc -l))

#substitute all input variables to Ela2D param & in file
sed -e "s/src_x/$src_x/" -e "s/src_z/$src_z/" \
-e "s/seddt/$dt/" -e "s/sedtmax/$tmax/" -e "s/sedf_cent/$f_cent/" \
-e "s/nrec/$nrec/" \
 < ./template/ela2d.in.template > ela2d.in.tmp

sed -e "s/seddx/$dx/" -e "s/seddz/$dz/" \
-e "s/sednx/$nx/" -e "s/sednz/$nz/" \
 < ./template/grid.param.template > grid.param
 
cat ela2d.in.tmp receiver_list.txt > ela2d.in

#Running Ela2D
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
suxwigb < $outputX title="X Component" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)" &
suxwigb < $outputZ title="Z Component" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)" &
