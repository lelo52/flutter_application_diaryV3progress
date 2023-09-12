import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_diary/add_page.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({
    super.key,
  });
  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late Directory? directory;
  String filePath = '';
  dynamic myList = Text('준비');
  @override
  void initState() {
    // TODO: implement initState
    //파일경로 = 찾기;
    getPath().then((value) {
      showList();
    });
  }

  Future<void> getPath() async {
    directory = await getApplicationSupportDirectory();
    if (directory != null) {
      var fileName = 'zxc.json';
      filePath = '${directory!.path}/$fileName';
    }
  }

  Future<void> showList() async {
    try {
      var file = File(filePath);
      if (file.existsSync()) {
        setState(() {
          myList = FutureBuilder(
            future: file.readAsString(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var d = snapshot.data;
                var dataList = jsonDecode(d!) as List<dynamic>; //string -> map
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = dataList[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['contents']),
                      trailing: Icon(Icons.delete),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: dataList.length,
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        });
      }
    } catch (e) {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          ElevatedButton(onPressed: showList, child: Text('조회')),
          Expanded(child: myList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(filePath: filePath),
              ));
          if (result == 'ok') {
            showList();
            //결과 출력
          }
        },
      ),
    );
  }
}
