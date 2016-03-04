(*
	This script marks the selected actions as complete and creates new actions in a "Waiting For" context to track replies.
	Modified a bit by Alexander Kudryashov in order to select just created task and set a deffer date to tomorrow.
	
	by Curt Clifton
	
	Copyright © 2007-2008, 2012, 2014, 2016 Curtis Clifton
	
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	
		• Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
		
		• Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
		
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
	version 1.0.2: Fixed to not lose links in note of item
	version 1.0.1: Fixed to work with Mac App Store version of OmniFocus 2 Pro
	version 1.0: Lots of improvements:
		• Updated for OmniFocus 2. 
		• Uses Notification Center instead of Growl. 
		• Handles a Waiting context that is a sub-context, instead of just top-level contexts. 
		• Added a property to allow adjusting due date of created task, but made the default be no due date.
		• Adds an paragraph to the new action’s note indicating when the “waiting for” task was created.
		• If the selected task is already a “waiting for” task, the new task won’t have the “Reply on:” prefix added twice, but it will get another paragraph indicating when the follow-up was sent.
	version 0.2: Removed Growl support
	version 0.1: Original release
*)

(*
	This string is matched against your contexts to find a context in which to place the new "waiting-for" action.  The matching is the same as in the context column in OmniFocus, so you don't need the entire contexxt name, just a unique fragment.
*)
property waitingForContext : "Waiting"

(*
	This string is used as a prefix on the original item title when creating the "waiting-for" action.
*)
property waitingPrefix : "Follow up on: "

(*
	This string is used as a prefix for a paragraph added to the new item’s note that indicates when the original action was completed.
*)
property notePrefix : "Completed on: "

(* 
	This string is used in notifications if multiple items are processed. For single items, we use the actual item title. 
*)
property multipleItemsCompleted : "Multiple Items"

property startTime : 7

set itemTitle to missing value
tell application "OmniFocus"
	tell front document
		-- Gets target context
		try
			set theContextID to id of item 1 of (complete waitingForContext as context)
			set theWaitingForContext to first flattened context whose id is theContextID
		on error
			display alert "No context found whose name contains “" & waitingForContext & "”"
			return
		end try
		tell content of document window 1 -- (first document window whose index is 1)
			set theSelectedItems to value of every selected tree
			if ((count of theSelectedItems) < 1) then
				display alert "You must first select an item to complete." as warning
				return
			end if
			repeat with anItem in theSelectedItems
				set itemTitle to name of anItem
				set theDupe to duplicate anItem to after anItem
				tell application "System Events"
					key code 125
				end tell
				-- Configure the duplicate item
				set oldName to name of theDupe
				if (oldName does not start with waitingPrefix) then
					set name of theDupe to waitingPrefix & oldName
				end if
				set textToInsert to notePrefix & ((current date) as text) & return
				insert textToInsert at before first character of note of theDupe
				set context of theDupe to theWaitingForContext
				set repetition of theDupe to missing value
				-- set defer date of theDupe to missing value
				set deferDate to (current date) - (time of (current date)) + 86400
				set defer date of theDupe to (deferDate + (startTime * hours))
				set completed of anItem to true
			end repeat
			if (count of theSelectedItems) > 1 then
				set itemTitle to multipleItemsCompleted
			end if
		end tell
	end tell
end tell
