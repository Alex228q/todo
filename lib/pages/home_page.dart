import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? sharedPreferences;
  @override
  void initState() {
    initPref();
    super.initState();
  }

  void saveOnLocalStorage() {
    final taskData = tasksList.map((task) => task.toJson()).toList();
    sharedPreferences?.setStringList('tasks', taskData);
  }

  void readTasks() {
    setState(() {
      final taskData = sharedPreferences?.getStringList('tasks') ?? [];
      tasksList =
          taskData.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
    });
  }

  void initPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    readTasks();
  }

  List<TaskModel> tasksList = [];
  final TextEditingController taskTextEditingController =
      TextEditingController();

  void createTask({required TaskModel task}) {
    setState(() {
      tasksList.add(task);
      saveOnLocalStorage();
    });
  }

  void updateTask({required String taskId, required TaskModel updateTask}) {
    final taskIndex = tasksList.indexWhere((task) => taskId == task.id);
    setState(() {
      tasksList[taskIndex] = updateTask;
      saveOnLocalStorage();
    });
  }

  void deleteTask({required String taskId}) {
    setState(() {
      tasksList.removeWhere((task) => task.id == taskId);
      saveOnLocalStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('My To-Do List'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: tasksList.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ListView.builder(
                        itemCount: tasksList.length,
                        itemBuilder: (context, index) {
                          final TaskModel task = tasksList[index];
                          return ListTile(
                            leading: Transform.scale(
                              scale: 2,
                              child: Checkbox(
                                value: task.isCompleted,
                                onChanged: (isChecked) {
                                  final TaskModel updatedTask = task;
                                  updatedTask.isCompleted = isChecked!;
                                  updateTask(
                                      taskId: task.id, updateTask: updatedTask);
                                },
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: task.isCompleted
                                    ? Colors.grey
                                    : Colors.black,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontSize: 20,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                deleteTask(taskId: task.id);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 30.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'No tasks registered, tap the button with the + symbol',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.spaceBetween,
                title: const Text('New Task'),
                content: TextField(
                  controller: taskTextEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Describe your task',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (taskTextEditingController.text.isNotEmpty) {
                        final TaskModel newTask = TaskModel(
                            id: DateTime.now().toString(),
                            title: taskTextEditingController.text);

                        createTask(task: newTask);
                        taskTextEditingController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
