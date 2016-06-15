(*
	This script takes the currently selected actions or projects and sets them for action this weekend.

	This is written by Dan Byler (http://bylr.net/), I just carved what is useful for me		
*)

-- To change your weekend start/stop date/time, modify the following properties
property setDueDate : false --set to False if you don't want to change the due date
property weEndDay : Sunday
property weEndTime : 17 --due time in hours (24 hr clock)
property weStartDay : Saturday
property weStartTime : 8 --due time in hrs (24 hr clock)

on main()
	tell application "OmniFocus"
		tell content of first document window of front document
			--Get selection
			set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
			set totalItems to count of validSelectedItemsList
			if totalItems is 0 then
				return
			end if
			
			--Calculate due date
			set dueDate to current date
			set theTime to time of dueDate
			repeat while weekday of dueDate is not weEndDay
				set dueDate to dueDate + 1 * days
			end repeat
			set dueDate to dueDate - theTime + weEndTime * hours
			
			--Calculate start date
			set diff to weEndDay - weStartDay
			if diff < 0 then set diff to diff + 7
			set diff to diff * days + (weEndTime - weStartTime) * hours
			set startDate to dueDate - diff
			
			--Perform action
			set successTot to 0
			set autosave to false
			repeat with thisItem in validSelectedItemsList
				set succeeded to my setDate(thisItem, startDate)
				if succeeded then set successTot to successTot + 1
			end repeat
			set autosave to true
		end tell
	end tell
end main

on setDate(selectedItem, startDate)
	set success to false
	tell application "OmniFocus"
		try
			set defer date of selectedItem to startDate
			set success to true
		end try
	end tell
	return success
end setDate

main()
