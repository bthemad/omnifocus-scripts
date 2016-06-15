(*
	This script takes the currently selected actions or projects and sets them for action today.

	This is written by Dan Byler (http://bylr.net/), I just carved what is useful for me
*)

-- To change settings, modify the following properties

property startTime : 18 --Start hour for items not previously assigned a start time (24 hr clock)


-- Don't change these
on main()
	tell application "OmniFocus"
		tell content of first document window of front document
			--Get selection
			set totalMinutes to 0
			set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
			set totalItems to count of validSelectedItemsList
			if totalItems is 0 then
				return
			end if

			--Perform action
			set successTot to 0
			set autosave to false
			set currDate to (current date) - (time of (current date))
			repeat with thisItem in validSelectedItemsList
				set succeeded to my startToday(thisItem, currDate)
				if succeeded then set successTot to successTot + 1
			end repeat
			set autosave to true
		end tell
	end tell
end main

on startToday(selectedItem, currDate)
	set success to false
	tell application "OmniFocus"
		try
			set originalStartDateTime to defer date of selectedItem
			if (originalStartDateTime is not missing value) then
				set todayDate to (currDate + (time of originalStartDateTime))
				if originalStartDateTime is todayDate then
					set defer date of selectedItem to missing value
				else
					set defer date of selectedItem to (currDate + (startTime * hours))
				end if
				set success to true
			else
				set defer date of selectedItem to (currDate + (startTime * hours))
				set success to true
			end if
		end try
	end tell
	return success
end startToday

main()
