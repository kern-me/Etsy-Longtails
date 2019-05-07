###################
# PROPERTIES
###################
# Delays
property theDelay : 1

# Formatting
property newLine : "\n"

###################
# LOAD SCRIPT
###################
on load_script(_scriptName)
	tell application "Finder"
		set _myPath to container of (path to me) as string
		set _loadPath to (_myPath & _scriptName) as string
		load script (alias _loadPath)
	end tell
end load_script

##############################
# ROUTINES
##############################
on processBaseKeywordsFile(actionSetting)
	set unixPath to POSIX path of ((path to me as text) & "::")
	set objectPath to unixPath & "objects/"
	
	set a to load_script("objects:list_fromFile.scpt")
	set b to objectPath & "_alphabet.txt"
	set c to unixPath & "_base-keywords.txt"
	set d to load_script("objects:do_etsyInput.scpt")
	set e to load_script("objects:routine_makeList.scpt")
	set f to load_script("objects:list_insert.scpt")
	set g to load_script("objects:load_GUI.scpt")
	
	tell a
		set theList to makeListFromFile(b)
		set theList2 to makeListFromFile(c)
	end tell
	
	set theResultsList to {}
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		set AppleScript's text item delimiters to newLine
		set text item delimiters to newLine
		
		repeat with a from 1 to length of theList2
			set AppleScript's text item delimiters to newLine
			set text item delimiters to newLine
			
			set theCurrentListItem2 to item a of theList2
			set theQuery to (theCurrentListItem2 & " " & theCurrentListItem)
			tell g
				tell d to inputEvent(theQuery)
				delay 2
			end tell
			
			tell e to set theItem to makeList(-1, newLine, 4, false) as text
			
			tell f to insertItemInList(theItem, theResultsList, 1) as text
			
		end repeat
	end repeat
	
	if actionSetting is 1 then
		return theResultsList as text
	else if actionSetting is 2 then
		set h to load_script("objects:file_write.scpt")
		set theResultsList to theResultsList as text
		tell h to writeFile(theResultsList, false, "longtail results", "txt")
	end if
end processBaseKeywordsFile

#####################################

on getLongtails()
	set unixPath to POSIX path of ((path to me as text) & "::")
	set objectPath to unixPath & "objects/"
	
	set a to load_script("objects:list_fromFile.scpt")
	set b to objectPath & "_alphabet.txt"
	set c to unixPath & "_base-keywords.txt"
	set d to load_script("objects:do_etsyInput.scpt")
	set e to load_script("objects:routine_makeList.scpt")
	set f to load_script("objects:list_insert.scpt")
	set g to load_script("objects:load_GUI.scpt")
	set h to load_script("objects:file_write.scpt")
	
	tell a
		set theList to makeListFromFile(b)
		set theList2 to makeListFromFile(c)
	end tell
	
	set theResultsList to {}
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		set AppleScript's text item delimiters to newLine
		set text item delimiters to newLine
		
		repeat with a from 1 to length of theList2
			set AppleScript's text item delimiters to newLine
			set text item delimiters to newLine
			
			set theCurrentListItem2 to item a of theList2
			set theQuery to (theCurrentListItem2 & " " & theCurrentListItem)
			
			tell g
				tell d to inputEvent(theQuery)
				delay 2
			end tell
			
			tell e to set theItem to makeList(-1, newLine, 4, false) as text
			tell h to writeFile(theCurrentListItem & newLine & theItem & newLine, false, "longtail results", "txt")
		end repeat
	end repeat
end getLongtails 

########################################

#processBaseKeywordsFile(2)
getLongtails()

#set makeListScript to load_script("objects:routine_makeList.scpt")
#tell makeListScript to makeList(-1, newLine, 4, false)


