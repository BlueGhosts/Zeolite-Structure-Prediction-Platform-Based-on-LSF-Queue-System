#!/bin/bash 

echo "2.sh"

export FraGen=`pwd`
export FraGenCodes=$FraGen/Codes

FraGen=$FraGen
cd $FraGen

if [ ! -d $FraGen/GetZeolite_lsf ]; then
	mkdir $FraGen/GetZeolite_lsf
fi

rm -rf GetZeolite_lsf/*
bsub<GetZeolite.lsf