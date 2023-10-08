# utility scripts for bash (specifically written for Unraid - debian 

## Description 

For [Memories](https://memories.gallery) on Nextcloud, the Timeline view is (at least by default) based off the modified date of the photos. 

Sometimes when files are moved around/downloaded/whatever, this date gets changed which will cause photos to appear out of their natural, chronological order as viewed on the timeline. 


## Prerequisites

 
This script requires the [installation of ImageMagick](https://www.linuxcapable.com/how-to-install-imagemagick-on-debian-linux/)for the `identify` utility that it installs to extract the exif metadata.


## The "fix" 

In order to address this, I wrote a script to go through all the photos in a folder and extract the appropriate date. 

In the batch of photos that I was working on, I found the following three locations for the date I wanted to use, each with their own slightly different format: 

### 1 & 2 Together

``` 
  Properties:
    date:create: 2023-10-07T19:25:11+00:00
    date:modify: 2021-03-17T07:00:00+00:00
    exif:Copyright: Copyright Lifetouch Inc. 2021
    exif:DateTimeDigitized: 2021-03-22T17:48:02Z
    exif:DateTimeOriginal: 2021-03-17T00:00:00Z
``` 

The `DateTimeOriginal` and `date:modify` seem to have the same date and the format here is `YYYY-MM-DDTHH:MM:SSZ` or `YYYY-MM-DDTHH:MM+SS:MS`

### All 3 in one file
``` 
    date:create: 2023-10-07T19:25:17+00:00
    date:modify: 2021-01-26T08:00:00+00:00
    exif:ApertureValue: 54823/32325
    exif:BrightnessValue: 74612/41543
    exif:ColorSpace: 1
    exif:ComponentsConfiguration: 1, 2, 3, 0
    exif:DateTime: 2021:01:26 14:45:40
    exif:DateTimeDigitized: 2021:01:26 14:45:40
    exif:DateTimeOriginal: 2021:01:26 14:45:40
``` 

The `exif:DateTime` property has the format ```YYYY:MM:DD[[:space]]HH:DD:SS```

I think there were photos where only one of the three existed, so the logic I implemented here will grab and set the date as long as any of the three are populated.

## "Fun" problems during development

* Ran into lots of difficulties initially because of spaces in filenames. This is an informative post on [why looping over find output is bad practice.](https://unix.stackexchange.com/questions/321697/why-is-looping-over-finds-output-bad-practice)
   * This helped me arrive at my final solution of calling the script from in the recommended way like this:
   ```
   find ./ -type f \( -iname \*.jpg \) -exec sh -c 'for f do ../touch_exif_photos.sh "$f"; done' find-sh {} \;
   ```

   * Additionally, the syntax for doing this for multiple filetypes would look like this:
   ```
   find ./ -type f \( -iname \*.jpg -o -name \*.png -o -name '\*.JPG のコピー' \) -exec sh -c 'for f do ../touch_exif_photos.sh "$f"; done' find-sh {} \;
   ```
   

* Chaining `grep` and `sed`, using `xargs` & `exec` have lots of gotchas and intricacies, but I like the way I ended up with one pipeline to extract out the date. I'm sure there are are more clever (and just better) ways of getting it out, which may properly consider the structure of the exif metadata, etc.

## Possible future features

* generate a test-run to show files and the proposed dates
* allow user input to select which date to use if there are multiple dates
* flag files which are missing or have a date that may not be appropriate (like today's date)


