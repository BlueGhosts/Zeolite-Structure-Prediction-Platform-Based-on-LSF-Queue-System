#!/bin/bash
export FraGen=`pwd`
export FraGenCodes=$FraGen/Codes
#echo $FraGen

echo "Please input the max number of wyc combination in each wyc file.(wycnum)"
read wycnum
echo "Please input the cycle num for each wyc combination.(cyclenum)"
read cyclenum
echo "Please input the max radio for each wyc created Structure.(maxradio)"
read maxradio
export wycnum
export cyclenum
export maxradio

#export wycnum=30
#export cyclenum=2000

cd $FraGen

if [ ! -d $FraGen/FraGen_lsf ]; then
	mkdir $FraGen/FraGen_lsf 
fi

if [ ! -d $FraGen/wyc ]; then
	mkdir $FraGen/wyc
fi

if [ ! -f $FraGen/wyc/wyckfull.dat ]; then
	cp $FraGen/wyckfull.dat $FraGen/wyc
fi

rm -rf lsf/*
rm -f run.log

echo '1.sh'
echo "wycnum : $wycnum"
echo "cyclenum : $cyclenum"
echo "maxradio : $maxradio"
#bash $FraGenCodes/workflow/workflow.sh
bsub<FraGen.lsf

