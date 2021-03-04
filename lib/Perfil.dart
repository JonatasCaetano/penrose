import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Classes/Rotas.dart';
import 'dart:async';

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {

  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerRamo = TextEditingController();
  TextEditingController _controllerUrlCanal = TextEditingController();
  TextEditingController _controllerInscritos = TextEditingController();
  TextEditingController _controllermediaDeVisualizacoes = TextEditingController();
  TextEditingController _controllerendereco = TextEditingController();
  File  _imagem;
  String _imagemRecuperada;
  String tipo;
  String uid;
  String _nomeAntigo;
  String mensagem='';
  double pendentePerfilAntigo;
  double pendentePerfilNovo;
  String pendentePerfilFinal;


  _testeLogado()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if(user != null){
      print('Usuario não é nulo');

      DocumentSnapshot snapshot = await Firestore.instance.collection('usuarios').document(user.uid).get();
      setState(() {
         uid = user.uid;
        _controllerNome.text = snapshot.data['nome'];
        _nomeAntigo = snapshot.data['nome'];
        _controllerRamo.text = snapshot.data['ramo'];
         tipo = snapshot.data['tipo'];
        _imagemRecuperada = snapshot.data['urlImagem'];
        _controllerUrlCanal.text = snapshot.data['urlCanal'];
        _controllerInscritos.text = snapshot.data['inscritos'];
        _controllermediaDeVisualizacoes.text = snapshot.data['MediaDeVisualizacoes'];
        _controllerendereco.text = snapshot.data['endereço'];
         pendentePerfilAntigo = double.parse(snapshot.data['pendentePerfil']);
         pendentePerfilNovo = pendentePerfilAntigo + 1.0;
         pendentePerfilFinal = pendentePerfilNovo.toStringAsFixed(1);
      });
    print(pendentePerfilFinal);
    }else if(user == null){
      print('Usuario nulo');
      Navigator.pushReplacementNamed(context, Rotas.Rota_Login);
    }
  }

  Future _carregarImagem() async {
    File _imagemSelecionada = await ImagePicker.pickImage(
        source: ImageSource.gallery);
    setState(() {
      _imagem = _imagemSelecionada;
    });
    salvarImagemApenas(_imagem);
  }

  salvarImagemApenas(File imagem)async{

    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child('perfil').child(uid + '.jpeg');
    StorageUploadTask task = arquivo.putFile(imagem);
    task.onComplete.then((StorageTaskSnapshot snapshot)async{
      String url = await snapshot.ref.getDownloadURL();
      setState(() {
        _imagemRecuperada=url;
        mensagem='Imagem salva';
      });

    }).then((user)async{
      print('Imagem salva');
      Firestore.instance.collection('usuarios').document(uid).updateData(
        {
        'urlImagem' : _imagemRecuperada
        }
      );
      if(tipo == 'empresa'){
        QuerySnapshot querySnapshot = await Firestore.instance.collection('campanhas').getDocuments();
        for(DocumentSnapshot item in querySnapshot.documents){
          if(item.data['nomeEmpresa']== _nomeAntigo){
            Firestore.instance.collection('campanhas').document(item.documentID).updateData(
                {
                  'urlImagemDaEmpresa': _imagemRecuperada,
                }
            );
          }
        }
      }
    });
  }

  _atualizar() async {
    String urlCanalNovo = _controllerUrlCanal.text;
    Firestore.instance.collection('usuarios').document(uid).updateData({
      'nome' : _controllerNome.text,
      'ramo' : _controllerRamo.text,
      'urlCanal' : _controllerUrlCanal.text,
      'inscritos' : _controllerInscritos.text,
      'MediaDeVisualizacoes' : _controllermediaDeVisualizacoes.text,
      'endereço' : _controllerendereco.text
    }).then(
        (user){
          setState(() {
            mensagem='Cadastro atualizado';
          });
        }
    );
    if(tipo == 'youtuber'){
      Firestore.instance.collection('UrldosCanais').document('urls').collection('UrldosCanais').document(uid).updateData(
          {
            'url' : urlCanalNovo
          }
      );
    }
    if(tipo == 'empresa'){
      String novoNome = _controllerNome.text;
      String novoRamo = _controllerRamo.text;
      QuerySnapshot querySnapshot = await Firestore.instance.collection('campanhas').getDocuments();
      for(DocumentSnapshot item in querySnapshot.documents){
        if(item.data['nomeEmpresa']== _nomeAntigo){
          Firestore.instance.collection('campanhas').document(item.documentID).updateData(
              {
                'nomeEmpresa': novoNome,
                'ramoEmpresa': novoRamo
              }
          );
        }
      }
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
    return  Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: Text('Minha conta', style: TextStyle(fontSize: 16),),
      ),
      body:
      Container(
          width: MediaQuery.of(context).size.width,
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
                            child: Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: _imagemRecuperada == null
                                    ? CircleAvatar(
                                  backgroundColor: Colors.grey, radius: 50,)
                                    : CircleAvatar(radius: 50,
                                  backgroundImage: NetworkImage(_imagemRecuperada),)
                            ),
                          ),
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
                        padding: EdgeInsets.only(bottom: 8, top: 0, left: 16),
                        child: Text(
                          'ex: culinaria, educação, infantil, etc...',
                          style: TextStyle(fontSize: 12),),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(mensagem),
                        ),
                       ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: RaisedButton(
                              child: Text('Atualizar', style: TextStyle(
                                  color: Colors.white, fontSize: 16),),
                              onPressed: (){
                                _atualizar();
                                Firestore.instance.collection('usuarios').document(uid).updateData({
                                  'pendentePerfil' : pendentePerfilFinal
                                }).then(
                                    (user){_testeLogado();}
                                );
                              },
                              color: Color(0xff990000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                //side: BorderSide(color: Color(0xff990000))
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
