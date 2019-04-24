import 'package:flutter/material.dart';
import 'package:task_list_app/services/storage.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final taskCtrl = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  List _objectList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    readData().then((data) {
      setState(() {
        this._objectList = json.decode(data);
      });
    });
  }

  void _addTask(){
    String task = this.taskCtrl.text;
    this.taskCtrl.clear();
    Map<String, dynamic> value = {'title': task, 'checked': false};
    setState(() {
      this._objectList.add(value);
    });
    saveData(this._objectList);
  }

  void _changeStateTask(bool checked, int index){
    setState(() {
      this._objectList[index]['checked'] = checked;
    });
    saveData(this._objectList);
  }

  Widget _removeTask(int index){
    this._lastRemoved = Map.from(this._objectList[index]);
    this._lastRemovedPos = index;
    setState(() {
      this._objectList.removeAt(index);
    });
    saveData(this._objectList);

    return SnackBar(
      content: Text('Tarefa \"${this._lastRemoved["title"]}\" removida!'),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: (){
          setState(() {
            this._objectList.insert(this._lastRemovedPos, this._lastRemoved);
          });
          saveData(this._objectList);
        },
      ),
    );
  }

  Future _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      this._objectList.sort((a, b){
        if(a['checked'] && !b['checked']) return 1;
        else if(!a['checked'] && b['checked']) return -1;
        else return 0;
      });
    });
    saveData(this._objectList);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Form(
              key: this.formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: this.taskCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nova Tarefa'
                      ),
                      validator: (value) {
                        if(value.isEmpty){
                          return 'Digite alguma coisa!';
                        }
                      },
                    ),
                  ),
                  RaisedButton(
                    child: Text('Add'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      if(this.formKey.currentState.validate()){
                        this._addTask();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: this._objectList.length,
                itemBuilder: this.buildItem,
              ),
              onRefresh: this._refresh,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9,0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: CheckboxListTile(
        title: Text(this._objectList[index]['title']),
        value: this._objectList[index]['checked'],
        secondary: CircleAvatar(
          child: Icon(
            this._objectList[index]['checked'] ? Icons.check : Icons.error
          ),
        ),
        onChanged: (value) {
          this._changeStateTask(value, index);
        },
      ),
      onDismissed: (direction){
        final snackbar = this._removeTask(index);
        Scaffold.of(context).showSnackBar(snackbar);
      },
    );
  }
}
