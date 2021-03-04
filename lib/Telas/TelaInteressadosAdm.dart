import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TelaInteressadosAdm extends StatefulWidget {

  String NomeCampanha;

  TelaInteressadosAdm(this.NomeCampanha);

  @override
  _TelaInteressadosAdmState createState() => _TelaInteressadosAdmState();
}

class _TelaInteressadosAdmState extends State<TelaInteressadosAdm> {
  double valorRecuperado;
  String valorEstimado;
  String situacao;
  String situacaoPagamento;
  int pendenteNovo;
  int alcance;

  _recuperarValor()async{
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection('campanhas').document(widget.NomeCampanha).get();
    setState(() {
      valorRecuperado=double.parse(documentSnapshot.data['valorEstimado']);
      int pendente = documentSnapshot.data['pendenciasAdm'];
      pendenteNovo = pendente - 1;
      alcance = documentSnapshot.data['alcance'];
    });
    print(valorRecuperado.toString());
    print(pendenteNovo.toString());
  }
  _recuperarValorEstimado()async{
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection('campanhas').document(widget.NomeCampanha).get();
    setState(() {
      double pagamentoEstimado = double.parse(documentSnapshot.data['valorEstimado']);
      valorEstimado= pagamentoEstimado.toStringAsFixed(2);
      situacao = documentSnapshot.data['situaçãoDaCampanha'];
      situacaoPagamento = documentSnapshot.data['situaçãoPagamento'];
    });
  }


  Stream<QuerySnapshot> _recuperarCampanhas() {
    final stream = Firestore.instance
        .collection('interessados')
        .document(widget.NomeCampanha)
        .collection('interessados').orderBy('dataSolicitação', descending: true).snapshots();
    return stream;
  }

  _recuperarLink(String url) async {
    await launch(url);
  }

  @override
  void initState() {
    super.initState();
    _recuperarValorEstimado();
    _recuperarValor();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
        appBar: AppBar(title: Text(widget.NomeCampanha + " Tela ADM", style: TextStyle(fontSize: 16),),),
        body:  valorEstimado == null ? Center(child: CircularProgressIndicator(),) :
        Column(
          children: <Widget>[
            Expanded(child: StreamBuilder(
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
                      List<DocumentSnapshot> listDocuments = List();
                      for (DocumentSnapshot item in querySnapshot.documents){
                        if(situacaoPagamento=='Pago'){
                          if(item.data['pagamento']== 'aguardando liberação'){

                            Firestore.instance.collection('interessados').document(widget.NomeCampanha).collection('interessados').document(item['uid']).updateData({
                              'pagamento' : 'liberado',
                            });
                            Firestore.instance.collection('campanhas').document(widget.NomeCampanha).updateData({item['uid']  :
                            {
                              'dataSolicitação': item.data['dataSolicitação'],
                              'situação': 'completada',
                              'valorVideo' : item.data['valorVideo'],
                              'pagamento' : 'liberado',
                              'PostagemAvaliação' : item.data['PostagemAvaliação']
                            },
                            });
                          }
                        }
                        listDocuments.add(item);
                      }

                      return listDocuments.length == 0 ? Center(
                        child: Text('Esta campanha ainda não possui interessados'),
                      ) :
                      ListView.builder(
                        itemCount: listDocuments.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> interessado = listDocuments[index].data;

                          double valorView = double.parse(interessado['valorPorView']);
                          double valorMaximo = double.parse(interessado['valorMaximo']);
                          double views = double.parse(interessado['visualizações']);
                          double valorVideo = valorView * views > valorMaximo ? valorMaximo :
                          valorView * views;



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
                                title: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 0, top: 8, right: 30),
                                        child: Text('Canal: ' +
                                            interessado['nome'], style: TextStyle(fontSize: 21, color: Colors.blue[800]),),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[

                                      Row(children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 0, right: 16),
                                            child: Row(children: <Widget>[
                                              Text('Avaliação: ' +
                                                  interessado['mediaAvaliações']),
                                              Padding(padding: EdgeInsets.only(bottom: 2),
                                                child: Icon(Icons.star, color: Colors.yellow[600],) ,
                                              )
                                            ],)
                                        ),
                                        Row(children: <Widget>[
                                          Text('Visitar canal: '),
                                          Padding(
                                              padding: EdgeInsets.only(bottom: 0 , left: 4),
                                              child: IconButton(
                                                  icon: Icon(Icons.video_library, color: Colors.blue,),
                                                  onPressed: (){
                                                    _recuperarLink(interessado['urlCanal']);
                                                  }
                                              )
                                          )
                                        ],
                                        ),
                                      ],),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Image.network(interessado['urlImagem'], fit: BoxFit.fill,),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text('Foco do canal: ' +
                                            interessado['ramo']),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text('Inscritos: ' +
                                            interessado['inscritos']),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text('Media de visualizações: ' +
                                            interessado['visualizações']),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text('Participação: ' +
                                            interessado['situação'],),
                                      ),
                                      interessado['situação'] == 'completada' ?

                                      interessado['situação'] != 'negada' ?
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text('Pagamento: ' +
                                            interessado['pagamento'],),
                                      ) : Container() : Container(),

                                      Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                                        child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text('R\$: ' +
                                            valorVideo.toStringAsFixed(2), style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
                                      ),

                                      interessado['situação'] == 'completada' ?
                                      Row(children: <Widget>[
                                        Text('Publicado'),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 8 , left: 16),
                                            child: IconButton(

                                                icon: Icon(Icons.ondemand_video, color: Colors.blue,),
                                                onPressed: (){
                                                  _recuperarLink(interessado['urlVideo']);
                                                }
                                            )
                                        ),
                                        interessado['PostagemAvaliação'] != null ?
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            interessado['PostagemAvaliação'].toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                                        ) : Container(),
                                        interessado['PostagemAvaliação'] != null ?
                                        Padding(padding: EdgeInsets.only(bottom: 10),
                                          child: Icon(Icons.star, color: Colors.yellow[600],) ,
                                        ): Container()
                                      ],
                                      ) : Container(),

                                      interessado['situação'] == 'completada' ? interessado['pagamento'] == 'liberado' ?
                                      RaisedButton(
                                          child: Text('Pago', style: TextStyle(color: Colors.white, fontSize: 16),),
                                          color: Colors.blue[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                            //side: BorderSide(color: Color(0xff990000))
                                          ),
                                          onPressed: (){
                                            _recuperarValor();
                                            Firestore.instance.collection('interessados').document(widget.NomeCampanha).collection('interessados').document(interessado['uid']).updateData({
                                              'pagamento' : 'pago',
                                            });

                                            Firestore.instance.collection('campanhas').document(widget.NomeCampanha).updateData({
                                              interessado['uid'] : {
                                                'dataSolicitação': interessado['dataSolicitação'],
                                                'situação' : 'completada',
                                                'valorVideo' : interessado['valorVideo'],
                                                'pagamento' : 'pago',
                                                'PostagemAvaliação' : interessado['PostagemAvaliação']
                                              },
                                              'pendenciasAdm' : pendenteNovo
                                             }
                                            );
                                            _recuperarValor();
                                            _recuperarValorEstimado();
                                          }) : Container() : Container()
                                    ]
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
            ),
            Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Total R\$: ' + valorEstimado, style: TextStyle(fontSize: 14),),
                    Text('   Alcance ' + alcance.toString() + ' pessoas', style: TextStyle(fontSize: 14),),
                  ],)
            )
          ],
        )
    );
  }
}
