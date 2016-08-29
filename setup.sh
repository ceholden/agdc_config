#!/bin/bash
#
# Some resources:
# * http://www.thegeekstuff.com/2014/02/enable-remote-postgresql-connection/
# * http://blog.endpoint.com/2013/06/installing-postgresql-without-root.html
# * https://agdc-v2.readthedocs.io/en/develop/ops/db_setup.html

export PGHOST=geo.bu.edu
export PGUSER=ceholden

export AGDC_ROOT=/projectnb/landsat/datasets/AGDC/
export AGDC_DB=$AGDC_ROOT/DATABASE
export AGDC_DATA=$AGDC_ROOT/TILES

mkdir -p $AGDC_DATA

export AGDC_CONFIG=/projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/config
export DATACUBE_CONFIG_PATH=$AGDC_CONFIG/datacube.conf

# 1. Install conda environment

# 2. Configure PostgreSQL
# 2.1. Init the database
initdb -D $AGDC_DB
# 2.2. Configure pg_hba.conf
#       This should be in your PGDATA dir, but you can check with
#       `SHOW hba_file;`
cp $AGDC_CONFIG/db/pg_hba.conf $AGDC_DB/
# 2.3. Configure postgresql.conf
#       This should be in your PGDATA dir, but you can check with
#       `SHOW config_file;`
cp $AGDC_CONFIG/db/postgresql.conf $AGDC_DB/
# 2.4. Run the database
postgres -D $AGDC_DB

# 3. Setup AGDC db
# 3.1. Create the datacube
# createdb datacube
createdb -h $PGHOST -U $PGUSER datacube

# 3.2. Create datacube configuration file
#   Default location is ~/.datacube.conf
#   Alternatively, define $DATACUBE_CONFIG_PATH

# 3.3. Init datacube schema
datacube -v system init

# 3.4. Init product definitions
# TODO: Landsat 4 (and MSS!)
datacube -v  product add $AGDC_CONFIG/product/ls5_scenes.yaml
datacube -v  product add $AGDC_CONFIG/product/ls7_scenes.yaml
datacube -v  product add $AGDC_CONFIG/product/ls8_scenes.yaml

# 3.5. Create metadata doc for data
./agdc-v2/utils/usgslsprepare.py /projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/TEST_DATA/LC80120312016115-SC20160707131945

# 3.6. Index some data
datacube dataset add --auto-match /projectnb/landsat/users/ceholden/2016_DATACUBE/AGDC/TEST_DATA/LC80120312016115-SC20160707131945

# 3.7. Run index
datacube ingest --executor distributed 192.12.187.132:8786 -c config/ingest/ls8_espa_albers.yaml
