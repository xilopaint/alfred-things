#!/usr/bin/osascript -l JavaScript

function run(argv) {
  const action = argv[0];
  const listId = $.NSProcessInfo.processInfo.environment.objectForKey("list").js;
  const projectId = $.NSProcessInfo.processInfo.environment.objectForKey("project").js;
  const tagId = $.NSProcessInfo.processInfo.environment.objectForKey("tag").js;

  if (argv.indexOf("back") === -1) {
    switch (action) {
      case "showLists":
        return showLists();
      case "showToDos":
        return showToDos(listId);
      case "showListInThings":
        showListInThings(listId);
        break;
      case "showToDoInThings":
        showToDoInThings(argv);
        break;
      case "showToDosInProject":
        return showToDosInProject(projectId);
      case "showTagsInList":
        return showTagsInList(listId);
      case "showToDosInTag":
        return showToDosInTag(tagId);
      case "addToDo":
        addToDo();
        break;
      case "markAsCompleted":
        markAsCompleted(argv);
        break;
      case "markAsCanceled":
        markAsCanceled(argv);
        break;
      case "deleteToDo":
        deleteToDo(argv);
        break;
      case "emptyTrash":
        emptyTrash();
        break;
      default:
        console.log("Invalid action.");
    }
  }
}

function showLists() {
  const app = Application("com.culturedcode.ThingsMac");
  const lists = app.lists();
  const items = [];

  for (let i = 0; i < lists.length; i++) {
    const list = lists[i];
    const listName = list.name();
    const listId = list.id();
    const icons = ["inbox", "today", "anytime", "upcoming", "someday", null, "logbook", "trash"];

    let icon = null;
    if (i < 8 && i !== 5) {
      icon = "images/icons/" + icons[i] + ".png";
    } else if (i > 8) {
      icon = "images/icons/area.png";
    }

    if (icon) {
      items.push({
        title: listName,
        subtitle: "",
        arg: listId,
        icon: { path: icon },
      });
    }
  }

  return JSON.stringify({ items: items });
}

function showToDos(listId) {
  const app = Application("com.culturedcode.ThingsMac");
  const list = app.lists.byId(listId);
  const toDos = list.toDos();
  const items = [];
  
  const subtitle = toDos.length === 0 ? "Empty list" : "";
  items.push({
    title: "Back to Lists",
    subtitle: subtitle,
    arg: "back",
    icon: { path: "images/icons/back.png" },
  });
  for (const toDo of toDos) {
    const toDoName = toDo.name();
    const dueDate = toDo.dueDate();
    const toDoId = toDo.id();
    let subtitle = "";
    let icon = "images/icons/todo.png";

    if (dueDate) {
      const interval = (dueDate - new Date()) / (1000 * 60 * 60 * 24);
      if (interval > 0) {
        const roundedInterval = Math.ceil(interval);
        subtitle = `⚐ ${roundedInterval} ${roundedInterval === 1 ? "day" : "days"} left`;
      } else if (interval > -1 && interval < 0) {
        subtitle = "⚐ today";
      } else if (interval < -1) {
        const roundedInterval = Math.floor(-interval);
        subtitle = `⚐ ${roundedInterval} ${roundedInterval === 1 ? "day" : "days"} ago`;
      }
    }

    if (app.projects.whose({ name: toDoName }).length > 0) {
      icon = "images/icons/project.png";
    }

    items.push({
      title: toDoName,
      subtitle: subtitle,
      arg: toDoId,
      icon: { path: icon },
    });
  }
  return JSON.stringify({ items: items });
}

function showListInThings(listId) {
  const app = Application("com.culturedcode.ThingsMac");
  const list = app.lists.byId(listId);
  app.activate();
  list.show();
}

function showToDoInThings(argv) {
  const app = Application("com.culturedcode.ThingsMac");
  const toDo = app.toDos.byId(argv[1]);
  app.activate();
  toDo.show();
}

