#############################################
# GLOBAL HANDLERS
#############################################

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

---------------------------------------------
-- Wait for the Page Load
---------------------------------------------
on waitForPageLoad()
	tell application "Safari"
		local tids, theList, theText
		set {tids, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "</html>"}
		tell application "Safari" to set theText to source of its document 1
		set theList to text items of theText
		set AppleScript's text item delimiters to tids
		if length of theList = 1 then return false
		return true
	end tell
end waitForPageLoad

##########################################################################################
# FILE HANDLERS
##########################################################################################

---------------------------------------------
-- Reading and Writing Params
---------------------------------------------
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

---------------------------------------------
-- Write to file
---------------------------------------------
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

##########################################################################################
# PROPERTIES
##########################################################################################

property searchBar : "text field 1 of group 1 of group 1 of group 1 of group 2 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1"
property file_baseKeywords : "" & (path to desktop folder) & "base-keywords.txt"
property file_results : "/Users/nicokillips/Desktop/results.txt"
property file_alphabet : "/Users/nicokillips/Desktop/alphabet.txt"
property file_relatedTags : "/Users/nicokillips/Desktop/related-tags.txt"
property file_searchbar_longtail_tags : "/Users/nicokillips/Desktop/search-bar-longtails.txt"

property newLine : "
"

##########################################################################################
# LIST HANDLERS
##########################################################################################

---------------------------------------------
-- Insert Item into a List
---------------------------------------------
on insertItemInList(theItem, theList, thePosition)
	set theListCount to length of theList
	if thePosition is 0 then
		return false
	else if thePosition is less than 0 then
		if (thePosition * -1) is greater than theListCount + 1 then return false
	else
		if thePosition is greater than theListCount + 1 then return false
	end if
	if thePosition is less than 0 then
		if (thePosition * -1) is theListCount + 1 then
			set beginning of theList to theItem
		else
			set theList to reverse of theList
			set thePosition to (thePosition * -1)
			if thePosition is 1 then
				set beginning of theList to theItem
			else if thePosition is (theListCount + 1) then
				set end of theList to theItem
			else
				set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
			end if
			set theList to reverse of theList
		end if
	else
		if thePosition is 1 then
			set beginning of theList to theItem
		else if thePosition is (theListCount + 1) then
			set end of theList to theItem
		else
			set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
		end if
	end if
	return theList
end insertItemInList

---------------------------------------------
-- Make a list from an existing file
---------------------------------------------
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


##########################################################################################
# SEARCH BUTTON / INTERACTIONS HANDLERS
##########################################################################################
property searchInputDOMPath : "#gnav-search input#search-query"

---------------------------------------------
-- Click the search button
---------------------------------------------
on activateSearchButton()
	set searchButtonPath to "#gnav-search > div > div.search-button-wrapper.hide > button"
	tell application "Safari"
		do JavaScript "document.querySelector('" & searchButtonPath & "').click();" in document 1
	end tell
end activateSearchButton

---------------------------------------------
-- Set the Input
---------------------------------------------
on setInput(theValue)
	tell application "Safari"
		set inputPath to do JavaScript "document.querySelector('" & searchInputDOMPath & "').value = ('" & theValue & "');" in document 1
	end tell
end setInput

---------------------------------------------
-- Evoke Etsy's population of suggested tags
---------------------------------------------
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
# DOM HANDLERS
#############################################

---------------------------------------------
-- Get suggested keyword results from DOM
---------------------------------------------
on getFromDOM(instance)
	tell application "Safari"
		do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
	end tell
end getFromDOM


---------------------------------------------
-- Get Number of Total Listings for a Tag
---------------------------------------------
on getResultsCountFromDOM()
	set thePath to "#content > div > div.content.bg-white.col-md-12.pl-xs-1.pr-xs-0.pr-md-1.pl-lg-0.pr-lg-0.bb-xs-1 > div > div > div.col-group.pl-xs-0.search-listings-group > div:nth-child(2) > div:nth-child(1) > div.float-left > div > span:nth-child(6)"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelector('" & thePath & "').innerText.replace(',','').replace('(','').replace(')','').replace(' Results','')" in document 1
			return theResult as number
		on error
			return false
		end try
	end tell
