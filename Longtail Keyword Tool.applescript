###################
# PROPERTIES
###################
# Delays
property theDelay : 1

# Formatting
property newLine : "
"

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

(*on load_file(fileName)
	tell application "Finder"
		set posixPath to POSIX path of ((path to me as text) & "::")
		set fullPath to (posixPath & fileName) as string
		log fullPath
		return fullPath as alias
	end tell
end load_file*)

##############################
# ROUTINES
##############################
on processBaseKeywordsFile()
	set a to load_script("objects:list_fromFile.scpt")
	set b to "/Users/nicokillips/dev/Etsy Products/Longtail Keyword Tool/objects/_alphabet.txt"
	set c to "/Users/nicokillips/dev/Etsy Products/Longtail Keyword Tool/_base-keywords.txt"
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
	return theResultsList as text
end processBaseKeywordsFile

processBaseKeywordsFile()


