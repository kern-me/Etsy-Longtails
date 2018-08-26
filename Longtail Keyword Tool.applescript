on enabledGUIScripting(flag)
	considering numeric strings
		set MountainLionOrOlder to system version of (system info) < "10.9"
	end considering
	if MountainLionOrOlder then
		
		-- In OS X Mountain Lion 10.8 or earlier, enable GUI Scripting globally by calling this handler and passing 'true' in the flag parameter before your script executes any GUI Scripting commands, or pass 'false' to disable GUI Scripting. Authentication is required only if the value of the 'UI elements enabled' property will be changed. Returns the final setting of 'UI elements enabled' even if unchanged.
		
		tell application "System Events"
			activate -- brings System Events authentication dialog to front
			set UI elements enabled to flag
			return UI elements enabled
		end tell
	else
		
		-- In OS X Mavericks 10.9 or later, global access is no longer available and GUI Scripting can only be enabled manually on a per-application basis. Pass true to present an alert with a button to open System Preferences and telling the user to select the current application (the application running the script) in the Accessibility list in the Security & Privacy preference's Privacy pane. Authentication is required to unlock the preference. Returns the current setting of 'UI elements enabled' asynchronously, without waiting for System Preferences to open, and tells the user to run the script again.
		
		tell application "System Events" to set GUIScriptingEnabled to UI elements enabled -- read-only in OS X Mavericks 10.9 or later
		if flag is true then
			if not GUIScriptingEnabled then
				activate
				set scriptRunner to name of current application
				display alert "GUI Scripting is not enabled for " & scriptRunner & "." message "Open System Preferences, unlock the Security & Privacy preference, select " & scriptRunner & " in the Privacy Pane's Accessibility list, and then run this script again." buttons {"Open System Preferences", "Cancel"} default button "Cancel"
				if button returned of result is "Open System Preferences" then
					tell application "System Preferences"
						tell pane id "com.apple.preference.security" to reveal anchor "Privacy_Accessibility"
						activate
					end tell
				end if
			end if
		end if
		return GUIScriptingEnabled
	end if
end enabledGUIScripting


#############################################
# HANDLER

-- Reading and Writing Params
on writeTextToFile(theText, theFile, overwriteExistingContent)
	try
		set theFile to theFile as string
		set theOpenedFile to open for access file theFile with write permission
		
		if overwriteExistingContent is true then set eof of theOpenedFile to 0
		write theText to theOpenedFile starting at eof
		close access theOpenedFile
		
		return true
	on error
		try
			close access file theFile
		end try
		
		return false
	end try
end writeTextToFile

property newLine : "
"

#############################################
# HANDLER

-- Write to file

on writeFile(theContent, writable)
	set now to current date
	set mo to (month of now as string)
	set addDaytoYear to (year of now) * 100 + (day of now) as string
	set d to text -2 thru -1 of addDaytoYear
	set e to text 1 thru 3 of mo
	set f to text -6 thru -3 of addDaytoYear
	set this_Story to theContent
	set theFile to (((path to desktop folder) as string) & "results.txt")
	writeTextToFile(this_Story, theFile, writable)
end writeFile


property file_baseKeywords : "/Users/nicokillips/Desktop/base-keywords.txt"
property file_results : "/Users/nicokillips/Desktop/results.txt"
property file_alphabet : "/Users/nicokillips/Desktop/alphabet.txt"

#############################################
# HANDLER

-- Make a list from an existing file

on makeListFromFile(theFile)
	set theList to {}
	set theLines to paragraphs of (read POSIX file theFile)
	repeat with nextLine in theLines
		if length of nextLine is greater than 0 then
			copy nextLine to the end of theList
		end if
	end repeat
	return theList
end makeListFromFile

#############################################
# HANDLER

-- Get data from the DOM

on getFromDOM(instance)
	tell application "Safari"
		do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
	end tell
end getFromDOM

#############################################
# HANDLER

-- Simulates user interaction to evoke Etsy's population of related words

on inputEvent(keyword)
	tell application "Safari"
		activate
		tell application "System Events"
			tell process "Safari"
				# Click the input
				click text field 1 of group 1 of group 1 of group 1 of group 2 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1
				
				# Set the value of the input
				set value of text field 1 of group 1 of group 1 of group 1 of group 2 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1 to keyword
				
				delay 1
				
				(*
				select text field 1 of group 1 of group 1 of group 1 of group 2 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1
				
				delay 1
				
				perform action "AXPress" of text field 1 of group 1 of group 1 of group 1 of group 2 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1 *)
				
				# Adds space which initiates the results
				key code 49
				delay 1
				
				key code 51
				delay 1
			end tell
		end tell
	end tell
end inputEvent


#############################################
# ROUTINE

-- Loop through the results in the DOM
-- Write the results line by line to results file

on savePopulatedWords()
	set theCount to -1
	set theData to ""
	
	repeat
		try
			set updatedCount to (theCount + 1)
			set theData to getFromDOM(updatedCount)
			set theCount to theCount + 1
			writeFile(theData & newLine, false) as text
		on error
			set theCount to -1 #reset
			exit repeat
		end try
	end repeat
	return
end savePopulatedWords



###############################################
# ROUTINE

-- Makes a list
-- Loops through alphabet file
-- Initiates user click
-- Inserts letter
-- Grabs results
-- Saves to file

on loopAlphabet()
	set theList to makeListFromFile(file_alphabet)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		inputEvent(theCurrentListItem)
		delay 2
		saveAutoPopulatedWords()
	end repeat
end loopAlphabet



###############################################
# ROUTINE

-- Makes a list from the existing base keywords file
-- Initiates Etsy's search bar populated related keywords for each line of the list
-- Writes the results to "results" file

on processBaseKeywordsFile()
	set theList to makeListFromFile(file_baseKeywords)
	set theList2 to makeListFromFile(file_alphabet)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		
		repeat with a from 1 to length of theList2
			set theCurrentListItem2 to item a of theList2
			
			set theQuery to (theCurrentListItem & " " & theCurrentListItem2)
			
			inputEvent(theCurrentListItem & " " & theCurrentListItem2)
			
			delay 2
			
			savePopulatedWords()
		end repeat
	end repeat
end processBaseKeywordsFile

###############################################
###############################################

-- Handler Tests

#savePopulatedWords()
#inputEvent("chrono trigger")
#loopAlphabet()




-- Main Routine
processBaseKeywordsFile()

