#!/bin/bash
#
# Client side traffic generator
#

mydir=`dirname $0`

# Load the config

source "$mydir/config"


# Function to place the request - may do more later
placeRequest(){
	URL=$1
	HOST=$2
	START=$3
	END=$4


	# Place the request
	wget -O /dev/null --header="Host: $HOST" --header="Range: bytes $START-$END" "$URL" 2> /dev/null
}




# Start

# We're going to be using RANDOM quite a lot
RANDOM=$$ # Start by seeding with the pid

REQUESTS=$((RANDOM%$MAX_REQUESTS)) # How many requests to make

if [[ "$RANDOMIZE_CHUNKSIZE" == "n" ]]
then
	CHUNKS=$((RANDOM%$MAX_CHUNK_SIZE)) # Chunk size
fi


echo "Will place $REQUESTS Request(s)"

for i in `seq 1 $REQUESTS`
do
	if [[ ! "$RANDOMIZE_CHUNKSIZE" == "n" ]]
	then
		CHUNKS=$((RANDOM%$MAX_CHUNK_SIZE)) # Chunk size
	fi

	START=$((RANDOM%134217727)) # (1Gib-1byte) - if the end range falls outside 1Gib we'll just be served the remaining 1 byte
	END=$(( $START + $CHUNKS)) # Calculate the end of the range

	echo "Requesting range $START-$END (Chunk size $CHUNKS bytes) from $REMOTE_FILE"
	placeRequest "$REMOTE_FILE" "$HTTP_HOSTNAME" "$START" "$END"

	DELAY=$((RANDOM%5)) # Work out how long to delay the next request by
	echo "Waiting $DELAY seconds until next request"
	sleep $DELAY

done





