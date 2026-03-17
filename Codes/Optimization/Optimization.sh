#!/bin/bash 

# 2019-08-20 v1.0
# by wangjiaze

function JudgeGoutResult(){
    filepath=$1
    #$r1=`cat $filepath | grep "Optimisation achieved"`
    #$r2=`cat $filepath | grep "Unit cell is not charge neutral"`
    
    r1=`grep "Optimisation achieved" $filepath`
    r2=`grep "Unit cell is not charge neutral" $filepath`
    
    #echo "r1=$r1 \n"
    #echo "r2=$r2 \n"
    if [[ -n  $r1 ]];then
        result="Optimisation achieved"
    elif [[ -n  $r2  ]];then
        result="ChargeNeutral"
    else
        result='Failed'
    fi
    echo $result

    #return $result;
    } 


function AddOxygen(){
    filepath=$1
    cifpath=$2
    minBondDistance=$3
    maxBondDistance=$4
    
    $python3 $FraGenCodes/AddOxygen/AddOxygen.py $cifpath $filepath/AddOxygen_cif $minBondDistance $maxBondDistance
    }
    
    
function JudgeLID(){
    filepath=$1
    cifpath=$2
    result=$3
    
    filename=${cifpath##*/}
    filename=${filename%.*}
    echo $filename
    echo $result
    
    if [[ $result == 'Optimisation achieved' ]]; then
        $FraGenCodes/cif2fin/cif2fin.out "$filepath/Gulp_cif/$filename.cif" "$filepath/fin/$filename.fin"
    
        $FraGenCodes/FraGen/FraGen.out "fin/$filename.fin"
    
        LIDresult=`$python3 $FraGenCodes/LID_Judge/LID_Judge.py "fin/$filename.fout" "$filepath/Gulp_cif/$filename.cif"`
        echo '##############'
        echo $LIDresult
        if [[ $LIDresult == 'True' ]]; then
            cp $cifpath $filepath/LID_cif
            cp $cifpath $FraGen/wyc/AllLID_cif
        fi
    fi
    }
    
    
function RunGULP(){
    filepath=$1
    cifpath=$2
    maxGULPnumber=$3
    
    
    filename=${cifpath##*/}
    filename=${filename%.*}
    cifname=$filename.cif
    echo $cifpath
    echo $filename
    
    cp $cifpath $filepath/Gulp/1/cif_before/$cifname
    
    for(( i=1;i<=$maxGULPnumber;i++ ))
    do        
        $python3 $FraGenCodes/cif2gin/cif2gin.py $filepath/Gulp/$i/cif_before/$cifname $filepath/Gulp/$i/gin/$filename.gin Gulp/$i/cif/$cifname
        $FraGenCodes/gulp-5.1/gulp<$filepath/Gulp/$i/gin/$filename.gin>$filepath/Gulp/$i/gout/$filename.gout
        result=`JudgeGoutResult "$filepath/Gulp/$i/gout/$filename.gout"`
        echo $result
        
        if [[ $result == 'Optimisation achieved' ]]; then
	        cp $filepath/Gulp/$i/cif/$filename.cif $filepath/Gulp_cif
	        cp $filepath/Gulp/$i/cif/$filename.cif $FraGen/wyc/AllGULP_cif
			cp $filepath/Gulp/$i/gin/$filename.gin $FraGen/wyc/AllGULP_gin
			cp $filepath/Gulp/$i/gout/$filename.gout $FraGen/wyc/AllGULP_gout
	        break
	    
        elif [[ $result == "ChargeNeutral" ]];then
            echo "ChargeNeutral"
            break
        
        elif [[ $result == 'Failed' ]] ;then
            i_1=`expr $i + 1`
            #echo $i_1
            #echo $filepath/Gulp/$i_1/cif_before/$filename.cif
            if [ $i_1 -gt $maxGULPnumber ];then
                break
            fi
       	    $python3 $FraGenCodes/ExpandCell/ExpandCell.py $filepath/AddOxygen_cif/$cifname $filepath/Gulp/$i_1/cif_before $i
        fi
    done     
        
    echo $result
    echo ''
    echo 'Begin JudgeLID'
    LIDresult=`JudgeLID $filepath $cifpath "$result"`
    echo 'End JudgeLID'
    echo ''
    
    }


echo "Optimization.sh"

cifpath=$1
filepath=$2
maxGULPnumber=$3    
minBondDistance=$4
maxBondDistance=$5

#minBondDistance=0
#maxBondDistance=3.7001
#maxGULPnumber=3

cifname=${cifpath##*/}
cd $filepath

echo ''
echo 'Begin AddOxygen'
jobids=`AddOxygen $filepath $cifpath $minBondDistance $maxBondDistance`
echo 'End AddOxygen'
echo ''

echo ''
echo 'Begin GULP'
RunGULP $filepath $filepath/AddOxygen_cif/$cifname $maxGULPnumber
echo 'End GULP'
echo ''

