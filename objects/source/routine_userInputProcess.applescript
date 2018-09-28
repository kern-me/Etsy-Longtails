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