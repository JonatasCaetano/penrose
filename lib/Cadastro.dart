import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penrose/Classes/Funcoes.dart';
import 'dart:io';
import 'dart:async';
import 'package:penrose/Classes/Usuario.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  String tipo = 'empresa';
  File _imagem;
  bool senhaSecreta = true;
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerRamo = TextEditingController();
  TextEditingController _controllerUrlCanal = TextEditingController();
  TextEditingController _controllerInscritos = TextEditingController();
  TextEditingController _controllermediaDeVisualizacoes = TextEditingController();
  TextEditingController _controllerendereco = TextEditingController();
  String texto = '';


  _validarAcesso() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    String nome = _controllerNome.text;
    String ramo = _controllerRamo.text;
    String urlCanal = _controllerUrlCanal.text;
    String numeroDeInscritos = _controllerInscritos.text;
    String mediaDeVisualizacoes = _controllermediaDeVisualizacoes.text;

    if (_imagem != null) {
      if (nome.isNotEmpty) {
        if (ramo.isNotEmpty) {
          if (email.isNotEmpty && email.contains('@')) {
            if (senha.isNotEmpty && senha.length >= 6) {

              Usuario usuario = Usuario(
                  nome,
                  ramo,
                  tipo,
                  null,
                  urlCanal,
                  numeroDeInscritos,
                  mediaDeVisualizacoes,
                  );

              cadastrar( email, senha, context, _imagem, usuario, _controllerendereco.text);
              setState(() {
                texto = 'Realizando cadastro...';
              });

            } else {
              setState(() {
                texto = 'Informe uma senha com no minimo 6 caracteres';
              });
            }
          } else {
            setState(() {
              texto = 'Informe o Email';
            });
          }
        } else {
          setState(() {
            tipo == "empresa"
                ? texto = 'Informe o ramo da empresa'
                : texto = 'Infomer o foco do canal';
          });
        }
      } else {
        setState(() {
          tipo == 'empresa'
              ? texto = 'Informe o nome da empresa'
              : texto = 'Infome o nome do Canal';
        });
      }
    } else {
      setState(() {
        texto = 'Selecione uma imagem';
      });
    }
  }

  cadastrar(String email, String senha, BuildContext context, File imagem , Usuario usuario, String endereco)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(
        email: email,
        password: senha
    ).then((firebaseUser){
      _salvar();
      setState(() {
        texto = 'Cadastro realizado, aguarde';
      });
      String email = firebaseUser.user.email;
      Funcoes.salvarImagem(imagem, usuario, context, endereco, email);
      Funcoes.salvarUrl(usuario, firebaseUser.user.uid);
    }).catchError((error){
      setState(() {
        texto = 'Erro ao cadastrar';
      });
    });
  }

  Future _carregarImagem() async {
    File _imagemSelecionada = await ImagePicker.pickImage(
        source: ImageSource.gallery);
    setState(() {
      _imagem = _imagemSelecionada;
    });
  }

  _salvar()async{
    String _valorEmail = _controllerEmail.text;
    String _valorSenha = _controllerSenha.text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('login', [_valorEmail, _valorSenha]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Container(
          width: MediaQuery
              .of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _carregarImagem,
                            child:  Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: _imagem == null
                                    ? CircleAvatar(
                                    backgroundColor: Colors.grey[350], radius: 50, child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, size: 30,),
                                    Text('Imagem Pública',style: TextStyle(fontSize: 10),)
                                  ],
                                )
                                )
                                    : CircleAvatar(radius: 50,
                                  backgroundImage: FileImage(_imagem),)
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Empresa'),
                          Radio(
                              value: 'empresa', groupValue: tipo, onChanged: (
                              escolha) {
                            setState(() {
                              tipo = escolha;
                            });
                          }),
                          Text('Youtuber'),
                          Radio(value: 'youtuber',
                              groupValue: tipo,
                              onChanged: (escolha) {
                                setState(() {
                                  tipo = escolha;
                                });
                              })
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 8),
                        child: TextField(
                            controller: _controllerNome,
                            decoration: InputDecoration(
                                hintText: tipo == 'empresa'
                                    ? 'Nome da empresa'
                                    : 'Nome do canal',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50))
                            )
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 2),
                        child: TextField(
                            controller: _controllerRamo,
                            decoration: InputDecoration(
                                hintText: tipo == 'empresa'
                                    ? 'Ramo'
                                    : 'Foco do canal',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50))
                            )
                        ),
                      ),
                      tipo == 'empresa' ? Container() :
                      Padding(
                        padding: EdgeInsets.only(bottom: 0, top: 0, left: 16),
                        child: Text(
                          'ex: culinaria, educação, infantil, etc...',
                          style: TextStyle(fontSize: 12),),
                      ),

                      Padding(padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: InputDecoration(
                                hintText: 'E-mail',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50))
                            )
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 8),
                        child: TextField(
                            controller: _controllerSenha,
                            obscureText: senhaSecreta,
                            decoration: InputDecoration(
                                hintText: 'Senha',
                                suffixIcon: IconButton(
                                    icon: senhaSecreta ? Icon(
                                        Icons.visibility_off) : Icon(
                                        Icons.visibility), onPressed: () {
                                  if (senhaSecreta == true) {
                                    setState(() {
                                      senhaSecreta = false;
                                    });
                                  } else if (senhaSecreta == false) {
                                    setState(() {
                                      senhaSecreta = true;
                                    });
                                  }
                                }),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50))
                            )
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text('Ao clicar no botão cadastrar, eu concordo que li e aceito os '),
                          Row(children: [
                            GestureDetector(
                              child: Text('Termos de uso ', style: TextStyle(color: Colors.blue),),
                              onTap: (){launch('https://penroseapp.blogspot.com/2020/08/termos-de-uso.html');},
                            ),
                            Text('e a '),
                            GestureDetector(
                              child: Text('Politica de privacidade', style: TextStyle(color: Colors.blue),),
                              onTap: (){launch('https://penroseapp.blogspot.com/2020/08/politica-de-privacidade.html');},
                            ),
                          ],)
                        ],)
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: RaisedButton(
                              child: Text('Cadastrar', style: TextStyle(
                                  color: Colors.white, fontSize: 16),),
                              onPressed: _validarAcesso,
                              color: Color(0xff990000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                //side: BorderSide(color: Color(0xff990000))
                              ),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(texto, style: TextStyle(
                                color: Colors.black, fontSize: 20),),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
