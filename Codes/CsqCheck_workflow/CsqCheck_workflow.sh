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
    echo "REQU:" 		              > $parafile
    echo "    1: 4-4" 		          >> $parafile
    echo "    12: 120-10000"          >> $parafile
    echo "    STD2:0-2.404746"        >> $parafile
    echo "    STD3:0-4.647581"        >> $parafile
    echo "    STD4:0-5.752803"        >> $parafile
    echo "    STD5:0-7.293891"        >> $parafile
    echo "    STD6:0-8.810910"        >> $parafile
    echo "    STD7:0-12.810842"        >> $parafile
    echo "    STD8:0-14.586945"        >> $parafile
    echo "    STD9:0-15.389676"        >> $parafile
    echo "    STD10:0-17.754867"        >> $parafile
    echo "    STD11:0-18.645567"        >> $parafile
    echo "    STD12:0-28.181138"        >> $parafile
    echo "CSQF:"				      >> $parafile
    for csqfile in $csqfiles
    do
        echo "$csqfile N"               >> $parafile
    done
    #echo "    $path/csq.list"         >> $parafile
    echo "REFE:"			           >> $parafile
    echo "    iza.csq"			       >> $parafile
    echo "OUTF:"				       >> $parafile
    echo "    $wycpath/csq.tem"        >> $parafile
    echo "OUTC:"				       >> $parafile
    echo "    $FraGen/csq/csq.csqw"	   >> $parafile
    
    echo $parafile
    }


echo 'CsqCheck_workflow.sh'


wycpath=$FraGen/wyc
rm -f CsqCheck.log

echo 'CreateCsqPara'


csqfiles=`GetCsqfiles $wycpath 'csqw'`
parafile=`CreateCsqPara $wycpath "$csqfiles"`
echo $parafile


echo ''
echo 'Begin CsqCheck'
CsqCheck=`$python3 $FraGenCodes/CsqCheck/CsqCheck.py $parafile`
echo 'End CsqCheck'
echo ''

