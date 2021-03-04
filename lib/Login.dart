import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Rotas.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String texto='';
  bool senhaSecreta = true;
  String retorno;

  _validarAcesso()async{
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    if(email.isNotEmpty && email.contains('@')){
      if(senha.isNotEmpty && senha.length >= 5){
        entrar(email, senha);
        setState(() {
          texto='';
        });
      }else{
        setState(() {
          texto='Informe a senha';
        });
      }
    }else{
      setState(() {
        texto='Informe o email';
      });
    }
  }

  entrar(String email, String senha)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: email,
        password: senha
    ).then((firebaseUser){
      retorno = 'Login efetuado com sucesso';
      _salvar();
      setState(() {
        texto= retorno;
      });
      Timer(Duration(seconds: 1), (){
        Navigator.pushReplacementNamed(context, Rotas.Rota_Home);
      });
    }).catchError((error){
      retorno = 'Erro ao tentar fazer login';
      print('Erro : ' + retorno);
      setState(() {
        texto= retorno;
      });
    });
    print(texto);
  }
  
  _salvar()async{
    String _valorEmail = _controllerEmail.text;
    String _valorSenha = _controllerSenha.text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('login', [_valorEmail, _valorSenha]);
  }

  _recuperar()async{
    List<String> loginDados = List();
    final prefs = await SharedPreferences.getInstance();
    loginDados = await prefs.getStringList('login');
    setState(() {
      loginDados[0] != null ? _controllerEmail.text = loginDados[0] : _controllerEmail.text="";
      loginDados[1] != null ? _controllerSenha.text = loginDados[1] : _controllerSenha.text="";
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          Expanded(
            child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(bottom: 8, top: 36),
                        child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: InputDecoration(
                                hintText: 'E-mail',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                            )
                        ),
                      ),
                      TextField(
                          controller: _controllerSenha,
                          obscureText: senhaSecreta,
                          decoration: InputDecoration(
                              hintText: 'Senha',
                              suffixIcon: IconButton(icon: senhaSecreta ? Icon(Icons.visibility_off) : Icon(Icons.visibility), onPressed: (){
                                if(senhaSecreta==true){
                                  setState(() {
                                    senhaSecreta=false;
                                  });
                                }else if(senhaSecreta==false){
                                  setState(() {
                                    senhaSecreta=true;
                                  });
                                }
                              }),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                          )
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: RaisedButton(
                          child: Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 16),),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            //side: BorderSide(color: Color(0xff990000))
                          ),
                          onPressed: _validarAcesso,
                          color: Colors.blue[800],
                        ),
                      ),

                      Text(texto, style: TextStyle(color: Colors.black, fontSize: 20),),
                      Padding(padding: EdgeInsets.only(top: 16,),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(right: 8),
                              child: Text('Não tem cadastro? ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                            ),
                            FlatButton(
                              child: Padding(padding: EdgeInsets.all(1),
                                child: Text('Cadastre-se', style: TextStyle(color: Color(0xff990000), fontSize: 16),),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: BorderSide(color: Color(0xff990000))
                              ),
                              onPressed: (){
                                Navigator.pushNamed(context, Rotas.Rota_Cadastro);
                              },
                              //color: Color(0xff990000),
                            ),
                          ],
                        ),)
                    ],
                  ),
                )
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Esqueci minha senha', style: TextStyle(fontSize: 16),),
            Padding(padding: EdgeInsets.only(left: 16),
              child: FlatButton(
                child: Padding(padding: EdgeInsets.all(1),
                  child: Text('Recuperar', style: TextStyle(color: Colors.blue[800], fontSize: 16),),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.blue[800])
                ),
                onPressed: (){
                  Navigator.pushNamed(context, Rotas.Rota_RecuperarSenha);
                },
                //color: Color(0xff990000),
              ),
            )
          ],)
        ],)
      ),
    );
  }
}
