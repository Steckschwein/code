#!/bin/bash

pythonbin=`which python3`
if [ -z "${pythonbin}" ];then
	echo "python not found!"
	exit -1
fi
pyversion=$(${pythonbin} --version 2>&1 | cut -d '.' -f1)
if ! [[ ${pyversion} =~ 3.* ]]; then
	echo "${pyversion} detected, 3.x required!"
	exit -1
fi

output=0x0200	# use steckschwein i/o area as default to avoid conflicts. on steckschwein, code are never placed here
dir=`dirname $0`
if [ -z "$1" ]; then
	echo "usage $0 <file> [address, defaults 0x1000]" >&2
	exit 1;
fi
if [ ! -r "$1" ]; then
	echo "file $1 does not exist or is not accessible!" >&2
	exit 1;
fi
ld_address=$2
if [ -z ${ld_address} ]; then
	ld_address="$1000"
fi
binary=$1
#echo ${pythonbin} ${dir}/asmunit.monitor.py -m 65c02 --output $output
#echo .load "${binary}" ${ld_address} > /tmp/$$.py65
#echo .add_breakpoint 0x19cf >> /tmp/$$.py65
#echo .goto ${ld_address} >> /tmp/$$.py65

#.add_breakpoint 0x19cf
# exec &> >(tee -a "$output")
if [ "$ASMUNIT_ATTACH" == true ]; then
	echo ".load "${binary}" ${ld_address}"
	echo ".goto ${ld_address}"
	exec ${pythonbin} ${dir}/asmunit.monitor.py --mpu 65C02 --output $output
else
	exec ${pythonbin} ${dir}/asmunit.monitor.py --mpu 65C02 --output $output <<EOF
	.load "${binary}" ${ld_address}
	.goto ${ld_address}
EOF
fi
