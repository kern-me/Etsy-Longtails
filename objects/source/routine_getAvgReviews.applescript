
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