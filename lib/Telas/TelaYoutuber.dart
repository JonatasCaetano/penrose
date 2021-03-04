import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Usuario.dart';



class TelaYoutuber extends StatefulWidget {
  @override
  _TelaYoutuberState createState() => _TelaYoutuberState();
}

class _TelaYoutuberState extends State<TelaYoutuber> {
  Usuario _usuario;
  String url;
  String tipo;
  String nome;
  double visualizacoes;
  String mediaAvaliacoes;
  String uid;
  String situacaoConta= 'ativa';
  String endereco;



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
        visualizacoes = double.parse(_usuario.mediaDeVisualizacoes);
        mediaAvaliacoes = snapshot.data['mediaAvaliações'];
        uid = snapshot.data['uid'];
        situacaoConta = snapshot.data['situaçãoConta'];
        endereco = snapshot.data['endereço'];
        print(situacaoConta);
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
    return situacaoConta == null ? Center(child: CircularProgressIndicator(),) : situacaoConta == 'ativa' ?
    Container(
        color: Colors.grey[350],
      child: StreamBuilder(
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
                  if ((item.data['situaçãoDaCampanha'] != 'aberta') || item.data['plataforma'] != tipo) continue;
                  listaDocumentos.add(item);
                }

                return listaDocumentos.length == 0 ? Center(
                  child: Text('No momento não existem campanhas abertas'),
                ) :
                ListView.builder(
                  itemCount: listaDocumentos.length,
                  itemBuilder: (context, index) {


                    Map<String, dynamic> campanha = listaDocumentos[index].data;
                    int pendente = campanha['pendencias']+1;

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
                                ) : Container(),

                                campanha['tipoCampanha'] == 'Produto' ?
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Envia o produto: ' +
                                      campanha['enviaProduto']),
                                ) : Container(),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Observação: ' +
                                      campanha['observacao']),
                                ),

                                Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('R\$: ' +
                                      campanha[uid]['valorVideo'], style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
                                ),

                                campanha[uid]['situação'] == 'não solicitada'
                                    ? Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: RaisedButton(
                                      child: Text(
                                        'Participar',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      color: Colors.blue[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        //side: BorderSide(color: Color(0xff990000))
                                      ),
                                      onPressed: (endereco == '') && (campanha['tipoCampanha']=='Produto') && (campanha['enviaProduto'] == 'sim')  ?
                                          (){
                                        final snackBar = SnackBar(content: Text('Para participar desta campanha é necessário ter cadastrado um endereço'));
                                        Scaffold.of(context).showSnackBar(snackBar);
                                      } :
                                          () {

                                        Firestore.instance
                                            .collection('campanhas')
                                            .document(listaDocumentos[index]
                                            .data['nomeCampanha'])
                                            .updateData({
                                          uid : {
                                            'dataSolicitação': Timestamp.now(),
                                            'situação': 'solicitada',
                                            'valorVideo' : campanha[uid]['valorVideo'],
                                          },
                                          'pendencias' : pendente
                                        });

                                        Firestore.instance
                                            .collection('interessados')
                                            .document(campanha['nomeCampanha'])
                                            .collection('interessados')
                                            .document(uid)
                                            .setData({
                                          'nome' : nome,
                                          'situação' : 'solicitada',
                                          'ramo' : _usuario.ramo,
                                          'inscritos' : _usuario.numeroDeInscritos,
                                          'visualizações' : _usuario.mediaDeVisualizacoes,
                                          'urlCanal' : _usuario.urlCanal,
                                          'urlImagem' : _usuario.urlImagem,
                                          'dataSolicitação' : Timestamp.now(),
                                          'valorPorView' : campanha['valorPorVisualizacao'],
                                          'valorMaximo' : campanha['valorMaximoPorVideo'],
                                          'urlVideo' : '',
                                          'valorVideo' : campanha[uid]['valorVideo'],
                                          'mediaAvaliações' : mediaAvaliacoes,
                                          'uid' : uid,
                                          'endereço' : endereco
                                        });

                                      }
                                  ),
                                ) :
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.only(bottom: 2, top: 8),
                                      child: Text('Participação Solicitada', style: TextStyle(fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(padding: EdgeInsets.only(bottom: 16, top: 2),
                                      child: Text('Acompanhe pelo histórico', style: TextStyle(fontWeight: FontWeight.bold),),
                                    )
                                  ],),
                              ],
                            ),
                          ),
                        )
                    );
                  },
                );
            }
            return Container();
          }
      )
    ) : Container(
      child: Center(child: Text(situacaoConta),),
    );
  }
}
