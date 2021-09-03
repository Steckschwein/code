#!/bin/bash

dir=`dirname $0`
logfile=$1.log

_ts=$(date +%s%N)
$dir/asmunit_runner.sh $1 $2 > $logfile
_tt=$((($(date +%s%N) - $_ts)/1000000))
test_fail=`grep "FAIL" $logfile | wc -l`
tests=$(grep "\[.*\]" $logfile | wc -l)

if [ "${ASMUNIT_VERBOSE}" == true ]; then
   echo "[DEBUG] TEST OUTPUT"
   cat $logfile
fi

# PC  AC XR YR SP NV-BDIZC
# 65C02: 226a 42 00 ff ff 10110001
_SP=$(tail -2 $logfile|head -1|cut -d ' ' -f6)
if [ ! "${_SP}" = "ff" ]; then
   echo "[ERROR] Stack corruption detected! Either your test or testee are broken. Expect SP=0xff after test was running."
   tail -3 $logfile
   exit 1
fi


if [ "${3}" = false ]; then
    exit 0
fi

if [ "${tests}" -eq 0 ]; then
    echo "[ERROR] No Unit tests found. Make sure at least one test exists within ${1} and is labeled via test_name <name of test>!" >&2
    exit 1
fi

if [ -z "${TARGET_DIR}" ]; then
	TARGET_DIR=target/test-reports
fi

mkdir -p ${TARGET_DIR}
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<testsuite xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"https://maven.apache.org/surefire/maven-surefire-plugin/xsd/surefire-test-report.xsd\"
	name=\"${1}\"
	time=\"$(awk "BEGIN {printf (\"%.3f\"), ${_tt}/1000}")\"
	tests=\"${tests}\"
	errors=\"0\"
	skipped=\"0\"
	failures=\"${test_fail}\">" > ${TARGET_DIR}/${1}.xml

	while IFS='' read -r line || [[ -n "$line" ]]; do
		if [[ $line =~ ^\[(.*)\]$ ]] ; then
#			echo ${BASH_REMATCH[1]} line was $line
			echo "<testcase name=\"${BASH_REMATCH[1]}\" classname=\"${1}\" time=\"0\"/>" >> ${TARGET_DIR}/${1}.xml
#		echo "<testcase name=\"\" classname=\"${1}\" time=\"0\"/>"
		fi
	done < $logfile

echo "</testsuite>" >> ${TARGET_DIR}/${1}.xml

echo "Tests run: "${tests}", Failures: ${test_fail}"
if [ -n "`grep FAIL $logfile`" ] ; then
	cat $logfile
    exit 1
fi

exit 0