end getResultsCountFromDOM


---------------------------------------------
-- Suggested Tag results from DOM
---------------------------------------------
on getSuggestedTags(instance)
	tell application "Safari"
		try
			set theData to do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
			return theData
		on error
			return false
		end try
	end tell
end getSuggestedTags


#############################################
# LOOP ROUTINES
#############################################

---------------------------------------------
-- Save the suggested words
---------------------------------------------
on saveSuggestedTags()
	set theCount to -1
	set theData to ""
	
	repeat
		set updatedCount to (theCount + 1)
		set theData to getSuggestedTags(updatedCount)
		
		if theData is false then
			exit repeat
		end if
		
		set theCount to theCount + 1
		
		writeFile(theData & newLine, false) as text
	end repeat
	return
end saveSuggestedTags

---------------------------------------------
-- Save Reviews
---------------------------------------------
on getReview(instance)
	set thePath to ".stars-svg + span"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelectorAll('" & thePath & "')[" & instance & "].innerText.replace(',','').replace('(','').replace(')','')" in document 1
			
			(*
			set s to quoted form of theResult
			do shell script "sed s/[a-zA-Z\\']//g <<< " & s
			set dx to the result
			set numlist to {}
			repeat with i from 1 to count of words in dx
				set this_item to word i of dx
				try
					set this_item to this_item as number
					set the end of numlist to this_item
				end try
			end repeat
			
			return numlist
			*)
			return theResult
		on error
			return -1
		end try
	end tell
end getReview

---------------------------------------------
-- Loop over Review Values
---------------------------------------------
property reviewCount : 0

on saveReviews()
	set theCount to -1
	set nodeCounter to 0
	set theData to ""
	
	repeat
		set updatedCount to (theCount + 1)
		log updatedCount
		
		set theData to getReview(updatedCount)
		
		
		log getReview(updatedCount)
		
		if theData is -1 then
			exit repeat
		end if
		
		set theCount to theCount + 1
		set nodeCounter to nodeCounter + 1
		log nodeCounter
		
		set reviewCount to (theData + reviewCount)
		log ("add theData to reviewCount property")
		log reviewCount
		
	end repeat
	set avgReviews to reviewCount / nodeCounter
	set avgReviews to avgReviews as text
	#set reviewCount to reviewCount as text
	#set nodeCounter to nodeCounter as text
	
	writeFile(avgReviews & newLine, false)
	set reviewCount to 0
	return
end saveReviews


---------------------------------------------
-- Loop the Alphabet file
---------------------------------------------
on loopAlphabet()
	set theList to makeListFromFile(file_alphabet)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		inputEvent(theCurrentListItem)
		delay 2
		saveSuggestedTags()
	end repeat
end loopAlphabet


---------------------------------------------
-- Process the Base Keywords
---------------------------------------------
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
			
			saveSuggestedTags()
		end repeat
	end repeat
end processBaseKeywordsFile


---------------------------------------------
-- Find Number of Listings
---------------------------------------------
on findNumberofListings()
	set theList to makeListFromFile(file_searchbar_longtail_tags)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		
		setInput(theCurrentListItem)
		delay 1
		activateSearchButton()
		delay 1
		waitForPageLoad()
		
		set theResults to getResultsCountFromDOM()
		
		if theResults is false then
			writeFile(theCurrentListItem & "," & "no result" & newLine, false) as text
		end if
		
		writeFile(theCurrentListItem & "," & theResults & newLine, false) as text
	end repeat
end findNumberofListings


-- Main Routine
#processBaseKeywordsFile()
#findNumberofListings()
#getReview(10)
saveReviews()



