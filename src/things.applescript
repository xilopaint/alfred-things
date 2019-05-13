on run argv
    set workflowFolder to do shell script "pwd"
    set wlib to load script POSIX file (workflowFolder & "/lib/lib.scpt")
    set wf to wlib's workflow()
    set theAction to item 1 of argv as text
    set listId to (system attribute "list")
    set projectId to (system attribute "project")
    set tagId to (system attribute "tag")

    if argv does not contain "back" then

        if theAction is "showLists" then
            showLists(wf)

        else if theAction is "showToDos" then
            showToDos(wf, listId)

        else if theAction is "showListInThings" then
            showListInThings(listId)

        else if theAction is "showToDoInThings" then
            showToDoInThings(argv)

        else if theAction is "showToDosInProject" then
            showToDosInProject(wf, projectId)

        else if theAction is "showTagsInList" then
            showTagsInList(wf, listId)

        else if theAction is "showToDosInTag" then
            showToDosInTag(wf, tagId)

        else if theAction is "addToDo" then
            addToDo()

        else if theAction is "markAsCompleted" then
            markAsCompleted(argv)

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
            set listName to name of item n of lists
            set listId to id of item n of lists
            set icons to {"inbox", "today", "anytime", "upcoming", "someday", null, "logbook", "trash"}

            if n < 9 and n ≠ 6 then
                set icon to "icons/" & item n of icons & ".png"
                add_item of wf with valid given title:listName, subtitle:"", arg:listId, icon:icon

            else if n > 8 then
                set icon to "icons/area.png"
                add_item of wf with valid given title:listName, subtitle:"", arg:listId, icon:icon

            end if
        end repeat
    end tell
    return wf's to_json()
end showLists


on showToDos(wf, listId)
    tell application "Things3"
        if wf's is_empty(to dos of list id listId)
            set subtitle to "Empty list"
        else
            set subtitle to ""
        end if

        add_item of wf with valid given title:"Back to Lists", subtitle:subtitle, arg:"back", icon:"icons/back.png"

        repeat with toDo in to dos of list id listId
            set toDoName to name of toDo
            set dueDate to due date of toDo
            set toDoId to id of toDo

            if dueDate is missing value then
                set subtitle to ""
            else
                set interval to ((dueDate) - (current date)) / days

                if interval > 0 then
                    set interval to round interval rounding up
                    if not interval = 1 then
                        set subtitle to "⚑ " & interval & " days left"
                    else
                        set subtitle to "⚑ " & interval & " day left"
                    end if

                else if interval > -1 and interval < 0 then
                    set subtitle to "⚑ today"

                else if interval < -1 then
                    set interval to -1 * interval
                    set interval to round interval rounding down
                    if not interval = 1 then
                        set subtitle to "⚑ " & interval & " days ago"
                    else
                        set subtitle to "⚑ " & interval & " day ago"
                    end if
                end if
            end if

            if not exists project named toDoName
                set icon to "icons/todo.png"
            else
                set icon to "icons/project.png"
            end if

            add_item of wf with valid given title:toDoName, subtitle:subtitle, arg:toDoId, icon:icon
        end repeat
    end tell
    return wf's to_json()
end showToDos


on showListInThings(listId)
    tell application "Things3"
        activate
        show list id listId
    end tell
end showListInThings


on showToDoInThings(argv)
    tell application "Things3"
            activate
            show to do id (item 2 of argv as text)
    end tell
end showToDoInThings


on showToDosInProject(wf, projectId)
    tell application "Things3"
        if wf's is_empty(to dos of project id projectId)
            set subtitle to "Empty project"
        else
            set subtitle to ""
        end if

        add_item of wf with valid given title:"Back to Lists", subtitle:subtitle, arg:"back", icon:"icons/back.png"

        repeat with toDo in (to dos of project id projectId)
            set toDoName to name of toDo
            set dueDate to due date of toDo
            set toDoId to id of toDo

            if dueDate is missing value then
                set subtitle to ""
            else
                set interval to ((dueDate) - (current date)) / days

                if interval > 0 then
                    set interval to round interval rounding up
                    if not interval = 1 then
                        set subtitle to "⚑ " & interval & " days left"
                    else
                        set subtitle to "⚑ " & interval & " day left"
                    end if

                else if interval > -1 and interval < 0 then
                    set subtitle to "⚑ today"

                else if interval < -1 then
                    set interval to -1 * interval
                    set interval to round interval rounding down
                    if not interval = 1 then
                        set subtitle to "⚑ " & interval & " days ago"
                    else
                        set subtitle to "⚑ " & interval & " day ago"
                    end if
                end if
            end if

            add_item of wf with valid given title:toDoName, subtitle:subtitle, arg:toDoId, icon:"icons/todo.png"
        end repeat
    end tell
    return wf's to_json()
end showToDosInProject


on showTagsInList(wf, listId)
    tell application "Things3"
        add_item of wf with valid given title:"Back to Lists", subtitle:"", arg:"back", icon:"icons/back.png"

        set listName to text 3 thru -11 of listId
        set tagNames to {}

        repeat with theTag in tags of to dos of list id listId
            set tagName to name of theTag

            if tagNames does not contain tagName
                copy tagName to the end of tagNames
                set tagId to id of theTag
                set theUrl to "things:///show?id=" & listName & "&filter=" & tagName

                add_item of wf with valid given title:tagName, subtitle:"", arg:tagId, icon:"icons/tag.png"
                add_modifier of wf with valid given modkey:"cmd", subtitle:"Show in Things", arg:theUrl
            end if
        end repeat
    end tell
    return wf's to_json()
end showTagInList


on showToDosInTag(wf, tagId)
    tell application "Things3"
        add_item of wf with valid given title:"Back to Lists", subtitle:"", arg:"back", icon:"icons/back.png"

        repeat with toDo in (to dos of tag id tagId)
            set toDoName to name of toDo
            set dueDate to due date of toDo
            set toDoId to id of toDo

            if dueDate is missing value then
                set subtitle to ""
            else
                set interval to ((dueDate) - (current date)) / days

                if interval > 0 then
                    set interval to round interval rounding up
                    if not interval = 1 then
                        set subtitle to "⚑ " & interval & " days left"
                    else
                        set subtitle to "⚑ " & interval & " day left"
                    end if

                else if interval > -1 and interval < 0 then
                    set subtitle to "⚑ today"

                else if interval < -1 then
                    set interval to -1 * interval
                    set interval to round interval rounding down
                    if not interval = 1 then
                        set subtitle to "⚑ " & interval & " days ago"
                    else
                        set subtitle to "⚑ " & interval & " day ago"
                    end if
                end if
            end if

            add_item of wf with valid given title:toDoName, subtitle:subtitle, arg:toDoId, icon:"icons/todo.png"
        end repeat
    end tell
    return wf's to_json()
end showToDosInTag


on addToDo()
    tell application "Things3" to show quick entry panel
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
