#!/bin/bash 

function getdir(){    
	for element in `ls $1`    
	do          
		dir_or_file=$1"/"$element        
		if [ -d $dir_or_file ];
		then             
			getdir $dir_or_file        
		else            
			echo $dir_or_file        
		fi      
	done
	}
	
	
function GetCsqfiles(){
    wycpath=$1
    extname=$2
    files=`getdir $wycpath`
    
    for file in $files
    do
	    ext=${file##*.}
	    if [ $ext == $extname ];then
		    echo $file
	    fi
    done
    }


function CreateCsqPara(){
    wycpath=$1
    csqfiles=$2
    
    parafile=$wycpath/para_csqcheck.pche
    echo "REQU:" 		             > $parafile
    echo "    1: 4-4" 		        >> $parafile
    echo "    12: 120-10000"        >> $parafile
    echo "CSQF:"				    >> $parafile
    for csqfile in $csqfiles
    do
        echo "$csqfile N"               >> $parafile
    done
    #echo "    $path/csq.list"      >> $parafile
    echo "REFE:"			        >> $parafile
    echo "    iza.csq"			    >> $parafile
    echo "OUTF:"				    >> $parafile
    echo "    $wycpath/csq.tem"        >> $parafile
    echo "OUTC:"				    >> $parafile
    echo "    $FraGen/csq/csq.csqw"	>> $parafile
    
    echo $parafile
    }


function SeleteCsq(){
    temfile=$1
    csqfiles=$2
    
    for csqfile in $csqfiles
    do
        #echo $csqfile
        filename=${csqfile##*/}
	    filename=${filename%.*}
        filepath=${csqfile%/*}
        parafile=$filepath/$filename.psel
        echo "IN "$temfile     			     > $parafile
		echo "SIGN "$filename 			    >> $parafile
		echo "OUT "$filepath/$filename.txt  >> $parafile
        python $FraGenCodes/CsqCheck/Seletcsq.py $parafile
        
        echo $csqfile
    done
    }


function Si2SiO2Task(){
    csqfiles=$1
    minBondDistance=$2
    maxBondDistance=$3
    GULP_num=$4
    allJobNumber=$5
    echo $allJobNumber
    
    for csqfile in $csqfiles
    do
        filename=${csqfile##*/}
	    filename=${filename%.*}
        filepath=${csqfile%/*}
        
        job_id_Si2SiO2Task=$(bsub -P Csqcheck -J "Si2SiO2Task" -o "$FraGen/GetZeolite_lsf/%J_Si2SiO2Task_$filename.log" bash $FraGenCodes/Si2SiO2Task/Si2SiO2Task.sh  $filepath $filename $minBondDistance $maxBondDistance $GULP_num $allJobNumber | grep Job |awk '{print $2}' |tr -d '<>') 
        echo $job_id_Si2SiO2Task
    done
    }


minBondDistance=0
maxBondDistance=3.7001
GULP_num=5
allJobNumber=500
#allJobNumber=750

echo 'GetZeolite_workflow.sh'


wycpath=$FraGen/wyc
rm -f GetZeolite.log
if [ ! -d $FraGen/csq ];then 
    mkdir $FraGen/csq
fi

if [ ! -d $wycpath/AllGULP_cif ]; then
    mkdir $wycpath/AllGULP_cif
fi
rm -rf $wycpath/AllGULP_cif/*

if [ ! -d $wycpath/AllLID_cif ]; then
    mkdir $wycpath/AllLID_cif
fi
rm -rf $wycpath/AllLID_cif/*


echo 'CreateCsqPara'


csqfiles=`GetCsqfiles $wycpath 'csqo'`
parafile=`CreateCsqPara $wycpath "$csqfiles"`
echo $parafile


echo ''
echo 'Begin CsqCheck'
CsqCheck=`$python3 $FraGenCodes/CsqCheck/CsqCheck.py $parafile`
echo 'End CsqCheck'
echo ''


echo ''
echo 'Begin SeleteCsq'
csqfiles=`SeleteCsq $wycpath/csq.tem "$csqfiles"`
echo 'End SeleteCsq'
echo ''

echo $allJobNumber

echo $filepaths
echo ''
echo 'Begin Si2SiO2Task'
jobids=`Si2SiO2Task "$csqfiles" $minBondDistance $maxBondDistance $GULP_num $allJobNumber`
#Si2SiO2Task "$csqfiles" $minBondDistance $maxBondDistance $GULP_num $allJobNumber
echo 'End Si2SiO2Task'
echo ''
