(*
	This script takes the currently selected actions or projects and sets them for action tomorrow.

	This is written by Dan Byler (http://bylr.net/), I just carved what is useful for me
*)
property startTime : 7 --Start hour for items not previously assigned a start time (24 hr clock)

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
			repeat with thisItem in validSelectedItemsList
				set succeeded to my setToMinusOne(thisItem)
				if succeeded then set successTot to successTot + 1
			end repeat
			set autosave to true
		end tell
	end tell
end main

on setToMinusOne(selectedItem)
	set success to false
	tell application "OmniFocus"
		try
			set originalStartDateTime to defer date of selectedItem
			if (originalStartDateTime is not missing value) then
				--Set new start date with original start time
				set newDate to (originalStartDateTime) - (time of (originalStartDateTime)) - 86400
				set defer date of selectedItem to (newDate + (time of originalStartDateTime))
				set success to true
			else
				set newDate to (current date) - (time of (current date)) - 86400
				set defer date of selectedItem to (newDate + (startTime * hours))
				set success to true
			end if
		end try
	end tell
	return success
end setToMinusOne

main()
