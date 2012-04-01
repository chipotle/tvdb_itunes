tell application "iTunes" to set mySelection to selection

repeat with trackItem in mySelection
	set trackEpisode to get_episode for trackItem
	set trackSeason to get_season for trackItem
	set trackShow to get_show for trackItem
	set trackInfo to {tshow:trackShow, episode:trackEpisode, season:trackSeason}
	set trackData to get_tvdb_data for trackInfo
	update_track(trackItem, trackData)
end repeat

on get_episode for trackItem
	tell application "iTunes"
		if (episode number of trackItem) > 0 then
			return episode number of trackItem
		else
			set SeasonEpisode to parse_filename of me for trackItem
			return episode of SeasonEpisode
		end if
	end tell
end get_episode

on get_season for trackItem
	tell application "iTunes"
		if (season number of trackItem) > 0 then
			return season number of trackItem
		else
			set SeasonEpisode to parse_filename of me for trackItem
			return season of SeasonEpisode
		end if
	end tell
end get_season

on parse_filename for trackItem
	tell application "iTunes"
		considering case
			set fullPath to (location of trackItem) as string
			set AppleScript's text item delimiters to ":"
			set these_items to text items of fullPath
			set nameItem to last item of these_items
			set AppleScript's text item delimiters to {""}
			set offsetS to (offset of ".S" in nameItem)
			set offsetE to (offset of "E" in nameItem)
			if offsetE = (offsetS + 4) then
				set epnum to text (offsetE + 1) through (offsetE + 2) of nameItem
				set seasnum to text (offsetS + 2) through (offsetS + 3) of nameItem
				log "First clause hit: " & epnum & " " & seasnum
			else
				set nameItem to name of trackItem
				set offsetS to (offset of "S" in nameItem)
				set offsetE to (offset of "E" in nameItem)
				if offsetE = (offsetS + 3) then
					set epnum to text (offsetE + 1) through (offsetE + 2) of nameItem
					set seasnum to text (offsetS + 1) through (offsetS + 2) of nameItem
					log "Second clause hit: " & epnum & " " & seasnum
					
				else
					set epnum to 0
					set seasnum to 0
				end if
			end if
			set SeasonEpisode to {episode:epnum, season:seasnum}
			return SeasonEpisode
		end considering
	end tell
end parse_filename

on get_show for trackItem
	tell application "iTunes"
		if (show of trackItem) is not "" then
			set showName to show of trackItem
		else
			set fullPath to (location of trackItem) as string
			set AppleScript's text item delimiters to ":"
			set these_items to text items of fullPath
			set nameItem to last item of these_items
			set AppleScript's text item delimiters to {""}
			set offsetS to (offset of ".S" in nameItem)
			if offsetS > 0 then
				set fileName to text 1 through (offsetS - 1) of nameItem
				set AppleScript's text item delimiters to "."
				set these_items to text items of fileName
				set AppleScript's text item delimiters to space
				set showName to these_items as string
				set AppleScript's text item delimiters to {""}
			else
				set showName to "Unknown"
			end if
		end if
		-- TO DO: map returned showname against correction databse
		return showName
	end tell
end get_show


on get_tvdb_data for track
	set myscript to "
#!/usr/bin/env python
import sys
import tvdb_api
t = tvdb_api.Tvdb()
show_name = sys.argv[1].decode('utf-8')
season = sys.argv[2].decode('utf-8')
episode = sys.argv[3].decode('utf-8')

try:
	data = t[show_name][int(season)][int(episode)]
except Exception, e:
	print '!! Error %s ' % e
	sys.exit(1)
print data['episodename'].encode('utf-8')
print data['overview'].encode('utf-8')
print data['firstaired']
print data['absolute_number']
"
	set trackSeason to season of track
	set trackEpisode to episode of track
	set trackShow to tshow of track
	set command to "/usr/bin/python -c " & quoted form of myscript & " " & quoted form of trackShow & " " & trackSeason & " " & trackEpisode
	set myResult to (do shell script command)
	if (offset of "!!" in myResult) > 0 then
		display dialog myResult with icon stop
		set trackData to {"", "", "", ""}
	else
		set AppleScript's text item delimiters to return
		set resultItems to text items of myResult
		set AppleScript's text item delimiters to {""}
		set newTitle to (item 1 of resultItems)
		set newDescription to (item 2 of resultItems)
		if (item 3 of resultItems) is not "None" then
			set newYear to text 1 thru 4 of (item 3 of resultItems)
		else
			set newYear to ""
		end if
		set newEpisodeID to (item 4 of resultItems)
		set trackData to {newTitle:newTitle, newDescription:newDescription, newYear:newYear, newEpisodeID:newEpisodeID, trackShow:trackShow, trackSeason:trackSeason, trackEpisode:trackEpisode}
	end if
	return trackData
end get_tvdb_data

on update_track(trackItem, trackData)
	set newTitle to newTitle of trackData
	set newDescription to newDescription of trackData
	set newYear to newYear of trackData
	set newEpisodeID to newEpisodeID of trackData
	set trackShow to trackShow of trackData
	set trackSeason to (trackSeason of trackData) as number
	set trackEpisode to (trackEpisode of trackData) as number
	log trackShow & " - " & trackSeason & " - " & trackEpisode
	tell application "iTunes"
		set season number of trackItem to trackSeason
		set episode number of trackItem to trackEpisode
		set track number of trackItem to trackEpisode
		set show of trackItem to trackShow
		set artist of trackItem to trackShow
		set albumName to trackShow & ", Season " & trackSeason
		set album of trackItem to albumName
		if newTitle is not "None" then
			set name of trackItem to newTitle
		end if
		if newDescription is not "None" then
			set description of trackItem to newDescription
		end if
		if newYear is not "" then
			set year of trackItem to newYear
		end if
		if newEpisodeID is not "None" then
			set episode ID of trackItem to newEpisodeID
		end if
		set video kind of trackItem to TV show
	end tell
end update_track
