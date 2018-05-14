on run argv
    set workflowFolder to do shell script "pwd"
    set wlib to load script POSIX file (workflowFolder & "/q_workflow.scpt")

    set wf to wlib's new_workflow()
    set theAction to item 1 of argv as text
    set theListID to (system attribute "list")
    set theProjectID to (system attribute "project")

    if argv does not contain "back" then

        if theAction is "showLists" then
            showLists(wf)

        else if theAction is "showToDos" then
            showToDos(wf, theListID)

        else if theAction is "showListInThings" then
            showListInThings(theListID)

        else if theAction is "showToDoInThings" then
            showToDoInThings(argv)

        else if theAction is "showToDosInProject" then
            showToDosInProject(wf, theProjectID)

        else if theAction is "addToDo" then
            addToDo(argv, theListID)

        else if theAction is "markAsCompleted" then
            markAsCompleted(argvD)

        else if theAction is "markAsCanceled" then
            markAsCanceled(argv)

        else if theAction is "deleteToDo" then
            deleteToDo(argv)

        else if the theAction is "emptyTrash" then
            emptyTrash()

        end if
    end if
end run


on showLists(wf)
    tell application "Things3"
        repeat with n from 1 to count of lists
            set theListName to name of item n of lists
            set theListID to id of item n of lists
            set theIcons to {"inbox", "today", "anytime", "upcoming", "someday", null, "logbook", "trash"}

            if n < 9 and n ≠ 6 then
                set theIcon to "icons/" & item n of theIcons & ".png"
                add_result of wf with isValid given theUID:"", theArg:theListID, theTitle:theListName, theAutocomplete:"", theSubtitle:"", theIcon:theIcon, theType:""

            else if n > 8 then
                set theIcon to "icons/area.png"
                add_result of wf with isValid given theUID:"", theArg:theListID, theTitle:theListName, theAutocomplete:"", theSubtitle:"", theIcon:theIcon, theType:""
            end if
        end repeat
    end tell
    return wf's to_xml("")
end showLists


on showToDos(wf, theListID)
    tell application "Things3"
        if wf's q_is_empty(to dos of list id theListID)
            set theSubtitle to "Empty list"
        else
            set theSubtitle to ""
        end if

        add_result of wf with isValid given theUID:"", theArg:"back", theTitle:"Back to Lists", theAutocomplete:"", theSubtitle:theSubtitle, theIcon:"icons/back.png", theType:""

        repeat with toDo in to dos of list id theListID
            set toDoName to name of toDo
            set theDueDate to due date of toDo
            set theID to id of toDo

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

            if not exists project named toDoName
                set theIcon to "icons/todo.png"
            else
                set theIcon to "icons/project.png"
            end if

            add_result of wf with isValid given theUID:"", theArg:theID, theTitle:toDoName, theAutocomplete:"", theSubtitle:theSubtitle, theIcon:theIcon, theType:""
        end repeat
    end tell
    return wf's to_xml("")
end showToDos


on showListInThings(theListID)
    tell application "Things3"
        activate
        show list id theListID
    end tell
end showListInThings


on showToDoInThings(argv)
    tell application "Things3"
            activate
            show to do id (item 2 of argv as text)
    end tell
end showToDoInThings


on showToDosInProject(wf, theProjectID)
    tell application "Things3"
        if wf's q_is_empty(to dos of project id theProjectID)
            set theSubtitle to "Empty list"
        else
            set theSubtitle to ""
        end if

        add_result of wf with isValid given theUID:"", theArg:"back", theTitle:"Back to Lists", theAutocomplete:"", theSubtitle:theSubtitle, theIcon:"icons/back.png", theType:""

        repeat with toDo in (to dos of project id theProjectID)
            set toDoName to name of toDo
            set theDueDate to due date of toDo
            set theID to id of toDo

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

            add_result of wf with isValid given theUID:"", theArg:theID, theTitle:toDoName, theAutocomplete:"", theSubtitle:theSubtitle, theIcon:"icons/todo.png", theType:""
        end repeat
    end tell
    return wf's to_xml("")
end showToDoInProject


on addToDo(argv, theListID)
    tell application "Things3"
        set toDoName to (item 2 of argv as text)
        set newToDo to make new to do with properties {name:toDoName} at beginning of list id theListID
        move newToDo to list id theListID
    end tell
end addToDo


on markAsCompleted(argv)
    tell application "Things3"
        set toDo to to do id (item 2 of argv as text)
        set status of toDo to completed
        delay 1.3
    end tell
end markAsCompleted


on markAsCanceled(argv)
    tell application "Things3"
        set toDo to to do id (item 2 of argv as text)
        set status of toDo to canceled
        delay 1.3
    end tell
end markAsCanceled


on deleteToDo(argv)
    tell application "Things3"
        set toDo to to do id (item 2 of argv as text)
        move toDo to list id "TMTrashListSource"
    end tell
end deleteToDo


on emptyTrash()
    tell application "Things3" to empty trash
end emptyTrash
