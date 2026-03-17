#!/bin/bash
    path=$2
    temp=$path/$1/cycle/*.s
    for j in $temp 
     do
      if [ -f $j ];then
         name=$(basename ${j} .s)
         echo "$path/$1/cycle/${name}.s" > $path/$1/cycle/${name}.p
         echo "$path/$1/cif" >> $path/$1/cycle/${name}.p
         echo "0" >> $path/$1/cycle/${name}.p
         echo "3.7001" >> $path/$1/cycle/${name}.p
         echo "" >> $path/$1/cycle/${name}.p
      fi
    done


