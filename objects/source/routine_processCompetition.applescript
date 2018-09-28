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

---------------------------------------------
-- Find Listing with the Most Reviews
---------------------------------------------
on findMVPListing()
	set highestNumberList to makeList(0, ",", 2, true)
	
	set theResult to highest_number(highestNumberList)
	
	return theResult
end findMVPListing

findMVPListing()
