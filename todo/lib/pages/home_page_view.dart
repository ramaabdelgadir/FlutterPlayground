import 'package:flutter/material.dart';
import 'package:to_do/pages/home_page_model.dart';
import 'package:to_do/themes/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomePage> {
  String? taskContent;
  Box? box;

  @override
  Widget build(BuildContext context) {
    late double deviceHeight = MediaQuery.of(context).size.height;
    late double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.14),
        child: _myAppBar(deviceWidth, deviceHeight),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _myAppBar(double width, double height) {
    return AppBar(
      title: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: width * 0.05, top: height * 0.026),
        child: Text(
          "To Do",
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(height * 0.1),
          bottomRight: Radius.circular(height * 0.1),
        ),
      ),
      backgroundColor: AppColors.mainColor,
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          box = snapshot.data;
          return _taskList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = box!.values.toList();

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        Task task = Task.fromMap(tasks[index]);
        print(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              fontSize: 18,
              color: task.done ? Colors.grey : Colors.black,
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            DateFormat('yyyy/MM/dd  HH:mm').format(task.timestamp),
            style: TextStyle(fontSize: 12),
          ),
          trailing: Icon(
            task.done ? Icons.check_box_rounded : Icons.check_box_outline_blank,
            color: task.done ? AppColors.mainColor : Colors.blueGrey,
            size: 30,
          ),
          onTap: () {
            setState(() {
              task.done = !task.done;
              box!.putAt(index, task.toMap());
            });
          },
          onLongPress: () {
            setState(() {
              box!.deleteAt(index);
            });
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: AppColors.mainColor,
      onPressed: _taskPopup,
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  void _taskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Task!", style: TextStyle(fontSize: 20)),
          content: TextField(
            onSubmitted: (_) {
              if (taskContent != null) {
                var task = Task(
                  content: taskContent!,
                  timestamp: DateTime.now(),
                  done: false,
                );
                box!.add(task.toMap());
                setState(() {
                  taskContent = null;
                });
              }
              Navigator.pop(context);
            },
            onChanged: (value) {
              setState(() {
                taskContent = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskContent != null) {
                  var task = Task(
                    content: taskContent!,
                    timestamp: DateTime.now(),
                    done: false,
                  );
                  box!.add(task.toMap());
                  setState(() {
                    taskContent = null;
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
