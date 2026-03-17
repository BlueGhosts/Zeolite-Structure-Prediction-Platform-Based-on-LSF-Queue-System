#!/bin/bash 

echo "2.sh"

export FraGen=`pwd`
export FraGenCodes=$FraGen/Codes


FraGen=$FraGen
cd $FraGen

if [ ! -d $FraGen/CsqCheck_lsf ]; then
	mkdir $FraGen/CsqCheck_lsf
fi


filename=${FraGen##*/}
filename=${filename%.*}


# bsub<CsqCheck.lsf
bsub -P CsqCheck -q normal -a intelmpi -app normal -n 1 -o "CsqCheck_lsf/%J_CsqCheck_lsf_$filename.log"  -J "CsqCheck_$filename" bash $FraGenCodes/CsqCheck_workflow/CsqCheck_workflow.sh
