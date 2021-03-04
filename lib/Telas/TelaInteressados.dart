import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TelaInteressados extends StatefulWidget {

  String NomeCampanha;

  TelaInteressados(this.NomeCampanha);


  @override
  _TelaInteressadosState createState() => _TelaInteressadosState();
}

class _TelaInteressadosState extends State<TelaInteressados> {

    double valorRecuperado;
    String valorEstimado;
    String situacao;
    var _valores = ['1', '2', '3', '4', '5'];
    String tipoCampanha;
    String enviaProduto;
    int pendenteNovo;
    int alcance;

  _recuperarValor()async{
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection('campanhas').document(widget.NomeCampanha).get();
    setState(() {
      valorRecuperado=double.parse(documentSnapshot.data['valorEstimado']);
      int pendente = documentSnapshot.data['pendencias'];
      pendenteNovo = pendente - 1;
      alcance = documentSnapshot.data['alcance'];
    });
    print(valorRecuperado.toString());
  }
    _recuperarValorEstimado()async{
      DocumentSnapshot documentSnapshot = await Firestore.instance.collection('campanhas').document(widget.NomeCampanha).get();
      setState(() {
        double pagamentoEstimado = double.parse(documentSnapshot.data['valorEstimado']);
        valorEstimado= pagamentoEstimado.toStringAsFixed(2);
        situacao = documentSnapshot.data['situaçãoDaCampanha'];
        tipoCampanha = documentSnapshot.data['tipoCampanha'];
        enviaProduto = documentSnapshot.data['enviaProduto'];
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

    _salvarAvaliacao(String value, String userUid)async{
      DocumentSnapshot documentSnapshot = await Firestore.instance.collection('usuarios').document(userUid).get();
      String avaliacao = documentSnapshot.data['avaliação'];
      String avaliacoes = documentSnapshot.data['avaliações'];
      print(avaliacao);
      print(avaliacoes);

      double avaliacaoDouble = double.parse(avaliacao);
      double avaliacoesDouble = double.parse(avaliacoes);
      double avaliacaoFinal = avaliacaoDouble + double.parse(value);
      double avaliacoesFinal =  avaliacoesDouble + 1.0;
      print(avaliacaoFinal.toString());
      print(avaliacoesFinal.toString());
      double mediaAvaliacoes =  (avaliacaoFinal) / (avaliacoesFinal);



      Firestore.instance.collection('usuarios').document(userUid).updateData({
        'avaliação'       : avaliacaoFinal.toStringAsFixed(1),
        'avaliações'      : avaliacoesFinal.toStringAsFixed(1),
        'mediaAvaliações' : mediaAvaliacoes.toStringAsFixed(1)
      });

    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title:  Text(widget.NomeCampanha, style: TextStyle(fontSize: 16),
        ),
      ),
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
                        for (DocumentSnapshot item in querySnapshot.documents) {
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
                            Timestamp dataSolicitacao = interessado['dataSolicitação'];


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
                                              interessado['situação'], style: TextStyle(fontWeight: FontWeight.bold),),
                                        ),
                                        interessado['pagamento'] == 'liberado' ?
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text('Pagamento: ' +
                                              interessado['pagamento'], style: TextStyle(fontWeight: FontWeight.bold),),
                                        ) : Container(),

                                        interessado['situação'] == 'aceita' && tipoCampanha == 'Produto' && enviaProduto == 'sim'?
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text('Endereço: ' +
                                              interessado['endereço'], style: TextStyle(fontWeight: FontWeight.bold),),
                                        ) : Container(),

                                        interessado['situação'] == 'aceita' && tipoCampanha == 'Produto' && enviaProduto == 'sim'?
                                        Text('Envie junto com o produto instruções para a devolução') : Container(),

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

