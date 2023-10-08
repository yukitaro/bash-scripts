#!/bin/bash

identifyStr=$(identify -verbose "$@")
justthedate=$(echo "$identifyStr" | grep -oP "exif\:DateTimeOriginal\:[[:space:]]\d{4}-\d{2}-\d{2}T\d{2}\:\d{2}\:\d{2}Z" | \
sed -E 's/exif:DateTimeOriginal: //' | sed -E 's|([0-9]{4})-([0-9]{2})-([0-9]{2})T[0-9]{2}:[0-9]{2}:[0-9]{2}Z|\1\2\30000.00|')

n=`echo $justthedate | awk '{print length}'`
if [ $n -gt 0 ]
then
  # exif:DateTimeOriginal: 2021:01:26 14:45:40
   touch -a -m -t $justthedate "$@"
else
  # exif:DateTime: 2021:01:26 14:45:40
  dateFromDateTime=$(echo "$identifyStr" | grep "exif:DateTime:" | \
  sed -E 's/exif:DateTime: //' | sed -E 's|([0-9]{4}):([0-9]{2}):([0-9]{2}) [0-9]{2}:[0-9]{2}:[0-9]{2}|\1\2\30000.00|')

  length2=`echo $dateFromDateTime | awk '{print length}'`
  if [ $length2 -gt 0 ]
  then
    touch -a -m -t $dateFromDateTime "$@"
  else
    # date:modify: 2021-03-22T07:00:00+00:00
    dateFromDateModify=$(echo "$identifyStr" | grep "date:modify: " | \
    sed -E 's/date:modify: //' | sed -E 's|([0-9]{4})-([0-9]{2})-([0-9]{2})T[0-9]{2}:[0-9]{2}:[0-9]{2}\+[0-9]{2}:[0-9]{2}|\1\2\30000.00|')
     touch -a -m -t $dateFromDateModify "$@"
  fi
fi
