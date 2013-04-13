#!/bin/bash
## /**
## * @file Suttcorr.sh
## * @brief Geometric and transit time correction for VSP Data - Checkshot Computation (Simplified to vertical well with cosine correction)
## * @author fahdi@gm2001.net
## * @date March 2013
## * @param input SU file to correction
## * @param ascii ASCII TABLE
## */

###start of input
input=../data/Z.su
output=../data/Z_picked_srd.su
out_table=../data/checkshot_report.txt
out_tt_curve=../data/tt_picks_srd.txt #just to make easier when plotting :)

srd=0 #srd elevation
log_zero=6.0 #start of logging measurement

vmedium=1570 #replacement velocity from source position to SRD 
vhyd=1524 #replacement velocity from hydrophone position to source position

#wellhead location
wellx=xxx
welly=xxx

#source information
src_offset=95.0 #source offset from wellhead
src_azi=288 #source azimuth from north
src_z_log_zero=6.5  #source position/depth from logging zero

#source_sensor information
sensor_offset=95 #source_sensor offset from wellhead
sensor_azi=288 #source_sensor azimuth from north
sensor_z_log_zero=6.5 #source_sensor position/depth from logging zero

###end of input

tmin=0.0
tmax=5.0

#receiver position X &Y taken from SU file header, 
#gelev assumed to be receiver z from log zero, please check manually

#get all headers, write into table
sugethw < $input key=tracr,scalco,scalel,sx,sy,sdepth,gx,gy,gelev,lagb \
	| sed -e 's/tracr=//' -e 's/scalco=//' -e 's/scalel=//' -e 's/sx=//' -e 's/sy=//' -e 's/sdepth=//' -e 's/gx=//' -e 's/gy=//' -e 's/gelev=//' -e 's/lagb=//' \
	| sed '/^$/d' > geom_table.tmp

awk -v src_srd=$src_srd -v log_zero=$log_zero -v wellx=$wellx -v welly=$welly -v pi=3.141596 \
	-v src_z_log_zero=$src_z_log_zero -v sensor_z_log_zero=$sensor_z_log_zero -v vmedium=$vmedium -v vhyd=$vhyd \
	-f geomcos.awk geom_table.tmp > $out_table

nrec=($(wc -l geom_table.tmp | awk '{print $1}'))

#dirty plotting, maybe switch to gmt 
#depth set to minus, in order to make depth increase downward
#plot td
awk '{print $13,$8*-1}' $out_table | xgraph -bg white -m -t "T-D Curve" -x "Time (s)" -y "TVDSS (Length)" -ng &
#plot vint
awk '{print $16,$8*-1}' $out_table | xgraph -bg white -m -t "VSP Interval Velocity" -x "Velocity (Length/s)" -y "TVDSS (Length)" -ng&

#set static shift to SRD value, and shift the waveform
awk '{print $17}' $out_table | sed '/^$/d' | awk '{print $1*1000}' > dlrt.tmp #stupid code :)
a2b < dlrt.tmp n1=$nrec > dlrt.bin
sushw < $input infile=dlrt.bin key=delrt \
	| sushift tmin=$tmin tmax=$tmax | suwind tmin=$tmin tmax=$tmax> $input.tmp1

#reinject calculated geometry headers into SU file
#currently supporting re-injecting  sdepth, gelev, lagb refer to srd
awk '{print $4*10,$8*10,$13*1000}' $out_table | sed 's/[^0-9." "]*//g' > srd_geom.tmp #stupid code :)
a2b < srd_geom.tmp n1=$nrec > srd_geom.bin
sushw < $input.tmp1 infile=srd_geom.bin key=sdepth,gelev,lagb > $output

#display
#get curve 
awk '{print $11,$8}' $out_table > tt_obs.txt
awk '{print $13,$8}' $out_table > tt_srd.txt
awk '{print $13,$8}' $out_table > $out_tt_curve
suxwigb < $input  key=gelev style=vsp perc=99 curve=tt_obs.txt npair=$nrec,1 curvecolor=red title="Before Geometric Correction"&
suxwigb < $output key=gelev style=vsp perc=99 curve=tt_srd.txt npair=$nrec,1 curvecolor=red title="After Geometric Correction"&

#clean up $out_table
#stupid code :)
sed -i -e '1iNO 		SX 			SY 		   SZ 		RX 			RY 		  RZ_MD 	 RZ_TVDSS 	  ROFF  SROFF   TT_OBS       TT_VERT     TT_SRD       DZ           DT        VINT	    SRDSHIFT' $out_table

#clean up	
rm *.bin
rm *.tmp
rm ../data/*.tmp*