                                                  icon: Icon(Icons.movie, color: Colors.blue,),
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
                                        ],) : Container(),


                                        interessado['situação'] == 'solicitada' ?
                                        Row(
                                          //mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                          situacao == 'fechada' ? Container() :
                                          Padding(
                                              padding: EdgeInsets.only(bottom: 8, right: 16),
                                              child: RaisedButton(
                                                  child: Text('Aceitar', style: TextStyle(color: Colors.white, fontSize: 16),),
                                                  color: Colors.blue[800],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    //side: BorderSide(color: Color(0xff990000))
                                                  ),
                                                  onPressed: (){
                                                    _recuperarValor();
                                                    double valorCampanha = valorRecuperado + valorVideo;
                                                    int alcanceNovo = alcance + int.parse(interessado['visualizações']);
                                                    Firestore.instance.collection('interessados').document(widget.NomeCampanha).collection('interessados').document(interessado['uid']).updateData({
                                                      'situação' : 'aceita',
                                                      'dataResposta' : Timestamp.now(),
                                                      'pagamento' : 'aguardando postagem',
                                                    });

                                                    Firestore.instance.collection('campanhas').document(widget.NomeCampanha).updateData({
                                                      interessado['uid'] : {
                                                        'situação': 'aceita',
                                                        'dataSolicitação': interessado['dataSolicitação'],
                                                        'valorVideo' : interessado['valorVideo'],
                                                        'pagamento' : 'aguardando postagem',
                                                      },
                                                      'valorEstimado' :  valorCampanha.toStringAsFixed(2),
                                                      'pendencias' : pendenteNovo,
                                                      'alcance' : alcanceNovo
                                                    }
                                                    );
                                                    _recuperarValor();
                                                    _recuperarValorEstimado();
                                                  }
                                              )
                                          ),

                                          Padding(
                                              padding: EdgeInsets.only(bottom: 8),
                                              child: RaisedButton(
                                                  child: Text('Negar', style: TextStyle(color: Colors.white, fontSize: 16),),
                                                  color: Theme.of(context).primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    //side: BorderSide(color: Color(0xff990000))
                                                  ),
                                                  onPressed: (){
                                                    _recuperarValor();
                                                    Firestore.instance.collection('interessados').document(widget.NomeCampanha).collection('interessados').document(interessado['uid']).updateData({
                                                      'situação' : 'negada',
                                                      'dataResposta' : Timestamp.now()
                                                    });
                                                    Firestore.instance.collection('campanhas').document(widget.NomeCampanha).updateData({interessado['uid'] : {
                                                      'situação': 'negada',
                                                      'valorVideo' : interessado['valorVideo'],
                                                      'dataSolicitação': interessado['dataSolicitação']
                                                    },
                                                      'pendencias' : pendenteNovo
                                                    }
                                                    );
                                                    _recuperarValor();
                                                  }
                                              )
                                          )
                                        ],) : Container(),
                                        interessado['situação'] == 'completada' ? interessado['PostagemAvaliação'] == null ?
                                        Row(
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.only(bottom: 8, right: 16),
                                              child: Text('Avalie'),
                                            ),

                                            Padding(padding: EdgeInsets.only(bottom: 8),
                                            child: DropdownButton<String>(
                                                hint: Text('selecione a nota'),
                                                items: _valores.map(
                                                        (String dropDownItem){
                                                      return DropdownMenuItem<String>(
                                                        value: dropDownItem,
                                                        child: Text(dropDownItem),
                                                      );
                                                    }
                                                ).toList(),
                                                onChanged: (String value){
                                                  _salvarAvaliacao(value, interessado['uid']);
                                                  _recuperarValor();
                                                  Firestore.instance.collection('interessados').document(widget.NomeCampanha).collection('interessados').document(interessado['uid']).updateData({
                                                    'pagamento' : 'aguardando liberação',
                                                    'PostagemAvaliação' : double.parse(value)
                                                  });


                                                  Firestore.instance.collection('campanhas').document(widget.NomeCampanha).updateData({
                                                    interessado['uid'] : {
                                                      'dataSolicitação': interessado['dataSolicitação'],
                                                      'situação': 'completada',
                                                      'valorVideo' : interessado['valorVideo'],
                                                      'pagamento' : 'aguardando liberação',
                                                      'PostagemAvaliação' : double.parse(value)
                                                    },
                                                    'pendencias' : pendenteNovo
                                                  }
                                                  );
                                                }
                                            ),
                                            )
                                          ],
                                        ) : Container() : Container()
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
