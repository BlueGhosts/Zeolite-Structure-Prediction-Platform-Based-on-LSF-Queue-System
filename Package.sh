#!bin/bash


if [[ -a GULP_cif.tar ]];then
    rm -f GULP_cif.tar;
fi;

if [[ -a LID_cif.tar ]];then
    rm -f LID_cif.tar;
fi;

if [[ -a zeolite.tar.gz ]];then
    rm -f zeolite.tar.gz;
fi;



export FraGen=`pwd`
filepath=${FraGen##*/}
filepath=${filepath%.*}




#bsub<Package.lsf
bsub -P continueFraGenJob -q normal -a intelmpi -app normal -n 1 -J "Package_$filepath" -o "$FraGen/%J_Package_$filepath.log" bash Package.lsf

