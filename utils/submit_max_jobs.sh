#!/bin/bash

set -e

SCRIPT=/projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/1_unzip_and_index.sh

MAX=$1
ARCHIVES=${@:2}

narchives=$(echo $ARCHIVES | wc -w)
nsplit=$(expr $narchives / $MAX + 1)

SUBMITTED=()

i=1
group=1
for archive in $ARCHIVES; do
    if [ $i -gt $nsplit ]; then
        i=1
        let group+=1
    fi
    if [ $i -eq 1 ]; then
        HOLD=""
    else
        HOLD="-hold_jid ${SUBMITTED[$group]}"
    fi

    echo "Submitting: $group/$MAX: $i/$nsplit - $archive"

    SUBMITTED[$group]=$(qsub -terse \
        -V -j y -l h_rt=24:00:00 -N unzip_${group}-${i} \
        $HOLD \
        $SCRIPT $archive)
    let i+=1
done
