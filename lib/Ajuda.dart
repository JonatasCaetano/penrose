import 'package:flutter/material.dart';

class Ajuda extends StatefulWidget {
  @override
  _AjudaState createState() => _AjudaState();
}

class _AjudaState extends State<Ajuda> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajuda', style: TextStyle(fontSize: 16),),),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('A Penrose cobra taxa das empresas?', style: TextStyle(fontWeight: FontWeight.bold),),
            Text('R: não'),
            Padding(padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('A Penrose cobra taxa dos youtubers?', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('R: sim a Penrose cobra uma taxa de 15 % no valor recebido de cada campanha'),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 8),
              child: Text('Para contatos:', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Text('email: penrose.app.console@gmail.com')
          ],
        ),
      ),
    );
  }
}
