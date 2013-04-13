#!/bin/bash
## /**
## * @file DisplaySynthetic.sh
## * @brief Display created sythetic model
## * @author fahdi@gm2001.net
## * @date April 2013 [update]
## */

#input
outputX=../data/HMX.su #specify filename for horizontal component
outputZ=../data/Z.su #specify filename for vertical component

suxwigb < $outputX title="X Component" perc=99 style=vsp key=gelev label2="depth" label1="twt (s)"&
suxwigb < $outputZ title="Z Component" perc=99 style=vsp key=gelev label2="depth" label1="twt (s)"&


