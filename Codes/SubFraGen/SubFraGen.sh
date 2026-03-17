#!/bin/bash 
inpfile=$1
maxradio=$2
wyckofffile=$3


until [ $inpfile == 'False' -o ${#inpfile} -gt 256 ];
do
    echo $inpfile
    runpath=${inpfile%/*}
    inpfilename=${inpfile##*/}
    cd $runpath
    #echo $runpath
    cp $wyckofffile $runpath
    
    #echo $runpath
    #echo $inpfilename
    #cho $maxradio
    
    $FraGenCodes/FraGen/FraGen.out $inpfilename
    inpfile=`$python3 $FraGenCodes/EvaluateAbility/EvaluateAbility.py $runpath 'ratio.txt' $maxradio`
    #echo '######'
    echo $inpfile
    #echo '######'
done