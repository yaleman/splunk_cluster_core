#!/bin/bash

# This is terrible, you really need to know what you're doing. It was used as a one-off migration script because the on-prem boxes were so old.

SUFFIX=$(echo -n "$(hostname -f)" | shasum)
#if [ "$(hostname -s)" == "exampleserver" ]; then
#        SUFFIX=001
#else
#        SUFFIX=002
#fi

echo "Adding suffix '${SUFFIX}' to buckets"

INDEXNAME="${1}"

read -rp "Copying bucket ${INDEXNAME}, hit ENTER to continue..."

while IFS= read -r -d '' folder
do
    echo "migrator script copying ${folder}"
    #example folder value: /var/log/splunkcold/security/colddb/db_1562810642_1561695768_86

    SHORTFOLDER=$(basename "${folder}")
    echo "shortbutts ${SHORTFOLDER} shortbutts"
    #example SHORTFOLDER value: db_1562810642_1561695768_86

    rsync --bwlimit 10240 -avz "${folder}" "migrator.example.com:/splunkdata/${INDEXNAME}/db/${SHORTFOLDER}${SUFFIX}"
done < <(find /var/log/ -type d -wholename "/var/log/splunk*/${INDEXNAME}/*db/db_*" -not -name '*rawdata' -print0)