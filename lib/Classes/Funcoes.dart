import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'Usuario.dart';
import 'dart:async';
import 'Rotas.dart';

class Funcoes{

  static salvarUrl(Usuario usuario, uid){
    if(usuario.tipo == 'youtuber'){
      Firestore.instance.collection('UrldosCanais').document('urls').collection('UrldosCanais').document(uid).setData({
        'url' : usuario.urlCanal,
      });
    }
  }


  static Future testeLogado(BuildContext context)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuario = await auth.currentUser();
    if(usuario != null){
      Navigator.pushReplacementNamed(context, Rotas.Rota_Home );
    }else{
      Navigator.pushReplacementNamed(context, Rotas.Rota_Login);
    }
  }

  static recuperarDados()async{
    Usuario usuario;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    DocumentSnapshot snapshot = await Firestore.instance.collection('usuarios').document(user.uid).get();
    usuario = Usuario(snapshot.data['nome'], snapshot.data['ramo'], snapshot.data['tipo'], snapshot.data['urlImagem'], snapshot.data['urlCanal'], snapshot.data['numeroDeInscritos'], snapshot.data['mediaDeVisualizacoes']);
    return usuario;
  }

  static salvarCadastro(Usuario usuario, BuildContext context, String endereco, String email)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    Firestore.instance.collection('usuarios').document(usuarioLogado.uid).setData(Funcoes.usuarioparaMap(usuario, usuarioLogado.uid, endereco, email)).then((firebaseUser){
      ///salvarInteresse(usuario, usuarioLogado.uid);
      Navigator.pushReplacementNamed(context, Rotas.Rota_Home);
    });

  }

  static Map<String, dynamic> usuarioparaMap(Usuario usuario, String userid, String endereco, String email){

    Map<String, dynamic> map = {

      'nome' : usuario.nome,
      'ramo'  : usuario.ramo,
      'tipo'  : usuario.tipo,
      'urlImagem' : usuario.urlImagem,
      'urlCanal' : 'vazio',
      'inscritos' : '0.0',
      'MediaDeVisualizacoes' : '0.0',
      'avaliação' : '5.0',
      'avaliações' : '1.0',
      'mediaAvaliações' : '5.0',
      'uid' : userid,
      'situaçãoConta' : usuario.ramo == 'empresa' ? 'ativa' : 'Em analise',
      'endereço' : endereco,
      'email' : email,
      'pendentePerfil' : '0.0'
    };
    return map;
  }

  static Future salvarImagem(File imagem , Usuario usuario, BuildContext context, String endereco, String email)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child('perfil').child(user.uid + '.jpeg');
    StorageUploadTask task = arquivo.putFile(imagem);
    task.onComplete.then((StorageTaskSnapshot snapshot)async{
      String url = await snapshot.ref.getDownloadURL();
      usuario.urlImagem=url;
    }).then((firebaseUser){
      salvarCadastro(usuario, context, endereco, email );
    });
  }

  static Future salvarImagemApenas(File imagem , Usuario usuario)async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child('perfil').child(user.uid);
    StorageUploadTask task = arquivo.putFile(imagem);
    task.onComplete.then((StorageTaskSnapshot snapshot)async{
      String url = await snapshot.ref.getDownloadURL();
      usuario.urlImagem=url;
    }).then((firebaseUser){
      print('Imagem salva');
    });
  }

  static criarCampanha()async{
    Usuario usuario = await recuperarDados();
    print(usuario.nome);
  }

}

salvarInteresse(Usuario usuario, uid) async {

  QuerySnapshot querySnapshot = await Firestore.instance.collection(
      'campanhas').getDocuments();
  for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
    if(usuario.tipo == 'empresa' ) continue;
    Firestore.instance.collection('campanhas').document(
        documentSnapshot.documentID.toString()).updateData({uid : {
      'situação': 'não solicitada',
      'dataSolicitação': Timestamp.now()
    }
    }
    );
  }
}
