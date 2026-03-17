#!/bin/sh

path=$1
parafiles=$path/*.psep

for parafile in $parafiles
	do
		bsub -P FraGen -J "SeparateWyc" -o  "$FraGen/lsf/%J_SeparateWyc.log"  $python3 $FraGenCodes/Separate/Separate1_1.py $parafile
	done