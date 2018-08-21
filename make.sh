#!/bin/bash

BASE=/tmp

prepare () {
	# folders
	[[ -d ${BASE}/src ]] && rm -rf ${BASE}/src
	[[ -d ${BASE}/dst ]] && rm -rf ${BASE}/dst
	
	mkdir -p ${BASE}/{src/etc,dst/etc}/config
	
	for i in {1,2,3}
	do
		date > ${BASE}/src/etc/config/$i.cfg
	done

	for i in {3,4,5}
	do
		date > ${BASE}/dst/etc/config/$i.cfg
	done
	
	date > ${BASE}/src/etc/A.cfg
	date > ${BASE}/dst/etc/A.cfg	
	
	# include, exclude files
	
	cat << EOF > ${BASE}/include.cfg
${BASE}/src/etc/
EOF

	cat << EOF > ${BASE}/exclude.cfg
${BASE}/src/etc/config/*.cfg
EOF
}

addFiles () {
		rm ${BASE}/src/etc/config/*

        for i in {3,4,5}
        do
                date > ${BASE}/src/etc/config/$i.cfg
        done
}

testFiles () {
	TAR_BASE=$1

	ls /tmp/src/etc/config/

	if [[ ! -e ${BASE}/src/etc/config/4.cfg ]] || [[ ! -e ${BASE}/src/etc/config/5.cfg ]]
	then
		echo "$TAR_BASE - ERROR"
	else
		echo "$TAR_BASE - OK"	
	fi
}

testTar () {
	TAR_BASE=$1

	$TAR_BASE/src/tar --version | grep "GNU tar"
	
	prepare	
	
	tree ${BASE}/src
	
	[[ -f /tmp/snapshot ]] && rm /tmp/snapshot
	
	# pushd ${BASE}/src > /dev/null
	
	echo "Compressing...."
	
	#../$TAR_BASE/src/tar -g /tmp/snapshot -cvz -f /tmp/test.tar.gz -T ../include.cfg -X ../exclude.cfg
	
	#$TAR_BASE/src/tar -g /tmp/snapshot -cvz -f /tmp/test.tar.gz -T ${BASE}/include.cfg -X ${BASE}/exclude.cfg  
 
	$TAR_BASE/src/tar -g /tmp/snapshot -cvz -f /tmp/test.tar.gz -X ${BASE}/exclude.cfg -T ${BASE}/include.cfg

	#pushd ${BASE}/dst > /dev/null
	
	echo "De-compressing...."
	
	addFiles
	tree ${BASE}/src
	
	#../$TAR_BASE/src/tar --extract --force-local --listed-incremental=/dev/null --file /tmp/test.tar.gz -v -C .
	
	$TAR_BASE/src/tar --overwrite --extract --force-local --listed-incremental=/dev/null --file /tmp/test.tar.gz -v -C /
	
	tree ${BASE}/src

	echo "-----------------"
	echo "   TAR LIST "
	$TAR_BASE/src/tar --list --incremental --verbose --verbose --file /tmp/test.tar.gz
	echo "-----------------"
	
	testFiles $TAR_BASE
}

makeTar () {
	for i in $(find . ! -path . -type d -maxdepth 1)
	do
		echo $i
		pushd $(basename $i) > /dev/null
		pwd
		# ./configure &
		# make &
	
		src/tar --version
 
		popd  > /dev/null
	done
}

for tar in $(find . ! -path . -type d -maxdepth 1)
do
	echo "======== TEST START ==============="
	echo $tar

	#tar=tar-1.26

	testTar $tar
	
	echo "========= TEST END ================"
	echo
done


exit


for tar in $(find . ! -path . -type d -maxdepth 1)
do
	echo $tar
	pushd $(basename $tar) > /dev/null
	pwd
	# ./configure &
	# make &

	src/tar --version
done