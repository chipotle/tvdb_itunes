on adding folder items to target_folder after receiving myItems
	set getDataLibFile to path to home folder as string
	set getDataLibFile to getDataLibFile & "Library:iTunes:Scripts:Get TV Show Data.scpt"
	set getDataLibFile to getDataLibFile as alias
	set getDataLib to load script getDataLibFile
	repeat with i from 1 to the count of myItems
		set inputFile to item i of myItems
		set stringName to inputFile as string
		if (offset of ".mp4" in stringName) > 0 or (offset of ".m4v" in stringName) > 0 then
			try
				tell application "iTunes" to set trackItem to (add inputFile)
				tell application "Finder" to delete inputFile
				tell getDataLib
					set trackEpisode to get_episode for trackItem
					set trackSeason to get_season for trackItem
					set trackShow to get_show for trackItem
					set trackInfo to {tshow:trackShow, episode:trackEpisode, season:trackSeason}
					set trackData to get_tvdb_data for trackInfo
					update_track(trackItem, trackData)
				end tell
			end try
		end if
	end repeat
end adding folder items to
