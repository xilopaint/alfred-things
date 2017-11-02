on run argv
    set workflowFolder to do shell script "pwd"
    set wlib to load script POSIX file (workflowFolder & "/q_workflow.scpt")

    set wf to wlib's new_workflow()
    set theAction to item 1 of argv as text
    set theList to (system attribute "list")

    if argv does not contain "back" then

        if theAction is "showLists" then
            showLists(wf)

        else if theAction is "showToDos" then
            showToDos(wf, theList)

        else if theAction is "showListInThings" then
            showListInThings(theList)

        else if theAction is "showToDoInThings" then
            showToDoInThings(argv)

        else if theAction is "addToDo" then
            addToDo(argv, theList)

        else if theAction is "markAsCompleted" then
            markAsCompleted(argv, theList)

        else if theAction is "markAsCanceled" then
            markAsCanceled(argv, theList)

        else if theAction is "deleteToDo" then
            deleteToDo(argv, theList)

        else if the theAction is "emptyTrash" then
            emptyTrash()

        end if
    end if
end run


on showLists(wf)
    tell application "Things3"
        repeat with theList in lists
            set theListName to name of theList
            set stdLists to {"Inbox", "Today", "Upcoming", "Anytime", "Someday", "Logbook", "Trash"}

            if theListName is in stdLists then
                set theIcon to "icons/" & theListName & ".png"
                add_result of wf with isValid given theUID:"", theArg:theListName, theTitle:theListName, theAutocomplete:"", theSubtitle:"", theIcon:theIcon, theType:""
            else if theListName is not in stdLists and theListName is not "Lonely Projects" then
                set theIcon to "icons/area.png"
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
            set theDueDate to due date of toDo

            if theDueDate is missing value then
                set theSubtitle to ""
            else
                set theInterval to ((theDueDate) - (current date)) / days

                if theInterval > 0 then
                    set theInterval to round theInterval rounding up
                    if not theInterval = 1 then
                        set theSubtitle to "⚑ " & theInterval & " days left"
                    else
                        set theSubtitle to "⚑ " & theInterval & " day left"
                    end if

                else if theInterval > -1 and theInterval < 0 then
                    set theSubtitle to "⚑ today"

                else if theInterval < -1 then
                    set theInterval to -1 * theInterval
                    set theInterval to round theInterval rounding down
                    if not theInterval = 1 then
                        set theSubtitle to "⚑ " & theInterval & " days ago"
                    else
                        set theSubtitle to "⚑ " & theInterval & " day ago"
                    end if
                end if
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


on addToDo(argv, theList)
    tell application "Things3"
        set toDoName to (item 2 of argv as text)
        set newToDo to make new to do with properties {name:toDoName} at beginning of list theList
        move newToDo to list theList
    end tell
end addToDo


on markAsCompleted(argv, theList)
    tell application "Things3"
        set toDo to to do named (item 2 of argv as text) of list theList
        set status of toDo to completed
        delay 1.3
    end tell
end markAsCompleted


on markAsCanceled(argv, theList)
    tell application "Things3"
        set toDo to to do named (item 2 of argv as text) of list theList
        set status of toDo to canceled
        delay 1.3
    end tell
end markAsCanceled


on deleteToDo(argv, theList)
    tell application "Things3"
        set toDo to to do named (item 2 of argv as text) of list theList
        move toDo to list "Trash"
    end tell
end deleteToDo


on emptyTrash()
    tell application "Things3"
        empty trash
    end tell
end emptyTrash
