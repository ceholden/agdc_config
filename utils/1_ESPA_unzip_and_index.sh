#!/bin/bash
# Script to extract and index an ESPA product into the datacube

set -e

# ROOT=/projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/TEST_DATA

function usage() {
    echo "Usage: $0 <ESPA Product (tar.gz)>"
    exit 1
}

if [ -z "$DATACUBE_CONFIG_PATH" ]; then
    echo "Where is your datacube.conf? (define DATACUBE_CONFIG_PATH)"
    exit 1
fi

if [ -z $1 ]; then
    echo "Error: Must specify a product to index"
    usage
fi
ARCHIVE=$1

# TODO: hard coded prep script
# PREP=/projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/agdc-v2/utils/usgslsprepare.py
PREP=/home/ceholden/Documents/DATACUBE/agdc-v2/utils/usgslsprepare.py
# TODO: hard coded
EXTRACTED=$ROOT/extract
mkdir -p $EXTRACTED
# TODO: hard coded 'completed'
COMPLETED=$ROOT/completed
mkdir -p $COMPLETED

PRODUCT_ID=$(basename $ARCHIVE .tar.gz)
EXTRACT_DIR=$EXTRACTED/$PRODUCT_ID
mkdir -p $EXTRACT_DIR

SCENE_ID=$(basename $(tar -tf $ARCHIVE | grep ".xml") .xml)

echo "Unzipping"
tar -C $EXTRACT_DIR \
    --keep-old-files \
    --exclude "${SCENE_ID}_band*" \
    -xvf $ARCHIVE

# echo "Removing DN band images"
# SCENE_ID=$(ls -1 $EXTRACT_DIR/ | head -n 1 | awk -F '_' '{ print $1 }')
# rm -vf $EXTRACT_DIR/${SCENE_ID}_band*.tif

echo "Preparing dataset metadata"
python $PREP $EXTRACT_DIR/ 

echo "Indexing"
datacube dataset add --auto-match $EXTRACT_DIR

echo "Indexed the data -- moving archive"
mv $ARCHIVE $COMPLETED/
