#!/bin/bash

## /**
## * @brief Create Simple Flat Model
## * @brief Clean.sh can be used to clean up 
## * @brief Model can be displayed by typing ./DisplayModel.sh
## * @file CreateFlatModel.sh
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## * @param nx Number of model sample in X direction
## * @param dx Model sampling rate in X direction
## * @param nz Number of model sample in Z direction
## * @param dz Model sampling rate in Z direction
## * @param whx Wellhead location X
## * @param why Wellhead location Y
## * @param rcv_x Receiver location X
## * @param rcv_spacing Receiver Spacing
## * @param rcv_z0 Depth of first receiver
## * @param nrcv Number of Receiver
## * @param offset Source Offset from wellhead
## * @param src_z Depth of source
## * @param ninf Number of interface in unif2 model
## * @param Vp P velocity for each layers
## * @param Vs S velocity for each layers
## * @param density Density for each layers
## */

#input
#define model identify, 
#model will be output to $model_dir with name $model_name
#this is actually stupid :) because ela2d required pre-defined naming convention
model_name=model01
model="../model/${model_name}"

#define model dimension
nx=100
dx=10
nz=300
dz=10

#set parameter
#Define Shooting Geometry
#wellhead location which will be receiver location
whx=400
why=0

#receiver
rcv_x=$((whx))
rcv_spacing=15
rcv_z0=200 
nrcv=120

#source, set by offset from wellhead
offset=80
src_z=5

#We will create model where interface defined by $input_model, contain 8 layer
#change the velocity for interface here
#To simply the exercise set Vp/Vs=2, and density is gardner
#output name is designed for Ela2d (vel_P.dat, vel_S.dat, density.dat)
#see SU documentation for unif2  to modify

input_model=model.unif2
ninf=8 #number of interface, check with $input_model
Vp=1524,1800,2100,2500,2700,3000,3500,4000 #m/s
Vs=890,1050,1235,1470,1588,1765,2058,2350 #m/s
density=1930,2020,2100,2190,2230,2290,2380,2460 #(g/m)?

### input stop here

#populate source
src_x=$((whx+offset))
printf "\t $src_z \t $src_x" > ${model}_source_list.txt

#Create Elastic Flat Model
#CreateVP
unif2 <  model.unif2  nx=$nx nz=$nz dx=$dx ninf=$ninf \
v00=$Vp dz=$dz > ${model}_vel_P.dat

#CreateVs (Vp/Vs~1.7)
unif2 <  model.unif2  nx=$nx nz=$nz dx=$dx ninf=$ninf \
v00=$Vs dz=$dz > ${model}_vel_S.dat

#CreateDensity
unif2 <  model.unif2  nx=$nx nz=$nz dx=$dx ninf=$ninf \
v00=$density dz=$dz > ${model}_density.dat

#create receiver array
awk -v rcv_z0=${rcv_z0} -v rcv_spacing=${rcv_spacing} -v rcv_x=${rcv_x} -v nrcv=${nrcv} 'BEGIN {
	rcv_z=rcv_z0
	i=1
     while (i <= nrcv) {
         printf "\t %.2f \t %.2f \n",rcv_z,rcv_x 
		 rcv_z=rcv_z+rcv_spacing
         i++
     } 
}' > ${model}_receiver_list.txt

#display, plot receiver as blue curve
ximage < ${model}_vel_P.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=hsv2 npair=$nrcv,1 \
	curve=${model}_receiver_list.txt,${model}_source_list.txt title="${model} Vp" &
ximage < ${model}_vel_S.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=hsv2 npair=$nrcv,1\
	curve=${model}_receiver_list.txt,${model}_source_list.txt title="${model} Vs" &
ximage < ${model}_density.dat n1=$nz d1=$dz n2=$nx d2=$dx legend=1 cmap=hsv2 npair=$nrcv,1\
	curve=${model}_receiver_list.txt,${model}_source_list.txt title="${model} Density" &
