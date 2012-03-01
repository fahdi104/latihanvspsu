#!/bin/bash
## /**
## * @file DisplaySynthetic.sh
## * @brief Display created sythetic model
## * @author fahdi@gm2001.net
## * @date February 2012
## */

#input
outputX=HMX.su #specify filename for horizontal component
outputZ=Z.su #specify filename for vertical component

suxwigb < $outputX title="X Component" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)"&
suxwigb < $outputZ title="Z Component" perc=97 style=vsp key=gelev label2="depth" label1="twt (s)"&


