import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:penrose/Classes/Rotas.dart';
import 'package:penrose/Classes/Usuario.dart';
import 'package:penrose/Telas/TelaAdministrador.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Telas/TelaEmpresa.dart';
import 'Telas/TelaYoutuber.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Usuario _usuario;
  String url;
  String tipo;
  String nome;
  String _idUsuario;
  String _nomeRecuperado;
  String _urlImagemRecuperada;
  String email;

  _testeLogado()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if(user != null){
      print('Usuario não é nulo');

      DocumentSnapshot snapshot = await Firestore.instance.collection('usuarios').document(user.uid).get();
      Usuario usuario = Usuario(
          snapshot.data['nome'],
          snapshot.data['ramo'],
          snapshot.data['tipo'],
          snapshot.data['urlImagem'],
          snapshot.data['urlCanal'],
          snapshot.data['inscritos'],
          snapshot.data['MediaDeVisualizacoes']
      );
      setState(() {
        _usuario =usuario;
        url             =_usuario.urlImagem;
        tipo            =_usuario.tipo;
        nome            =_usuario.nome;
        _idUsuario      = user.uid;
        email           = user.email;
      });

     }else if(user == null){
      print('Usuario nulo');
      Navigator.pushReplacementNamed(context, Rotas.Rota_Login);
     }
    }

    _sair(){
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.signOut();
      Navigator.pushReplacementNamed(context, Rotas.Rota_Login);
    }


  Stream<DocumentSnapshot> _recuperarPerfil(){
    final stream = Firestore.instance.collection('usuarios').document(_idUsuario).snapshots();
    return stream;
  }


  @override
  void initState() {
    super.initState();
    print('teste logado executado');
    _testeLogado();
  }


  @override
  Widget build(BuildContext context){
    return tipo == 'administracao' ? Administracao() :
    Scaffold(
      appBar: AppBar(
        title: tipo==null ? Center(child: CircularProgressIndicator(),) : tipo == 'empresa' ? Text('Minhas Campanhas', style: TextStyle(fontSize: 16),) : Text('Campanhas abertas', style: TextStyle(fontSize: 16),),
      ),
      drawer: StreamBuilder(
          stream: _recuperarPerfil(),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                print('waiting');
                return Drawer(
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: Center(child: CircularProgressIndicator(),),
                      )
                    ],
                  ),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                print('done');
                DocumentSnapshot shot = snapshot.data;
                _urlImagemRecuperada = shot.data['urlImagem'];
                _nomeRecuperado = shot.data['nome'];
                return Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Drawer(
                      child: Column(
                        children: <Widget>[
                          Expanded(child: ListView(
                            padding: EdgeInsets.all(0),
                            children: <Widget>[
                              DrawerHeader(child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(bottom: 8),
                                      child:
                                      _urlImagemRecuperada == null ? Container() : CircleAvatar(radius: 35, backgroundImage: NetworkImage(_urlImagemRecuperada),)
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 8,),
                                    child: Text( _nomeRecuperado == null ? 'Usuario' : _nomeRecuperado , style: TextStyle(fontSize: 18, color: Colors.white)),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 8,),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: <Widget>[
                                          Text( email == null ? '' : email , style: TextStyle(color: Colors.white))
                                        ],
                                      ),
                                    )
                                  )
                                ],
                              ),
                                  decoration: BoxDecoration(color: Color(0xff990000),)
                              ),

                              tipo == 'empresa' ? Container() :
                              ListTile(title: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(right: 16),
                                    child: Icon(Icons.history),
                                  ),
                                  Text('Histórico',  style: TextStyle(fontSize: 16)),
                                ],
                              ),
                                onTap: (){
                                  Navigator.pushNamed(context, Rotas.Rota_Historico);
                                },
                              ),

                              ListTile(title: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(right: 16),
                                    child: Icon(Icons.perm_identity),
                                  ),
                                  Text('Minha conta',  style: TextStyle(fontSize: 16)),
                                ],
                              ),
                                onTap: (){
                                  Navigator.pushNamed(context, Rotas.Rota_Perfil);
                                },
                              ),

                              ListTile(title: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(right: 16),
                                    child: Icon(Icons.help_outline),
                                  ),
                                  Text('Ajuda',  style: TextStyle(fontSize: 16)),
                                ],
                              ),
                                onTap: (){
                                  Navigator.pushNamed(context, Rotas.Rota_Ajuda);
                                },
                              ),

                              ListTile(title: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(right: 16),
                                    child: Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('Sair',  style: TextStyle(fontSize: 16)),
                                ],
                              ),
                                  onTap: _sair
                              ),

                            ],
                          ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
                          ),
                          ListTile(title: Row(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.receipt),
                              ),
                              Text('Termos de uso',  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                            onTap: (){
                             launch('https://penroseapp.blogspot.com/2020/08/termos-de-uso.html');
                            },
                          ),
                          /*
                          Padding(padding: EdgeInsets.only(bottom: 16),
                            child: Text('Penrose       versão 1.0.0' ),
                          )
                          */
                        ],
                      )
                  ),
                );
            }
            return Container();
          }
      ),
      body: tipo==null ? Center(child: CircularProgressIndicator(),) : tipo == 'empresa' ? TelaEmpresa() : TelaYoutuber(),
    );
  }
}


