# TVDB / iTunes Connector

These are two AppleScripts designed to add metadata from the open source TV Database (<http://thetvdb.com>) to files in iTunes. The input files are expected to follow a quasi-standard naming convention of

	Exciting.Show.Name.S01E01.Blargh.mp4

One script is intended to be used from within iTunes itself, and the other--which relies on the first script--is intended to be attached as a folder action.

## Prerequisites

These rely on a Python library called "tvdb_api." This may be installed on OS X with

	sudo easy_install tvdb_api

(For the Python fans in the audience, `pip` is a better choice if you have it, of course.)

## Installation

Both of these scripts should be loaded into and resaved with AppleScript Editor as `scpt` files (the output of "Save..." is fine). Copy "Get TV Show Data" into 

	~/Library/iTunes/Scripts

Note that it *must* be named exactly that for the folder action script to find it.

## Get TV Show Data

Select one or more files in iTunes and run this script (from iTunes' script menu). If it can find the TV show data in the database, it will add the show's correct title, description, year aired, and episode ID, and set other iTunes metadata in similar fashion to a TV show purchased from iTunes.

Note that shows that have a discrepancy between the filename and the listing in the database may come back with no information or, if you're lucky, incorrect information. A file whose show name is parsed as "CSI," for example, will *not* match the name "CSI: Crime Scene Investigation" in the database. To correct this problem, use the "Get Info" command on the file to enter the show name as it appears in TVDB (which you can determine by going to the web site), and then run the "Get TV Show Data" script again.

## Move TV Shows to iTunes

This is intended to be set as a folder action on a "drop folder." It will take files that are placed in that folder, and if they end in ".mp4" or ".m4v", add them to iTunes, delete them from the drop folder, and run the same functions as "Get TV Show Data" does.

If you set up another program, such as Transmission, to copy files into the folder with the action on it, make sure that it doesn't put incomplete files in there. (Transmission has a setting to store incomplete files in a different folder.)

Note that this script assumes you're letting iTunes move media into the iTunes Media directory when it's added rather than just storing references to files. If you're doing the latter, you'll need to modify the script in some fashion.
