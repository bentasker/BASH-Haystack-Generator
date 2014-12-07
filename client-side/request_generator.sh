#!/bin/bash
#
# Client side traffic generator
#

mydir=`dirname $0`


while getopts "c:" flag
do

        case "$flag" in
                c) configfile="$OPTARG";;
        esac
done


configfile=${configfile:-"$mydir/config"}


if [[ ! -f "$configfile" ]]
then
	if [[ ! -f "$mydir/$configfile" ]]
	then
		echo "Config file ($configfile) not found"
		exit
	fi
	configfile="$mydir/$configfile"
fi


# Load the config
source "$configfile"


[[ -f "$LOCKFILE" ]] && exit;


# Function to place the request - may do more later
placeRequest(){
	URL=$1
	HOST=$2
	START=$3
	END=$4
	UPSTREAM=$5
	DATA=$6

	if [ "$UPSTREAM" == 'n' ]
	then
		# Place the request
		curl -H "User-agent: $USER_AGENT" -H "Host: $HOST" -H "Range: bytes=$START-$END" "$URL" > /dev/null 2> /dev/null
	else
		curl -X POST -d "$DATA" -H "User-agent: $USER_AGENT" -H "Host: $HOST" -H "Range: bytes=$START-$END" "$URL" > /dev/null 2> /dev/null
	fi
}




# Start

# We're going to be using RANDOM quite a lot
RANDOM=$$ # Start by seeding with the pid

REQUESTS=$((RANDOM%$MAX_REQUESTS)) # How many requests to make

if [[ "$RANDOMIZE_CHUNKSIZE" == "n" ]]
then
	CHUNKS=$((RANDOM%$MAX_CHUNK_SIZE)) # Chunk size
fi


if [[ "$SEND_DATA" == "y" ]] && [[ "$RANDOMIZE_US_CHUNKSIZE" == "n" ]]
then
	UPSTREAM_LEN=$((RANDOM%$MAX_UPSTREAM))
	UPSTREAM_DATA=`cat /dev/urandom | tr -dc 'a-zA-Z0-9-_@#$%^&*()_+{}|:<>?='|fold -w $UPSTREAM_LEN| head -n 1`
fi


echo "Will place $REQUESTS Request(s)"

for i in `seq 1 $REQUESTS`
do
	if [[ ! "$RANDOMIZE_CHUNKSIZE" == "n" ]]
	then
		CHUNKS=$((RANDOM%$MAX_CHUNK_SIZE)) # Chunk size
	fi

	if [[ "$SEND_DATA" == "y" ]] && [[ "$RANDOMIZE_US_CHUNKSIZE" == "y" ]]
	then
		UPSTREAM_LEN=$((RANDOM%$MAX_UPSTREAM))
		UPSTREAM_DATA=`cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!@#$%^&*()_+{}|:<>?='|fold -w $UPSTREAM_LEN| head -n 1`
	fi



	START=$((RANDOM%134217727)) # (1Gib-1byte) - if the end range falls outside 1Gib we'll just be served the remaining 1 byte
	END=$(( $START + $CHUNKS)) # Calculate the end of the range

	echo "Requesting range $START-$END (Chunk size $CHUNKS bytes) from $REMOTE_FILE"

	if [[ "$SEND_DATA" == "y" ]]
	then
		echo "Sending $UPSTREAM_LEN bytes of meaningless data with the request"
	fi

	placeRequest "$REMOTE_FILE" "$HTTP_HOSTNAME" "$START" "$END" "$SEND_DATA" "$UPSTREAM_DATA"

	DELAY=$((RANDOM%$MAX_DELAY)) # Work out how long to delay the next request by
	echo "Waiting $DELAY seconds until next request"
	echo 
	sleep $DELAY

done





