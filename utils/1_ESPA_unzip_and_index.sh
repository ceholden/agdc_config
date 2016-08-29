#!/bin/bash
# Script to extract and index an ESPA product into the datacube

set -e

# TODO: hard coded prep script
PREP=/projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/agdc-v2/utils/usgslsprepare.py

# if [ -z $TMPDIR ]; then
#     TMPDIR=/tmp
# fi
# ROOT=$TMPDIR/$USER/

ROOT=/projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/TEST_DATA
EXTRACTED="${ROOT}/extract"
COMPLETED="${ROOT}/complete"

mkdir -p $EXTRACTED
mkdir -p $COMPLETED

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

PRODUCT_ID=$(basename $ARCHIVE .tar.gz)
EXTRACT_DIR=$EXTRACTED/$PRODUCT_ID
SCENE_ID=$(basename $(tar -tf $ARCHIVE | grep ".xml") .xml)

echo "Extracing $ARCHIVE to ${EXTRACT_DIR}..."
mkdir -p $EXTRACT_DIR

echo "Unzipping scene ID: ${SCENE_ID}..."
tar -C $EXTRACT_DIR \
    --keep-old-files \
    --exclude "${SCENE_ID}_band*" \
    -xf $ARCHIVE

echo "Preparing dataset metadata..."
python $PREP $EXTRACT_DIR/ 

echo "Indexing..."
datacube -v dataset add --auto-match $EXTRACT_DIR

echo "Done processing $ARCHIVE -- relocating"
mv $ARCHIVE $COMPLETED/
