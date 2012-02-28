#!/bin/bash
## @file DisplaySynthetic.sh
## @brief Display created sythetic model
## @author fahdi@gm2001.net
## @date February 2012

##define model dimension
nx=100
dx=10
nz=300
dz=10

outputX=HMX.su
outputZ=Z.su

suxwigb < $outputX title="X Component" perc=97 style=vsp key=gelev &
suxwigb < $outputZ title="Z Component" perc=97 style=vsp key=gelev &


