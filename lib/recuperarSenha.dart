import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecuperarSenha extends StatefulWidget {
  @override
  _RecuperarSenhaState createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {

  TextEditingController _controllerEmail = TextEditingController();
  String _email='vazio';
  String _mensagem='Entre no email abaixo para redefinir a senha';
  String _mensagemErro='';
  bool _enviado = false;

  _recuperarSenha(){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.sendPasswordResetEmail(
        email: _email
    );
  }

  _validarEmail(){
    setState(() {
      _mensagemErro='';
    });
    if(_controllerEmail.text.isNotEmpty && _controllerEmail.text.contains('@')){
      setState(() {
        _mensagemErro='';
        _email=_controllerEmail.text;
        _enviado=true;
      });
      _recuperarSenha();
    }else if(_controllerEmail.text.isEmpty){
      setState(() {
        _mensagemErro='Email não pode ser vazio';
      });
    }else{
      setState(() {
        _mensagemErro='Email invalido';
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Recuperar senha'),
        ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(16),
        child: _enviado == false ?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(bottom: 8),
              child: TextField(
                  controller: _controllerEmail,
                  decoration: InputDecoration(
                      hintText: 'E-mail',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                  )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: RaisedButton(
                child: Text('Recuperar senha', style: TextStyle(color: Colors.white, fontSize: 16),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  //side: BorderSide(color: Color(0xff990000))
                ),
                onPressed: _validarEmail,
                color: Colors.blue[800],
              ),
            ),
            Text(_mensagemErro, style: TextStyle(
                color: Colors.black, fontSize: 20),)
          ],
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_mensagem),
            Text(_email),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: RaisedButton(
                child: Text('Voltar', style: TextStyle(color: Colors.white, fontSize: 16),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  //side: BorderSide(color: Color(0xff990000))
                ),
                onPressed: (){
                  Navigator.pop(context);
                },
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      )
    );
  }
}
