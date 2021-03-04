import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Usuario.dart';



class ContaBloqueada extends StatefulWidget {
  @override
  _ContaBloqueadaState createState() => _ContaBloqueadaState();
}

class _ContaBloqueadaState extends State<ContaBloqueada> {

  Usuario  _usuario;
  String uid;
  String situacaoConta;

  _testeLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    setState(() {
      uid = user.uid;
    });
    if (user != null) {
      print('Usuario não é nulo');

      DocumentSnapshot snapshot = await Firestore.instance
          .collection('usuarios')
          .document(user.uid)
          .get();
      Usuario usuario = Usuario(
          snapshot.data['nome'],
          snapshot.data['ramo'],
          snapshot.data['tipo'],
          snapshot.data['urlImagem'],
          snapshot.data['urlCanal'],
          snapshot.data['inscritos'],
          snapshot.data['MediaDeVisualizacoes']);

      setState(() {
        _usuario   = usuario;
        situacaoConta = snapshot.data['situaçãoConta'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print('teste logado executado');
    _testeLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Nova campanha'),
        ),
        body: situacaoConta == null ? Center(child: CircularProgressIndicator(),) :
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Conta bloqueada'),
              Text(situacaoConta),
            ],
          ),
        )
    );
  }
}