function showToDosInProject(projectId) {
  const app = Application("com.culturedcode.ThingsMac");
  const project = app.projects.byId(projectId);
  const toDos = project.toDos();
  const items = [];

  const subtitle = toDos.length === 0 ? "Empty project" : "";
  items.push({
    title: "Back to Lists",
    subtitle: subtitle,
    arg: "back",
    icon: { path: "images/icons/back.png" },
  });

  for (const toDo of toDos) {
    const toDoName = toDo.name();
    const dueDate = toDo.dueDate();
    const toDoId = toDo.id();
    let subtitle = "";

    if (dueDate) {
      const interval = (dueDate - new Date()) / (1000 * 60 * 60 * 24);
      if (interval > 0) {
        const roundedInterval = Math.ceil(interval);
        subtitle = `⚐ ${roundedInterval} ${roundedInterval === 1 ? "day" : "days"} left`;
      } else if (interval > -1 && interval < 0) {
        subtitle = "⚐ today";
      } else if (interval < -1) {
        const roundedInterval = Math.floor(-1 * interval);
        subtitle = `⚐ ${roundedInterval} ${roundedInterval === 1 ? "day" : "days"} ago`;
      }
    }

    items.push({
      title: toDoName,
      subtitle: subtitle,
      arg: toDoId,
      icon: { path: "images/icons/todo.png" },
    });
  }

  return JSON.stringify({ items: items });
}

function showTagsInList(listId) {
  const app = Application("com.culturedcode.ThingsMac");
  const list = app.lists.byId(listId);
  const toDos = list.toDos();
  const items = [];
  const tagNames = new Set();

  items.push({
    title: "Back to Lists",
    subtitle: "",
    arg: "back",
    icon: { path: "images/icons/back.png" },
  });

  for (const toDo of toDos) {
    for (const tag of toDo.tags()) {
      const tagName = tag.name();
      const tagId = tag.id();

      if (!tagNames.has(tagName)) {
        tagNames.add(tagName);
        const theUrl = `things:///show?id=${list.name()}&filter=${tagName}`;

        items.push({
          title: tagName,
          subtitle: "",
          arg: tagId,
          icon: { path: "images/icons/tag.png" },
          mods: {
            cmd: {
              subtitle: "Show in Things",
              arg: theUrl,
            },
          },
        });
      }
    }
  }

  return JSON.stringify({ items: items });
}

function showToDosInTag(tagId) {
  const app = Application("com.culturedcode.ThingsMac");
  const tag = app.tags.byId(tagId);
  console.log(tagId)
  const toDos = tag.toDos();
  const items = [];

  items.push({
    title: "Back to Lists",
    subtitle: "",
    arg: "back",
    icon: { path: "images/icons/back.png" },
  });

  for (const toDo of toDos) {
    const toDoName = toDo.name();
    const dueDate = toDo.dueDate();
    const toDoId = toDo.id();
    let subtitle = "";

    if (dueDate) {
      const interval = (dueDate - new Date()) / (1000 * 60 * 60 * 24);
      if (interval > 0) {
        const roundedInterval = Math.ceil(interval);
        subtitle = `⚐ ${roundedInterval} ${roundedInterval === 1 ? "day" : "days"} left`;
      } else if (interval > -1 && interval < 0) {
        subtitle = "⚐ today";
      } else if (interval < -1) {
        const roundedInterval = Math.floor(-1 * interval);
        subtitle = `⚐ ${roundedInterval} ${roundedInterval === 1 ? "day" : "days"} ago`;
      }
    }

    items.push({
      title: toDoName,
      subtitle: subtitle,
      arg: toDoId,
      icon: { path: "images/icons/todo.png" },
    });
  }

  return JSON.stringify({ items: items });
}

function addToDo() {
  const app = Application("com.culturedcode.ThingsMac");
  app.showQuickEntryPanel();
}

function markAsCompleted(argv) {
  const app = Application("com.culturedcode.ThingsMac");
  const toDo = app.toDos.byId(argv[1]);
  toDo.status = "completed";
  delay(1.4);
}

function markAsCanceled(argv) {
  const app = Application("com.culturedcode.ThingsMac");
  const toDo = app.toDos.byId(argv[1]);
  toDo.status = "canceled";
  delay(1.4);
}

function emptyTrash() {
  const app = Application("com.culturedcode.ThingsMac");
  app.emptyTrash();
}
