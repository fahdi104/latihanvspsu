#!/bin/bash
## @file CreateFlatModel.sh
## @brief Create Simple Flat Model
## @author fahdi@gm2001.net
## @date February 2012

#define model dimension
nx=100
dx=10
nz=300
dz=10

#Define Shooting Geometry
#wellhead
whx=400
why=0

#receiver
#Offset from wellehad
rcv_x=$((whx))
rcv_spacing=15
rcv_z0=800 
nrcv=110

#source
offset=100
src_x=$((whx+offset))
src_z=50
printf "\t $src_z \t $src_x" > source_list.txt

#Create Elastic Flat Model
#CreateVP
unif2 <  model.unif2  nx=$nx nz=$nz dx=$dx ninf=8 \
v00=1524,1800,2100,2500,2700,3000,3500,4000 dz=10 > vel_P.dat

#CreateVs (Vp/Vs~1.7)
unif2 <  model.unif2  nx=$nx nz=$nz dx=$dx ninf=8 \
v00=890,1050,1235,1470,1588,1765,2058,2350 dz=10 > vel_S.dat

#CreateDensity
unif2 <  model.unif2  nx=$nx nz=$nz dx=$dx ninf=8 \
v00=1930,2020,2100,2190,2230,2290,2380,2460 dz=10 > density.dat

#create receiver array
awk -v rcv_z0=${rcv_z0} -v rcv_spacing=${rcv_spacing} -v rcv_x=${rcv_x} -v nrcv=${nrcv} 'BEGIN {
	rcv_z=rcv_z0
	i=1
     while (i <= nrcv) {
         printf "\t %.2f \t %.2f \n",rcv_z,rcv_x 
		 rcv_z=rcv_z+rcv_spacing
         i++
     } 
}' > receiver_list.txt

#display
ximage < vel_P.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=rgb1 npair=$nrcv,1 curve=receiver_list.txt,source_list.txt title="Vp"&
ximage < vel_S.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=rgb1 npair=$nrcv,1 curve=receiver_list.txt,source_list.txt title="Vs"&
ximage < density.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=rgb1 npair=$nrcv,1 curve=receiver_list.txt,source_list.txt title="Density"&


#preparation for 2Ela2d
#copy velocity model
#@todo this should be gone
cp *.dat ../2Ela2d
#copy receiver list
#flip receiver list
awk '{print "\t", $2, "\t", $1}' receiver_list.txt > ../2Ela2d/receiver_list.txt
awk '{print "\t", $2, "\t", $1}' source_list.txt > ../2Ela2d/source_list.txt


