#!/bin/bash
#
#
#

mydir=`dirname $0`

# Load the config

source "$mydir/config"



dd if=$DATA_SOURCE of=$OUTPUT_FILE bs=1M count=1024
