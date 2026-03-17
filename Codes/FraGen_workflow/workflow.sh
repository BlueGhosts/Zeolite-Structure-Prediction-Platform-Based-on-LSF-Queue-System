#!/bin/bash 

echo 'workflow.sh'
echo $wycnum
echo $cyclenum
echo $maxradio

function CreateInpList(){
    wycpath=$1  
    inpfiles=`ls $wycpath/*.inp`
    echo $inpfiles
    }


function CreateSepPara(){
    inpfiles=$1
    wycpath=$2
    separatenum=$3
    eachcyclenum=$4
    
    #echo $wycpath
    declare sepParafiles
    i=0
    for inpfile in $inpfiles
    do
		inpfilename=${inpfile##*/}
		inpfilename=${inpfilename%%.*}
		#echo $inpfilename
		wycline=`grep '^read' $inpfile`
		#echo $wycline
		wycfile=${wycline#* }
		#echo $wycfile
		
		if [ ! -d $wycpath/$inpfilename ];then 
        mkdir -m 777 $wycpath/$inpfilename
        fi
        rm -rf $wycpath/$inpfilename/*
		
		paraname=$wycpath/para_$inpfilename.psep
		#echo $paraname
		#echo $wycpath
		echo $paraname
		echo "INPFILE_PATH $wycpath/$wycfile"        > $paraname
		echo "OUTFILE_PATH $wycpath/$inpfilename"   >> $paraname
		echo "LABEL $inpfilename"		         >> $paraname
		echo "REFERENCEINP_PATH $inpfile"        >> $paraname
		echo "SEPARATE_NUM $separatenum"         >> $paraname
		echo "EACHCYCLE_NUM $eachcyclenum"       >> $paraname
		
		sepParafiles[$i]=$paraname
		i=`expr $i+1`
	done
    }
    
    
function SeparateWyc(){
    sepParafiles=$1
    for sepParafile in $sepParafiles
    do
        #echo $sepParafile
        newinpfiles=`$python3 $FraGenCodes/Separate/Separate.py $sepParafile`
        echo $newinpfiles
    done
    }


function RunFraGen(){
    inpfiles=$1
    maxradio=$2
    wyckofffile=$3
    #echo $maxradio
    for inpfile in $inpfiles
    do  
        echo $inpfile
        filename=${inpfile##*/}
        filename=${filename%.*}
        
        job_id_SubFraGen=$(bsub -P FraGen -J "SubFraGen_$filename" -o "$FraGen/FraGen_lsf/%J_SubFraGen_$filename.log" bash $FraGenCodes/SubFraGen/SubFraGen.sh $inpfile $maxradio $wyckofffile | grep Job |awk '{print $2}' |tr -d '<>')  
    done
    }

#wycnum=1
#cyclenum=20
#maxradio=0.2

wycnum=$wycnum
cyclenum=$cyclenum

wycpath=$FraGen/wyc
inpfiles=`CreateInpList $wycpath`

#echo $inpfiles
sepParafiles=`CreateSepPara "$inpfiles" $wycpath $wycnum $cyclenum`
#echo $sepParafiles
newinpfiles=`SeparateWyc "$sepParafiles"`
#echo $newinpfiles
a=`RunFraGen "$newinpfiles" $maxradio $FraGen/wyckfull.dat`

