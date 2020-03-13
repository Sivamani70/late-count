import 'package:flutter/material.dart';
import '../Data/dataManager.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:default_path_provider/default_path_provider.dart';

final PermissionHandler _permissionHandler = PermissionHandler();

class DisplayLateData extends StatefulWidget {
  final List<Map> dataList;
  DisplayLateData({this.dataList});

  @override
  _DisplayLateDataState createState() => _DisplayLateDataState();
}

class _DisplayLateDataState extends State<DisplayLateData> {
  List<Map> lateCountList;
  @override
  void initState() {
    lateCountList = [];
    if (widget.dataList.isNotEmpty) {
      lateCountList.addAll(widget.dataList);
    }
    super.initState();
  }

  @override
  void dispose() {
    StudentDataModel().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => deleteData(context, lateCountList),
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return lateCountList.isEmpty
        ? Center(
            child: Text(
              'No data available yet!',
              style: Theme.of(context).textTheme.body1,
            ),
          )
        : Container(
            child: ListView.builder(
              itemCount: lateCountList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'RollNo : ${lateCountList[index]['rollNum']}',
                        style: Theme.of(context).textTheme.title,
                      ),
                      subtitle: Text(
                        'Late Count : ${lateCountList[index]['lateCount']}',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                    ),
                  ],
                );
              },
            ),
          );
  }

  Future<void> deleteData(BuildContext context, List<Map> lateCountList) async {
    return lateCountList.isEmpty
        ? buildShowDialog(context, 'No Data', 'No Data Exists yet!')
        : showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Delete'),
              content: Text('Are you sure want to delete'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('No'),
                ),
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () async {
                    await saveToLocalStorage(context);
                  },
                ),
              ],
            ),
          );
  }

  Future<void> buildShowDialog(
      BuildContext context, String title, String text) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> saveToLocalStorage(BuildContext context) async {
    Map<PermissionGroup, PermissionStatus> permission = await askPermissions();
    if (permission[PermissionGroup.storage] == PermissionStatus.granted) {
      try {
        final String downloadPath =
            await DefaultPathProvider.getDownloadDirectoryPath;
        String dataToWrite = '';
        // String downloadPath = downloadsDirectory.path;
        for (Map late in lateCountList) {
          dataToWrite = dataToWrite +
              'Roll-No : ${late['rollNum']} , Late-Count : ${late['lateCount']} \n';
        }
        String fileName = 'Late-count-Data-on-Month-${DateTime.now().month}';
        File file = File('$downloadPath/$fileName.txt');
        await file.writeAsString(dataToWrite);
        StudentDataModel st = new StudentDataModel();
        await st.deleteData();
        Navigator.pop(context);
        setState(() {
          lateCountList.clear();
        });
      } catch (e) {
        buildShowDialog(context, 'Error', '${e.toString()}');
      }
    } else if (permission[PermissionGroup.storage] == PermissionStatus.denied ||
        permission[PermissionGroup.storage] == PermissionStatus.disabled ||
        permission[PermissionGroup.storage] == PermissionStatus.restricted) {
      buildShowDialog(
          context, 'Error', 'Permmisions are denined to save File Locally');
    }
  }

  Future<Map<PermissionGroup, PermissionStatus>> askPermissions() async {
    return await _permissionHandler
        .requestPermissions([PermissionGroup.storage]);
  }
}
