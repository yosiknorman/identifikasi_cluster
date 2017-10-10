#!/bin/bash

jam=$(TZ="UTC" date +%R)
menit=${jam:3:2}
if (( ${menit:1:1} != 0 )) 
  then
  	let "menit=$menit-${menit:0:1}0"
  	let "menit=10-$menit"
  	let "menit=$menit*60"
  
  	sleep $menit
  	echo $menit
  	./download_sat.sh
else
	./download_sat.sh
fi

./nowcaster.R
./pushgit.sh

