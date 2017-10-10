#!/bin/bash


declare -A months=( ["Jan"]="01" ["Feb"]="02" ["Mar"]="03" ["Apr"]="04" ["Mei"]="05" ["Jun"]="06" ["Jul"]="07" ["Agu"]="08" ["Sep"]="09" ["Okt"]="10" ["Nov"]="11" ["Des"]="12" )

while true ;
do	
	DATA="data"
	ymd=`date --utc -d "8 min ago"` #Jarak lag satelit
	#ymd=`date --utc`
	m=${ymd:4:3}
	year=${ymd:24:4}
	month=${months["${m}"]}
	day=${ymd:9:1}
	if [ ${day} -lt 10 ]
	then
		day=0${day}
	fi

	hour=${ymd:11:2}
	min=${ymd:14:1}0
	vary=`ls ../data | grep ${year}`
	
	if [ -z "$vary" ]
	then
      mkdir ../data/${vary}
	else
      echo "${vary} is NOT empty"
	fi

	varm=`ls ../data/${year} | grep ${month}`

	if [ -z "$varm" ]
	then
      mkdir ../data/${year}/${varm}
	else
      echo "${varm} is NOT empty"
	fi


	#wget ftp://user_himawari16_netcdf:cirrus@202.90.199.115/Indonesia/2017/10/02/H08_B16_Indonesia_201710020720.nc
	wget ftp://user_himawari16_netcdf:cirrus@202.90.199.115/Indonesia/${year}/${month}/${day}/H08_B16_Indonesia_${year}${month}${day}${hour}${min}.nc
	mv H08_B16_Indonesia_${year}${month}${day}${hour}${min}.nc ../data/${year}/${month}

	cp ../data/${year}/${month}/H08_B16_Indonesia_${year}${month}${day}${hour}${min}.nc ../data/recent/
	#rm H08_B16_Indonesia_${year}${month}${day}${hour}${min}.nc

	sleep 600
done