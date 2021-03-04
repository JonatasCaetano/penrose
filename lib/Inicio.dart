import 'dart:async';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Funcoes.dart';


class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(Duration(seconds: 3), (){ Funcoes.testeLogado(context);});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Image.asset('imagens/icone.png'),
            Text('Penrose', style: TextStyle(fontSize: 50, color: Colors.red[900], decoration: TextDecoration.none)),
            Padding(padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(backgroundColor: Colors.red,),)

            ],
          )
        )
      );
    }
}

