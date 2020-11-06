import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flux/internal/entity_info.dart';
import 'package:flux/internal/folder_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:process_run/process_run.dart';

final _folderProvider = FolderProvider();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SideDestination> sideDestinations = [];
  String currentDir;
  RelativeRect rect;

  bool ascending = true;
  int columnIndex = 0;

  @override
  void initState() {
    _folderProvider.directories.forEach((element) {
      sideDestinations.add(
        SideDestination(
          element.value,
          getEntityName(element.key),
          element.key,
        ),
      );
    });
    currentDir = _folderProvider.directories[0].key;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          Drawer(
            child: ListView(
              children: List.generate(
                sideDestinations.length,
                (index) => Material(
                  color: currentDir == sideDestinations[index].path
                      ? Theme.of(context).accentColor
                      : null,
                  child: ListTile(
                    leading: Icon(
                      sideDestinations[index].icon,
                      color: currentDir == sideDestinations[index].path
                          ? Theme.of(context).canvasColor
                          : null,
                    ),
                    title: Text(
                      sideDestinations[index].label,
                      style: TextStyle(
                        color: currentDir == sideDestinations[index].path
                            ? Theme.of(context).canvasColor
                            : null,
                      ),
                    ),
                    onTap: () => setState(
                        () => currentDir = sideDestinations[index].path),
                  ),
                ),
              )
                ..insert(
                  0,
                  Divider(
                    height: 2,
                  ),
                )
                ..insert(
                  0,
                  Container(
                    padding: EdgeInsets.all(24),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Flux",
                          style: TextStyle(fontSize: 24),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
            ),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    List<String> backDir = currentDir.split("/")..removeLast();
                    currentDir = backDir.join("/");
                  }),
                ),
              ),
              body: FutureBuilder<List<EntityInfo>>(
                future: getInfoForDir(Directory(currentDir)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data.isNotEmpty) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: DataTable(
                            sortAscending: ascending,
                            sortColumnIndex: columnIndex,
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(
                                label: Text("Name"),
                                onSort: (newColumnIndex, newAscending) =>
                                    setState(() {
                                  if (columnIndex == newColumnIndex) {
                                    ascending = newAscending;
                                  } else {
                                    ascending = true;
                                    columnIndex = newColumnIndex;
                                  }
                                }),
                              ),
                              DataColumn(
                                label: Text("Date"),
                                onSort: (newColumnIndex, newAscending) =>
                                    setState(() {
                                  if (columnIndex == newColumnIndex) {
                                    ascending = newAscending;
                                  } else {
                                    ascending = true;
                                    columnIndex = newColumnIndex;
                                  }
                                }),
                              ),
                              DataColumn(
                                label: Text("Size"),
                                onSort: (newColumnIndex, newAscending) =>
                                    setState(() {
                                  if (columnIndex == newColumnIndex) {
                                    ascending = newAscending;
                                  } else {
                                    ascending = true;
                                    columnIndex = newColumnIndex;
                                  }
                                }),
                              ),
                              DataColumn(
                                label: Text("Type"),
                              ),
                            ],
                            rows: List.generate(
                              snapshot.data.length,
                              (index) {
                                EntityInfo item = snapshot.data[index];

                                return DataRow(
                                  onSelectChanged: (_) async {
                                    if (item.isDirectory) {
                                      setState(() => currentDir = item.path);
                                    } else {
                                      final result =
                                          await OpenFile.open(item.path);
                                      print(result.type);
                                      if (result.type == ResultType.error) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: Text(
                                                "No app registered for this file type."),
                                            actions: [
                                              TextButton(
                                                child: Text("Ok"),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          Icon(
                                            item.isDirectory
                                                ? Icons.folder
                                                : Icons.insert_drive_file,
                                          ),
                                          SizedBox(width: 16),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 400,
                                            ),
                                            child: Text(
                                              getEntityName(item.path),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        DateFormat("HH:mm - d MMM yyyy").format(
                                          item.stat.modified,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item.isDirectory
                                            ? item.children.length.toString() +
                                                " items"
                                            : filesize(item.stat.size),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item.isDirectory ? "Directory" : "File",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )..insert(
                                0,
                                DataRow(
                                  onSelectChanged: (_) {
                                    setState(() {
                                      List<String> backDir =
                                          currentDir.split("/")..removeLast();
                                      currentDir = backDir.join("/");
                                    });
                                  },
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          Icon(Icons.folder),
                                          SizedBox(width: 16),
                                          Text(
                                            "..",
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Container()),
                                    DataCell(Container()),
                                    DataCell(Container()),
                                  ],
                                ),
                              ),
                          ),
                        ),
                      );
                      return Scrollbar(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTapDown: (details) {
                                Offset offset = details.globalPosition;
                                rect = RelativeRect.fromLTRB(
                                    offset.dx, offset.dy, offset.dx, offset.dy);
                              },
                              behavior: HitTestBehavior.translucent,
                              child: ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: Icon(
                                  snapshot.data[index].isDirectory
                                      ? Icons.folder
                                      : Icons.insert_drive_file,
                                  color: snapshot.data[index].isDirectory
                                      ? Theme.of(context).accentColor
                                      : null,
                                ),
                                onLongPress: () async {
                                  String result = await showMenu(
                                    context: context,
                                    position: rect ?? RelativeRect.fill,
                                    items: [
                                      PopupMenuItem(
                                        child: Text("Rename"),
                                        value: "rename",
                                      ),
                                    ],
                                  );

                                  print(result);

                                  switch (result) {
                                    case "rename":
                                      String value = "";
                                      showDialog(
                                        context: context,
                                        child: AlertDialog(
                                          title: Text("Rename file"),
                                          content: TextFormField(
                                            initialValue: getEntityName(
                                                snapshot.data[index].path),
                                            onChanged: (text) => value = text,
                                          ),
                                          actions: [
                                            FlatButton(
                                              child: Text("Cancel"),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                            FlatButton(
                                              child: Text("Rename"),
                                              onPressed: () async {
                                                List<String> newPath = snapshot
                                                    .data[index].path
                                                    .split("/")
                                                      ..removeLast()
                                                      ..add(value);
                                                await run("mv", [
                                                  snapshot.data[index].path,
                                                  newPath.join("/")
                                                ]);
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                      break;
                                  }
                                },
                                onTap: () async {
                                  if (snapshot.data[index].isDirectory) {
                                    setState(() =>
                                        currentDir = snapshot.data[index].path);
                                  } else {
                                    OpenFile.open(snapshot.data[index].path);
                                  }
                                },
                                subtitle: snapshot.data[index].isDirectory
                                    ? Text(snapshot.data[index].children.length
                                            .toString() +
                                        " items")
                                    : Text(filesize(
                                        snapshot.data[index].stat.size, 1)),
                                trailing: Text(DateFormat("HH:mm - d MMM yyyy")
                                    .format(
                                        snapshot.data[index].stat.modified)),
                                title: Text(
                                  getEntityName(snapshot.data[index].path),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                          itemCount: snapshot.data?.length ?? 0,
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 92,
                            ),
                            Text(
                              "The folder is empty",
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                      );
                    }
                  } else
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<EntityInfo>> getInfoForDir(Directory dir) async {
    List<FileSystemEntity> list = await dir.list().toList();
    List<EntityInfo> directories = [];
    List<EntityInfo> files = [];

    for (int i = 0; i < list.length; i++) {
      String name = getEntityName(list[i].path);
      if (name.startsWith(".")) {
        list.removeAt(i);
        continue;
      }

      EntityInfo info = EntityInfo(
        entity: list[i],
        stat: await list[i].stat(),
      );

      if (list[i] is Directory) {
        info.entityType = EntityType.DIRECTORY;
        info.children = await (list[i] as Directory).list().toList();
        directories.add(info);
      } else {
        info.entityType = EntityType.FILE;
        files.add(info);
      }
    }

    directories.sort((a, b) => sort(a, b, isDirectory: true));
    files.sort((a, b) => sort(a, b));

    return [...directories, ...files];
  }

  String getEntityName(String path) {
    return path.split("/").last;
  }

  int sort(EntityInfo a, EntityInfo b, {isDirectory = false}) {
    EntityInfo item1 = a;
    EntityInfo item2 = b;

    if (!ascending) {
      item2 = a;
      item1 = b;
    }

    switch (columnIndex) {
      case 0:
        return getEntityName(item1.path.toLowerCase())
            .compareTo(getEntityName(item2.path.toLowerCase()));
      case 1:
        return item1.stat.modified.compareTo(item2.stat.modified);
      case 2:
        if (isDirectory) {
          return item1.children.length.compareTo(item2.children.length);
        } else {
          return item1.stat.size.compareTo(item2.stat.size);
        }
        break;
    }
  }
}

class SideDestination {
  final IconData icon;
  final String label;
  final String path;

  const SideDestination(this.icon, this.label, this.path);
}
