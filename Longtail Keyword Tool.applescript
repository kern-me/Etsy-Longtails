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
property theDelay : 1

on waitForPageLoad(var)
	set doJS to "document.querySelector('.search-listings-group h1').innerText;"
	
	tell application "Safari"
		repeat until do JavaScript doJS as text is var
		end repeat
		delay theDelay
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
	log "---------------------------------"
	log "activateSearchButton()"
	log "---------------------------------"
	
	set searchButtonPath to "#gnav-search > div > div.search-button-wrapper.hide > button"
	
	tell application "Safari"
		do JavaScript "document.querySelector('" & searchButtonPath & "').click();" in document 1
	end tell
end activateSearchButton

---------------------------------------------
-- Set the Input
---------------------------------------------
on setInput(theValue)
	log "---------------------------------"
	log "setInput(" & theValue & ")"
	log "---------------------------------"
	
	tell application "Safari"
		set inputPath to do JavaScript "document.querySelector('" & searchInputDOMPath & "').value = ('" & theValue & "');" in document 1
	end tell
end setInput


on getInput()
	log "---------------------------------"
	log "getInput()"
	log "---------------------------------"
	
	set thePath to ".ss-navigateright + span + h1"
	
	tell application "Safari"
		set inputPath to do JavaScript "document.querySelector('" & thePath & "').innerText.replace(',','').replace('(','').replace(')','')" in document 1
	end tell
end getInput


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
	log "---------------------------------"
	log "getFromDOM(" & instance & ")"
	log "---------------------------------"
	
	tell application "Safari"
		do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
	end tell
end getFromDOM


---------------------------------------------
-- Suggested Tag results from DOM
---------------------------------------------
on getSuggestedTags(instance)
	log "---------------------------------"
	log "getSuggestedTags(" & instance & ")"
	log "---------------------------------"
	tell application "Safari"
		try
			set theData to do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
			return theData
		on error
			set theData to false
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
	log "================================="
	log "saveSuggestedTags()"
	log "================================="
	
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
-- Get Seller Review value from the DOM
---------------------------------------------
on getSellerReviewsValue(instance)
	set thePath to ".stars-svg + span"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelectorAll('" & thePath & "')[" & instance & "].innerText.replace(/,/g,'').replace('(','').replace(')','')" in document 1
			
			return theResult
			log "return " & theResult & ""
			
			
		on error
			log ("END of LOOP")
			delay 1
			return -1
		end try
	end tell
end getSellerReviewsValue

---------------------------------------------
-- Sum of Seller Reviews
---------------------------------------------
on getTotalSellerReviews()
	set theCount to -1
	set theData to 0
	
	repeat
		set updatedCount to (theCount + 1)
		set loopChecker to getSellerReviewsValue(updatedCount)
		
		if loopChecker is -1 then
			log "Return"
			log theData
			
			return theData
			exit repeat
		end if
		
		set updatedReviewsCount to (theData + getSellerReviewsValue(updatedCount))
		set theData to updatedReviewsCount
		set theCount to (theCount + 1)
		
		delay 0.15
	end repeat
end getTotalSellerReviews


---------------------------------------------
-- Count the Number of First Page Listings
---------------------------------------------
on countFirstPageListingResults()
	log "---------------------------------"
	log "countFirstPageListingResults()"
	log "---------------------------------"
	
	set thePath to ".stars-svg + span"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelectorAll('" & thePath & "').length" in document 1
			return theResult
		on error
			delay 1
			return "No Results Found."
		end try
	end tell
end countFirstPageListingResults


---------------------------------------------
-- ROUTINE : Get Average Number of Reviews
---------------------------------------------

on getAvgReviews()
	log "================================="
	log "getAvgReviews()"
	log "================================="
	
	
	set totalReviews to getTotalSellerReviews()
	set totalListings to countFirstPageListingResults()
	
	set avgReviews to (totalReviews / totalListings)
	log "" & totalReviews & " / " & totalListings & " = " & avgReviews & ""
	
	set avgReviews to round avgReviews as text
	log avgReviews
	
	return avgReviews
end getAvgReviews


---------------------------------------------
-- Loop the Alphabet file
---------------------------------------------
on loopAlphabet()
	log "================================="
	log "loopAlphabet()"
	log "================================="
	
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
	log "================================="
	log "processBaseKeywordsFile()"
	log "================================="
	
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
-- Get Number of Total Listings for a Tag
---------------------------------------------
on getTotalListings()
	log "---------------------------------"
	log "getTotalListings()"
	log "---------------------------------"
	
	set thePath to ".ss-navigateright + span + h1 + span + span"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelector('" & thePath & "').innerText.replace(/,/g,'').replace('(','').replace(')','').replace(' Result','').replace('s','')" in document 1
			log ("Do JS to get result.")
			
			delay 1
			
			set theValue to round theResult
			log ("Round the result: " & theResult & "")
			
			return theValue
			log ("Return theResult")
			
			error
			
			delay 1
			
			return false
			log ("Return false")
		end try
	end tell
end getTotalListings


---------------------------------------------
-- Process Competition and Reputation
---------------------------------------------
on processCompetitionAndReputation()
	set theList to makeListFromFile(file_searchbar_longtail_tags)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		
		setInput(theCurrentListItem)
		delay 1
		
		activateSearchButton()
		delay 1
		
		waitForPageLoad(theCurrentListItem)
		delay 2
		
		set totalListings to getTotalListings() as text
		delay 1
		
		set avgReviews to getAvgReviews()
		delay 1
		
		writeFile(theCurrentListItem & "," & totalListings & "," & avgReviews & "," & newLine, false) as text
	end repeat
end processCompetitionAndReputation


---------------------------------------------
-- Process one listing
---------------------------------------------
on processOneListing()
	set tagName to getInput()
	set resultsCount to getTotalListings()
	set avgReviewsCount to getAvgReviews()
	
	if resultsCount is false then
		set resultsCount to "No Results"
	end if
	
	writeFile(tagName & "," & resultsCount & "," & avgReviewsCount & "," & newLine, false) as text
end processOneListing

---------------------------------------------
-- Main Routine
---------------------------------------------

#findNumberofListings()
#getSellerReviewsValue(10)
#saveReviews()
#processOneListing()
#getAvgReviews()

#processBaseKeywordsFile()
processCompetitionAndReputation()
#countFirstPageListingResults()
#getTotalSellerReviews()




