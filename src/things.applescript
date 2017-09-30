on run argv
	set theArg to item 1 of argv as text
	set workflowFolder to do shell script "pwd"
	set wlib to load script POSIX file (workflowFolder & "/q_workflow.scpt")
	set wf to wlib's new_workflow()

	set theList to (system attribute "list")

	if argv does not contain "back" then

		if theArg is "showLists" then
			showLists(wf)

		else if theArg is "showToDos" then
			showToDos(wf, theList)

		else if theArg is "showListInThings" then
			showListInThings(theList)

		else if theArg is "showToDoInThings" then
			showToDoInThings(argv)

		else if theArg is "addToDo" then
			addToDo(wf, argv, theList)

		else if theArg is "markAsCompleted" then
			markAsCompleted(argv, wf)

		else if theArg is "markAsCanceled" then
			markAsCanceled(argv, wf)

		else if theArg is "deleteToDo" then
			deleteToDo(argv, wf)

		else if the theArg is "emptyTrash" then
			emptyTrash(wf)

		end if
	end if
end run


on showLists(wf)
	tell application "Things3"
		repeat with theList in lists of (application "Things3")
			set theListName to name of theList
			set theIcon to "icons/" & theListName & ".png"

			if theListName is not "Lonely Projects" then
				add_result of wf with isValid given theUID:"", theArg:theListName, theTitle:theListName, theAutocomplete:"", theSubtitle:"", theIcon:theIcon, theType:""
			end if
		end repeat
	end tell

	return wf's to_xml("")
end showLists


on showToDos(wf, theList)
	tell application "Things3"
		if wf's q_is_empty(to dos of list theList) then
			set theSubtitle to "Empty list"
		else
			set theSubtitle to ""
		end if

		add_result of wf with isValid given theUID:"", theArg:"back", theTitle:"Back to Lists", theAutocomplete:"", theSubtitle:theSubtitle, theIcon:"icons/back.png", theType:""

		repeat with toDo in to dos of list theList
			set toDoName to name of toDo
			set theDueDate to due date of toDo as string
			if theDueDate is "missing value" then
				set theSubtitle to ""
			else
				set the theSubtitle to "Due on " & q_split(theDueDate as string, " 00:00:00") of wf
			end if

			add_result of wf with isValid given theUID:"", theArg:toDoName, theTitle:toDoName, theAutocomplete:"", theSubtitle:theSubtitle, theIcon:"icons/todo.png", theType:""
		end repeat
	end tell
	return wf's to_xml("")
end showToDos


on showListInThings(theList)
	tell application "Things3"
		activate
		show list theList
	end tell
end showListInThings


on showToDoInThings(argv)
	tell application "Things3"
		activate
		show to do (item 2 of argv as text)
	end tell
end showToDoInThings


on addToDo(wf, argv, theList)
	tell application "Things3"
		set toDo to (item 2 of argv as text)
		set newToDo to make new to do with properties {name:toDo} at beginning of list theList
		move newToDo to list theList
	end tell
end addToDo


on markAsCompleted(argv, wf)
	tell application "Things3"
		set toDoCompleted to to do named (item 2 of argv as text)
		set status of toDoCompleted to completed
		delay 1.3
	end tell
end markAsCompleted


on markAsCanceled(argv, wf)
	tell application "Things3"
		set toDoCompleted to to do named (item 2 of argv as text)
		set status of toDoCompleted to canceled
		delay 1.3
	end tell
end markAsCanceled


on deleteToDo(argv, wf)
	tell application "Things3"
		set toDo to to do named (item 2 of argv as text)
		move toDo to list "Trash"
	end tell
end deleteToDo


on emptyTrash(wf)
	tell application "Things3"
		empty trash
	end tell
end emptyTrash
