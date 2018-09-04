##########################################################################################
# PROPERTIES
##########################################################################################

# DOM
property searchBar : "text field 1 of group 1 of group 1 of group 1 of group 2 of UI element 1 of scroll area 1 of group 1 of group 1 of tab group 1 of splitter group 1 of window 1"

# File Paths
property file_baseKeywords : "" & (path to desktop folder) & "base-keywords.txt"
property file_results : "/Users/nicokillips/Desktop/results.txt"
property file_alphabet : "/Users/nicokillips/Desktop/alphabet.txt"
property file_relatedTags : "/Users/nicokillips/Desktop/related-tags.txt"
property file_searchbar_longtail_tags : "/Users/nicokillips/Desktop/search-bar-longtails.txt"

# Delays
property theDelay : 1

# Formatting
property newLine : "
"

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


##########################################################################################
# WAIT FOR PAGE LOAD
##########################################################################################
---------------------------------------------
-- Wait for the Page Load
---------------------------------------------
on waitForPageLoad(var)
	set doJS to "document.querySelector('.search-listings-group h1').innerText;"
	
	tell application "Safari"
		repeat until do JavaScript doJS as text is var
		end repeat
		delay 2
	end tell
end waitForPageLoad


##########################################################################################
# FILE HANDLERS
##########################################################################################
---------------------------------------------
-- Reading and Writing Params
---------------------------------------------
on highest_number(values_list)
	set the high_amount to ""
	repeat with i from 1 to the count of the values_list
		set this_item to item i of the values_list
		set the item_class to the class of this_item
		if the item_class is in {integer, real} then
			if the high_amount is "" then
				set the high_amount to this_item
			else if this_item is greater than the high_amount then
				set the high_amount to item i of the values_list
			end if
		else if the item_class is list then
			set the high_value to highest_number(this_item)
			if the the high_value is greater than the high_amount then Â
				set the high_amount to the high_value
		end if
	end repeat
	return the high_amount
end highest_number

---------------------------------------------
-- Write to file
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
# LIST HANDLERS / ROUTINES
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
---------------------------------------------
-- ACTIVATE the Search Button
---------------------------------------------
on activateSearchButton()
	set thePath to "#gnav-search > div > div.search-button-wrapper.hide > button"
	
	tell application "Safari"
		do JavaScript "document.querySelector('" & thePath & "').click();" in document 1
	end tell
end activateSearchButton

---------------------------------------------
-- SET the Input Value
---------------------------------------------
on setInput(theValue)
	set thePath to "#gnav-search input#search-query"
	
	tell application "Safari"
		set inputPath to do JavaScript "document.querySelector('" & thePath & "').value = ('" & theValue & "');" in document 1
	end tell
end setInput

---------------------------------------------
-- GET the Input Value
---------------------------------------------
on getInput()
	set thePath to ".ss-navigateright + span + h1"
	
	tell application "Safari"
		set inputPath to do JavaScript "document.querySelector('" & thePath & "').innerText.replace(',','').replace('(','').replace(')','')" in document 1
	end tell
end getInput


---------------------------------------------
-- ACTIVATE Etsy Suggested Results
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


##########################################################################################
# DOM HANDLERS
##########################################################################################
---------------------------------------------
-- Get suggested tag results from DOM
---------------------------------------------
on getFromDOM(instance)
	tell application "Safari"
		do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
	end tell
end getFromDOM


---------------------------------------------
-- Suggested tag results from DOM
---------------------------------------------
on getSuggestedTags(instance)
	tell application "Safari"
		try
			set theData to do JavaScript "document.getElementsByClassName('as-suggestion')['" & instance & "'].innerText;" in document 1
			
			return theData
			
		on error
			set theData to false
		end try
	end tell
end getSuggestedTags


