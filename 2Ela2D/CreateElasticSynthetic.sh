#!/bin/bash

## /**
## * @WARNING Ela2D is still buggy. Don't know why the direct P TT is slower
## * @brief Do elastic synthetic modeling using ela2d, currently set using ricker wavelet, dilatational source
## * @brief Clean.sh can be used to clean up 
## * @brief Model can be displayed by typing ./DisplayModel.sh
## * @file CreateElasticSynthetic.sh
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @todo create proper 2D geom header sx,sy,selev,gx,gy,gelev
## * @param nx Number of model sample in X direction
## * @param dx Model sampling rate in X direction
## * @param nz Number of model sample in Z direction
## * @param dz Model sampling rate in Z direction
## * @param outputX Output for horizontal component
## * @param outputZ Output for vertical component
## * @param source_listing ASCII file for source listing (filename:source_list.txt, please do not change the filename)
## * @param receiver_listing ASCII file for receiver listing (filename:receiver_list.txt, please do not change the filename)
## */

#input
#define model dimension, @todo this should be read automatically
nx=100
dx=10
nz=300
dz=10
outputX=../data/HMX.su #specify filename for horizontal component,  keep directory name the same
outputZ=../data/Z.su #specify filename for vertical component, keep directory name the same
model=model01

#set parameter
#Ela2D FD setup
## * @todo this dt is for FD timestep modeling, should use appropriate dt for time step modeling
## * @todo implement resampling for final su data
dt=0.002 #set timestep and will also be samplin rate for out put data, @TODO CHECK!!
tmax=3  #maximum recording time
f_cent=15 #dominant frequency

#source
#setting source, use *.txt from 1BuildFlatModel, convert it to binary for SU header requirement
#DO NOT MODIFY LINE AFTER THIS

#read model receiver from 1BuildFlatModel or copy it :) 
cp ../model/${model}*.dat .
#rename model to ela2D format
mv ${model}_vel_P.dat vel_P.dat
mv ${model}_vel_S.dat vel_S.dat
mv ${model}_density.dat density.dat

#flip receiver list for Ela2D requirement
awk '{print "\t", $2, "\t", $1}' ../model/${model}_receiver_list.txt > receiver_list.tmp 
awk '{print "\t", $2, "\t", $1}' ../model/${model}_source_list.txt > source_list.tmp
mv receiver_list.tmp ${model}_receiver_list.txt
mv source_list.tmp ${model}_source_list.txt

a2b < ${model}_source_list.txt > ${model}_source_list.bin
src_x=($(awk '{print $1}' ${model}_source_list.txt))
src_z=($(awk '{print $2}' ${model}_source_list.txt))
#load receiver
a2b < ${model}_receiver_list.txt > ${model}_receiver_list.bin
nrec=($(wc -l ${model}_receiver_list.txt | awk '{print $1}'))
ns=($(echo $tmax/$dt+1 |bc -l))

#substitute all input variables to Ela2D param & in file
sed -e "s/src_x/$src_x/" -e "s/src_z/$src_z/" \
-e "s/seddt/$dt/" -e "s/sedtmax/$tmax/" -e "s/sedf_cent/$f_cent/" \
-e "s/nrec/$nrec/" \
 < ./template/ela2d.in.template > ela2d.in.tmp

sed -e "s/seddx/$dx/" -e "s/seddz/$dz/" \
-e "s/sednx/$nx/" -e "s/sednz/$nz/" \
 < ./template/grid.param.template > grid.param
 
cat ela2d.in.tmp ${model}_receiver_list.txt > ela2d.in

#Running Ela2D
echo "Start Ela2D"
ela2d

echo "Convert Ela2D output to SU Format"
dtms=($(echo $dt*1000000 |bc -l))
suaddhead < seismicX.H@ ns=$ns |
sushw key=dt a=$dtms |
sushw key=gx,gelev infile=${model}_receiver_list.bin |
sushw key=sx a=$src_x b=0 j=$nrec |
sushw key=selev a=$src_z b=0 j=$nrec |
suaddnoise sn=75 > $outputX 
segyhdrs < $outputX

suaddhead < seismicZ.H@ ns=$ns |
sushw key=dt a=$dtms |
sushw key=gx,gelev infile=${model}_receiver_list.bin |
sushw key=sx a=$src_x b=0 j=$nrec  |
sushw key=selev a=$src_z b=0 j=$nrec |
suaddnoise sn=75 > $outputZ 
segyhdrs < $outputZ

#clean Up
mv *.H* *.out *.param *.in ela2d_dir 
rm *.tmp *.bin *.txt
rm binary header
rm *.dat
echo "Ela2D Finished"

#display
suxwigb < $outputX title="X Component" perc=99 style=vsp key=gelev label2="depth" label1="twt (s)" &
suxwigb < $outputZ title="Z Component" perc=99 style=vsp key=gelev label2="depth" label1="twt (s)" &
