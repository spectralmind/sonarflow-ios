#!/bin/sh

#  FetchCannedResults.sh
#  SMArtist
#
#  Created by Fabian on 05.09.11.
#  Copyright (c) 2011 Spectralmind. All rights reserved.
#
# renews the canned results for the test cases


CANNEDRESULTSDIR="cannedresults"

NOW=$(date +"%Y-%m-%d_%T")

echo $NOW

if [ -d "$CANNEDRESULTSDIR" ]; then
    echo backing up $CANNEDRESULTSDIR
    mv $CANNEDRESULTSDIR ${CANNEDRESULTSDIR}_BACKUP_$NOW
fi

mkdir $CANNEDRESULTSDIR



echo loading last.fm results into $CANNEDRESULTSDIR


curl "http://ws.audioscrobbler.com/2.0/?api_key=fce4ee314339e5192fe28938e4795b9b&format=json&method=artist.getSimilar&artist=cher&limit=30" -o $CANNEDRESULTSDIR/lastfm_similarity_artist-cher_limit-30_correctresponse.json

curl "http://ws.audioscrobbler.com/2.0/?api_key=fce4ee314339e5192fe28938e4795b9b&format=json&method=artist.getInfo&artist=cher" -o $CANNEDRESULTSDIR/lastfm_bios_artist-cher_limit-30_correctresponse.json

curl "http://ws.audioscrobbler.com/2.0/?api_key=fce4ee314339e5192fe28938e4795b9b&format=json&method=artist.getImages&artist=cher&limit=30" -o $CANNEDRESULTSDIR/lastfm_images_artist-cher_limit-30_correctresponse.json



echo loading echonest results into $CANNEDRESULTSDIR


curl "http://developer.echonest.com/api/v4/artist/similar?api_key=YV4GJANNDGN3MWBQG&format=json&results=30&name=cher" -o $CANNEDRESULTSDIR/echonest_similarity_artist-cher_limit-30_correctresponse.json

curl "http://developer.echonest.com/api/v4/artist/images?api_key=YV4GJANNDGN3MWBQG&format=json&results=30&name=cher" -o $CANNEDRESULTSDIR/echonest_images_artist-cher_limit-30_correctresponse.json

curl "http://developer.echonest.com/api/v4/artist/biographies?api_key=YV4GJANNDGN3MWBQG&format=json&results=30&name=cher" -o $CANNEDRESULTSDIR/echonest_bios_artist-cher_limit-30_correctresponse.json