---------------------------------------------
-- Get Seller Review value from the DOM
---------------------------------------------
on getSellerReviewsValue(instance)
	set thePath to ".stars-svg + span"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelectorAll('" & thePath & "')[" & instance & "].innerText.replace(/,/g,'').replace('(','').replace(')','')" in document 1
			
			return theResult
		on error
			return false
		end try
	end tell
end getSellerReviewsValue


---------------------------------------------
-- Count the Number of First Page Listings
---------------------------------------------
on countFirstPageListingResults()
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
-- Get Number of Total Listings for a Tag
---------------------------------------------
on getTotalListings()
	set thePath to ".ss-navigateright + span + h1 + span + span"
	
	tell application "Safari"
		try
			set theResult to do JavaScript "document.querySelector('" & thePath & "').innerText.replace(/,/g,'').replace('(','').replace(')','').replace(' Result','').replace('s','')" in document 1
			
			set theValue to round theResult
			
			return theValue
			
		on error
			return false
		end try
	end tell
end getTotalListings





##########################################################################################
# USER PROMPT / FILE SELECTION
##########################################################################################
---------------------------------------------
-- User Keyword Prompt
---------------------------------------------
on userInput()
	set theKeyword to display dialog "Enter a keyword" default answer ""
	set keyword to text returned of theKeyword as text
	set firstKeyword to keyword
	return keyword as text
end userInput


---------------------------------------------
-- User Keyword Prompt 2 Buttons
---------------------------------------------
on userPrompt2Buttons(theText, buttonText1, buttonText2)
	activate
	display dialog theText buttons {buttonText1, buttonText2} default button buttonText2
	if button returned of result = buttonText1 then
		return false
	else if button returned of result = buttonText2 then
		return true
	end if
end userPrompt2Buttons


---------------------------------------------
-- User Input List
---------------------------------------------
on getDataFromUserInput()
	set theList to {}
	
	repeat
		set theTag to setInput(userInput())
		insertItemInList(theTag, theList, 1)
		set userResponse to userPrompt2Buttons("Add another tag?", "No", "Yes")
		
		if userResponse is false then
			exit repeat
		end if
		
		set theList to reverse of theList
	end repeat
	
	set progress description to ""
	set theListCount to length of theList
	set progress total steps to theListCount
	set progress completed steps to 0
	set progress description to ""
	
	repeat with a from 1 to the count of theList
		set currentItem to item a of theList
		set progress description to "Getting tag data for " & currentItem & " / " & a & " of " & theListCount & ""
		
		setInput(currentItem) as text
		set currentKeyword to currentItem as text
		
		activateSearchButton()
		waitForPageLoad(currentItem)
		
		set totalListings to getTotalListings() as text
		set avgReviews to getAvgReviews()
		
		if avgReviews is false then
			set avgReviews to "No Results Found."
		end if
		
		writeFile("Tag,Total Listings,Average Reviews, " & newLine & "", false) as text
		writeFile(currentItem & "," & totalListings & "," & avgReviews & "," & newLine, false) as text
		
		set progress completed steps to a
		delay 1
	end repeat
	
	-- Progress Reset
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end getDataFromUserInput


##########################################################################################
# LOOP ROUTINES
##########################################################################################
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
-- Sum of Seller Reviews
---------------------------------------------
on getTotalSellerReviews()
	set theCount to -1
	set theData to 0
	
	repeat
		set updatedCount to (theCount + 1)
		set loopChecker to getSellerReviewsValue(updatedCount)
		
		if loopChecker is -1 then
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
-- Get Average Number of Reviews
---------------------------------------------
on getAvgReviews()
	set totalReviews to getTotalSellerReviews()
	set totalListings to countFirstPageListingResults()
	
	if totalListings is 0 then
		return false
	end if
	
	set avgReviews to (totalReviews / totalListings)
	set avgReviews to round avgReviews as text
	
	return avgReviews
end getAvgReviews


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


