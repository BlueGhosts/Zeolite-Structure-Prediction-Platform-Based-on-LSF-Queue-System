#!/bin/bash

# 2019-07-09 v1.0
# by wangjiaze



function CreateDic(){
    
    filepath=$1
    if [ ! -d $filepath/FraGen_cif ]; then
        mkdir $filepath/FraGen_cif
    fi
        
    if [ ! -d $filepath/AddOxygen_cif ]; then
    	mkdir $filepath/AddOxygen_cif
    fi
    
    if [ ! -d $filepath/Gulp ]; then
    	mkdir $filepath/Gulp
    fi
    
    if [ ! -d $filepath/Gulp_cif ]; then
    	mkdir $filepath/Gulp_cif
    fi
    
    if [ ! -d $filepath/fin ]; then
        mkdir $filepath/fin
    fi
    
    if [ ! -d $filepath/LID_cif ]; then
        mkdir $filepath/LID_cif
    fi
    
    rm -rf $filepath/FraGen_cif/*
    rm -rf $filepath/AddOxygen_cif/*
    rm -rf $filepath/Gulp/*
    rm -rf $filepath/Gulp_cif/*
    rm -rf $filepath/fin/*
    rm -rf $filepath/LID_cif/*
    }


function Out2Cif(){
    filepath=$1
    filename=$2
    $python3 $FraGenCodes/Out2Cif/Out2Cif.py $filepath/$filename.txt $filepath/$filename.out $filepath/FraGen_cif
    #echo $filepath/FraGen_cif
    }
    
    
function CreateGULPDic(){
    filepath=$1
    maxGULPnumber=$2
    
    for (( i=1;i<=$maxGULPnumber;i++ ));
    do
	    mkdir $filepath/Gulp/$i
	    mkdir $filepath/Gulp/$i/gin
	    mkdir $filepath/Gulp/$i/gout
	    mkdir $filepath/Gulp/$i/cif
	    mkdir $filepath/Gulp/$i/cif_before
    done
    cp $FraGen/wyckfull.dat $filepath
    }
    

function SubOptimization(){
    filepath=$1
    FraGenCifDic=$2
    maxGULPnumber=$3
    minBondDistance=$4
    maxBondDistance=$5
    allJobNumber=$6
    # echo $filepath
    # echo $FraGenCifDic
    # echo $maxGULPnumber
    # echo $minBondDistance
    # echo $maxBondDistance
    # echo $allJobNumber
    # echo $FraGenCifDic
    
    FraGencifs=`ls $FraGenCifDic`
    for FraGencif in $FraGencifs
    do  
        nowJobNumber=`bjobs | wc -l`
        echo "nowJobNumber=$nowJobNumber"
        echo "allJobNumber=$allJobNumber"
        while [[ $nowJobNumber -gt $allJobNumber ]]
        do
            sleep 30s
            nowJobNumber=`bjobs | wc -l`
            echo "nowJobNumber=$nowJobNumber"
            echo "allJobNumber=$allJobNumber"
        done
            
        cifpath=$FraGenCifDic/$FraGencif
        
        filename=${FraGencif##*/}
	    filename=${filename%.*}
	    
        #echo $cifpath
        job_id_Optimization=$(bsub -P GetZeolite -J "Optimization_$filename" -o "$FraGen/GetZeolite_lsf/%J_Optimization_$filename.log" bash $FraGenCodes/Optimization/Optimization.sh $cifpath $filepath $maxGULPnumber $minBondDistance $maxBondDistance | grep Job |awk '{print $2}' |tr -d '<>') 
        echo $job_id_Optimization
        i=`expr $i + 1`
    done
    }



echo "Si2SiO2Task.sh"

filepath=$1
filename=$2
minBondDistance=$3
maxBondDistance=$4
maxGULPnumber=$5
allJobNumber=$6


echo ''
echo 'Begin CreateDic'
CreateDic $filepath 
echo 'End CreateDic'
echo ''

echo ''
echo 'Begin Out2Cif'
Out2Cif $filepath $filename
echo 'End Out2Cif'
echo ''

echo ''
echo 'Begin CreateGULPDic'
CreateGULPDic $filepath $maxGULPnumber
echo 'End CreateGULPDic'
echo ''

echo ''
echo 'Begin SubOptimization'
#SubOptimization $filepath $filepath/FraGen_cif $maxGULPnumber $minBondDistance $maxBondDistance $allJobNumber
jobids=`SubOptimization $filepath $filepath/FraGen_cif $maxGULPnumber $minBondDistance $maxBondDistance $allJobNumber`
#echo $jobids
echo 'End SubOptimization'
echo ''
