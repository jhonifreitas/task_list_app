import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

Future<File> _getFile() async{
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/data.json');
}

Future<String> readData() async{
  try{
    final file = await _getFile();
    return file.readAsString();
  }catch(e){
    return null;
  }
}

Future<File> saveData(List objectList) async{
  String data = json.encode(objectList);
  final file = await _getFile();
  return file.writeAsString(data);
}
