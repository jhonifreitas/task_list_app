import 'package:flutter/material.dart';
import 'package:task_list_app/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      home: HomePage(),
    );
  }
}
