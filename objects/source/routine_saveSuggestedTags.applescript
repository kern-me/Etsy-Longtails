on load_script(_scriptName)
	tell application "Finder"
		set _myPath to container of (path to me) as string
		set _loadPath to (_myPath & _scriptName) as string
		load script (alias _loadPath)
	end tell
end load_script

--

on saveSuggestedTags()
	set a to load_script("handler_getSuggestedTags.scpt")
	set b to load_script("handler_files.scpt")
	
	set theCount to -1
	set theData to ""
	
	repeat
		set updatedCount to (theCount + 1)
		
		tell a to set theData to getSuggestedTags(updatedCount)
		
		if theData is false then
			exit repeat
		end if
		
		set theCount to theCount + 1
		
		tell b to writeFile(theData & newLine, false, "suggested tags", "txt") as text
	end repeat
	
	return
end saveSuggestedTags