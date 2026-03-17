#!/bin/bash 

echo "2.sh"

export FraGen=`pwd`
export FraGenCodes=$FraGen/Codes


FraGen=$FraGen
cd $FraGen


wyckofffile=$FraGen/wyckfull.dat

echo "break path:"
read breakPath
inpfile=`ls $breakPath/*.inp`
#echo "Please input the max radio for each wyc created Structure.(maxradio)"
#read maxradio
maxradio=0.01

export inpfile
export maxradio
export wyckofffile

inpfilename=${inpfile##*/}
inpfilename=${inpfilename%.*}
export inpfilename
echo $inpfilename

bsub -P continueFraGenJob -q normal -n 1 -a intelmpi -app normal -J "continueFraGenJob_$inpfilename" -o "$FraGen/FraGen_lsf/%J_continueFraGenJob_$inpfilename.log" bash $FraGenCodes/SubFraGen/SubFraGen.sh $inpfile $maxradio $wyckofffile
#BSUB -o FraGen_lsf/%J_continueFraGenJob_$inpfilename.log
#BSUB -q normal
#BSUB -a intelmpi
#BSUB -app normal

#BSUB -J "continueFraGenJob_$inpfilename"

#BSUB -n 1

#bsub<continueFraGenJob.lsf 