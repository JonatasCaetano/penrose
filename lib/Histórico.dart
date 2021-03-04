import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Usuario.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';


class Historico extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {



  Firestore db = Firestore();
  String _idUsuarioLogado;
  Usuario _usuario;
  String url;
  String tipo;
  String nome;
  String _idUsuario;
  String _situacao;
  String _urlVideo;
  String _mensagemErro = '';
  double visualizacoes;
  Timestamp dataSolicitacao;
  String pagamentoSituacao;
  String uid;

  Stream<QuerySnapshot> _recuperarCampanhas() {
    final stream = Firestore.instance
        .collection('campanhas')
        .orderBy('dataInicio', descending: true)
        .snapshots();
    return stream;
  }

  _testeLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if (user != null) {
      print('Usuario não é nulo');
      setState(() {
        uid = user.uid;
      });

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
        url        = _usuario.urlImagem;
        tipo       = _usuario.tipo;
        nome       = _usuario.nome;
        _idUsuario = user.uid;
        visualizacoes = double.parse(_usuario.mediaDeVisualizacoes);
      });
    }

  }

  _verificarUrlVideo(String nomeCampanha, Timestamp dataSolicitacao, int pendente, int pendenteAdm, String valorVideo)async{
    setState(() {
      _mensagemErro = '';
    });
    bool PostagemExiste = false;
    QuerySnapshot querySnapshot = await Firestore.instance.collection('PostagensCampanhas').document('Postagens').collection('PostagensCampanhas').getDocuments();
    for(DocumentSnapshot documentSnapshot in querySnapshot.documents){
      if(documentSnapshot.data['video'] == _urlVideo){
        setState(() {
          PostagemExiste = true;
        });
      }
    }
    if(PostagemExiste == false){
      salvarUrl(nomeCampanha, dataSolicitacao, pendente, pendenteAdm, valorVideo);
    }else{
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              content: Text('Este video já foi usado em uma campanha'),
              actions: [
                FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('ok')
                )
              ],
            );
          }
      );


      /*
      setState(() {
        _mensagemErro='Este video já foi usado em uma campanha';
      });
      Timer(Duration(seconds: 5), (){
        setState(() {
          _mensagemErro='';
        });
      });
       */

    }
  }

  salvarUrl(String nomeCampanha, Timestamp dataSolicitacao, int pendente, int pendenteAdm, String valorVideo ){
    Firestore.instance.collection('PostagensCampanhas').document('Postagens').collection('PostagensCampanhas').document(Timestamp.now().toString()).setData({
     'video' : _urlVideo ,
    }).then(
      (user){
        print('Ok salvo nas Postagens');

        Firestore.instance.collection('interessados').document(nomeCampanha).collection('interessados').document(uid).updateData({
          'urlVideo' : _urlVideo,
          'dataCompletada' : DateTime.now(),
        }).then(
                (user){
              Firestore.instance.collection('interessados').document(nomeCampanha).collection('interessados').document(uid).updateData({
                'situação' : 'completada',
                'pagamento' : 'aguardando liberação',
                'PostagemAvaliação' : null,
              });
              Firestore.instance.collection('campanhas').document(nomeCampanha).updateData({
                uid : {
                  'dataSolicitação': dataSolicitacao,
                  'situação': 'completada',
                  'valorVideo' : valorVideo,
                  'pagamento' : 'aguardando liberação',
                  'PostagemAvaliação' : null,
                },
                'pendencias' : pendente,
                'pendenciasAdm' : pendenteAdm
              });
              showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      content: Text('Video da campanha ' + nomeCampanha + ' enviado com sucesso'),
                      actions: [
                        FlatButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text('ok')
                        )
                      ],
                    );
                  }
              );
            }
        );
      }
    ).catchError(
        (error){
          print('erro :'+ error.toString());
        }
    );
  }

  _recuperarLink(String url) async {
    await launch(url);
  }

  @override
  void initState() {
    super.initState();
    print('teste logado executado');
    _testeLogado();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: Text('Meu histórico', style: TextStyle(fontSize: 16),),
      ),
      body: nome == null ?
          Center(child: CircularProgressIndicator(),) :
      StreamBuilder(
          stream: _recuperarCampanhas(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                print('done');
                QuerySnapshot querySnapshot = snapshot.data;
                List<DocumentSnapshot> listaDocumentos = List();
                for (DocumentSnapshot item in querySnapshot.documents) {
                  if (item[uid]['situação'] == 'não solicitada' || item[uid]['situação'] == 'solicitada') continue;
                  listaDocumentos.add(item);
                }

                return listaDocumentos.length == 0 ? Center(
                  child: Text('Você ainda não participou de nenhuma campanha'),
                ) :
                ListView.builder(
                  itemCount: listaDocumentos.length,

                  itemBuilder: (context, index) {
                    Map<String, dynamic> campanha = listaDocumentos[index].data;
                    TextEditingController _controllerUrlVideo = TextEditingController();

                    double valorView = double.parse(campanha['valorPorVisualizacao']);
                    double valorMaximo = double.parse(campanha['valorMaximoPorVideo']);
                    double valorCampanha = (visualizacoes * valorView) > valorMaximo ?
                    valorMaximo : (visualizacoes * valorView);
                    dataSolicitacao = campanha[uid]['dataSolicitação'];
                    int pendente = campanha['pendencias']+1;
                    int pendenteAdm = campanha['pendenciasAdm']+1;
                    return Container(
                      margin: EdgeInsets.only(left: 6, right: 6, top: 3, bottom: 3),
                      padding: EdgeInsets.only(left: 0, right: 0),
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        margin: EdgeInsets.only(left: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          //side: BorderSide(color: Color(0xff990000))
                        ),
                        color: Colors.white,
                        elevation: 2.0,

                        child: ListTile(
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(
                              campanha['nomeCampanha'], style: TextStyle(fontSize: 21, color: Colors.blue[800])),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Empresa: ' +
                                    campanha['nomeEmpresa']),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Ramo: ' +
                                    campanha['ramoEmpresa']),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Image.network(campanha['urlImagemDaEmpresa' ], fit: BoxFit.fill,),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Tipo de divulgação: ' +
                                    campanha['tipoCampanha']),
                              ),
                              campanha['tipoCampanha'] == 'Produto' ?
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Produto: ' +
                                    campanha['nomeDoProduto']),
                              )
                                  : Container(),
                              campanha['tipoCampanha'] == 'Produto' ?
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Envia o produto: ' +
                                    campanha['enviaProduto']),
                              )
                                  : Container(),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Observação: ' +
                                    campanha['observacao']),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Participação: ' +
                                    campanha[uid]['situação']),
                              ),

                              campanha[uid]['situação'] == 'completada' ?
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('Situação do pagamento: ' + campanha[uid]['pagamento']),
                              ) : Container(),

                              campanha[uid]['situação'] == 'completada' ? campanha[uid]['PostagemAvaliação'] != null ?
                              Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(children: <Widget>[
                                    Text('Avaliação da Postagem: ' +
                                        campanha[uid]['PostagemAvaliação'].toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                                    Icon(Icons.star, color: Colors.yellow[600], )
                                  ],)
                              ) : Container() : Container(),

                              campanha[uid]['situação'] == 'negada'? Container() :
                              Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
                              ),

                              campanha[uid]['situação'] == 'negada'? Container() :
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('R\$: ' +
                                    campanha[uid]['valorVideo'], style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),)
                              ),


                              campanha[uid]['situação'] == 'aceita' ?
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Instruções: ' +
                                    campanha['instrucao']),
                              ) : Container(),


                              campanha[uid]['situação'] == 'aceita' ? Column(
                                children: <Widget>[
                                  (campanha['ImagemLogo'] != 'vazia') || (campanha['Imagem1'] != 'vazia') || (campanha['Imagem2'] != 'vazia') || (campanha['video'] != 'vazia') ?
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text('Arquivos de apoio'),
                                  ) :  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text('Não possui arquivos de apoio'),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[

                                      campanha['ImagemLogo'] != 'vazia' ?
                                      IconButton(
                                          icon: Icon(Icons.image, color: Colors.blue,),
                                          onPressed: (){
                                            _recuperarLink(campanha['ImagemLogo']);
                                          }
                                      ) : Container(),
                                      campanha['Imagem1'] != 'vazia' ?
                                      IconButton(
                                          icon: Icon(Icons.image, color: Colors.blue,),
                                          onPressed: (){
                                            _recuperarLink(campanha['Imagem1']);
                                          }
                                      ) : Container(),
                                      campanha['Imagem2'] != 'vazia' ?
                                      IconButton(
                                          icon: Icon(Icons.image, color: Colors.blue,),
                                          onPressed: (){
                                            _recuperarLink(campanha['Imagem2']);
                                          }
                                      ) : Container(),
                                      campanha['video'] != 'vazia' ?
                                      IconButton(
                                          icon: Icon(Icons.ondemand_video, color: Colors.blue,),
                                          onPressed: (){
                                            _recuperarLink(campanha['video']);
                                          }
                                      ) : Container(),

                                    ],
                                  )
                                ],
                              ) : Container(),


                              campanha[uid]['situação'] == 'aceita' ? Padding(padding: EdgeInsets.only(bottom: 8),
                                child: TextField(
                                    controller: _controllerUrlVideo,
                                    decoration: InputDecoration(
                                        hintText: ' Url do Video Publicado',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                    )
                                ),
                              ) : Container(),
                              Text(_mensagemErro),
                              campanha[uid]['situação'] == 'aceita' ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                RaisedButton(
                                    child: Text('Enviar', style: TextStyle(color: Colors.white, fontSize: 16),),
                                    color: Colors.blue[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      //side: BorderSide(color: Color(0xff990000))
                                    ),
                                    onPressed: (){
                                      if( _controllerUrlVideo.text.isNotEmpty){
                                        setState(() {
                                          _urlVideo =  _controllerUrlVideo.text;
                                        });
                                        print(_urlVideo);
                                        _verificarUrlVideo(campanha['nomeCampanha'], dataSolicitacao, pendente, pendenteAdm, campanha[uid]['valorVideo']);
                                      }else{
                                        setState(() {
                                          _mensagemErro='A url não pode ser vazia';
                                        });
                                        Timer(Duration(seconds: 5), (){
                                          setState(() {
                                            _mensagemErro = '';
                                          });
                                        });
                                      }
                                    })
                              ],) : Container(),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
            }
            return Container();
          }
      ),
    );
  }
}