##########################################################################################
# PRIMARY ROUTINES
##########################################################################################
---------------------------------------------
-- Process the Base Keywords
---------------------------------------------
on processBaseKeywordsFile()
	set theList to makeListFromFile(file_baseKeywords)
	set theList2 to makeListFromFile(file_alphabet)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		
		repeat with a from 1 to length of theList2
			set theCurrentListItem2 to item a of theList2
			set theQuery to (theCurrentListItem & " " & theCurrentListItem2)
			
			inputEvent(theCurrentListItem & " " & theCurrentListItem2)
			
			saveSuggestedTags()
		end repeat
	end repeat
end processBaseKeywordsFile

---------------------------------------------
-- Process Competition and Avg Reviews
-- (Active in Browser)
---------------------------------------------
on processOneListing()
	set tagName to getInput()
	set totalListings to getTotalListings() as text
	set avgReviews to getAvgReviews()
	
	if avgReviews is false then
		set avgReviews to "No Results Found."
	end if
	
	writeFile(tagName & "," & totalListings & "," & avgReviews & "," & newLine, false) as text
end processOneListing

---------------------------------------------
-- Process Competition and Avg Reviews
---------------------------------------------
on processCompetitionAndReputation()
	set theList to makeListFromFile(file_searchbar_longtail_tags)
	
	repeat with a from 1 to length of theList
		set theCurrentListItem to item a of theList
		
		setInput(theCurrentListItem)
		activateSearchButton()
		waitForPageLoad(theCurrentListItem)
		
		set totalListings to getTotalListings() as text
		set avgReviews to getAvgReviews()
		
		if avgReviews is false then
			set avgReviews to "No Results Found."
		end if
		
		writeFile(theCurrentListItem & "," & totalListings & "," & avgReviews & "," & newLine, false) as text
	end repeat
end processCompetitionAndReputation

##########################################################################################
# GET SHOP NAME
##########################################################################################

---------------------------------------------
-- Get Shop Name from the DOM
---------------------------------------------
on getShopName(instance)
	tell application "Safari"
		try
			set theResult to do JavaScript "document.getElementsByClassName('v2-listing-card__shop')[" & instance & "].querySelector('p').innerText" in document 1
			return theResult
		on error
			log "Not found in the DOM"
			return false
		end try
	end tell
end getShopName

---------------------------------------------
-- Insert item into list template
---------------------------------------------

on makeList(theCountValue, delimiter, handlerType)
	# Make the empty/container list
	set theList to {}
	set AppleScript's text item delimiters to "" & delimiter & ""
	set text item delimiters to delimiter
	set theCount to theCountValue
	set updatedCount to ""
	
	if handlerType is 1 then
		set handlerFlag to 1
	else if handlerType is 2 then
		set handlerFlag to 2
	else if handlerType is 3 then
		set handlerFlag to 3
	end if
	
	
	# Iterate over items
	repeat
		set updatedCount to (theCount + 1)
		
		if handlerFlag is 1 then
			set theData to getShopName(updatedCount)
			if theData is false then
				exit repeat
			end if
			insertItemInList(theData, theList, 1)
		else if handlerFlag is 2 then
			set theData to getSellerReviewsValue(updatedCount)
			if theData is false then
				exit repeat
			end if
			insertItemInList(theData, theList, 1)
		else if handlerFlag is 3 then
			set theData to getShopName(updatedCount)
			set theData2 to getSellerReviewsValue(updatedCount)
			if theData is false then
				exit repeat
			end if
			if theData2 is false then
				set theData2 to "No Reviews"
			end if
			insertItemInList(theData & ", " & theData2, theList, 1)
		end if

		set theCount to theCount + 1
	end repeat
	
	return the reverse of theList
end makeList

makeList(0, ",", 3)
---------------------------------------------
-- Find Listing with the Most Reviews
---------------------------------------------
on findMVPListing()
	#makeList(
end findMVPListing



##########################################################################################
## HANDLER CALLS
##########################################################################################
#processCompetitionAndReputation()
#processOneListing()
#getDataFromUserInput()



