import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:penrose/Classes/Rotas.dart';
import 'package:penrose/Classes/Usuario.dart';




class TelaEmpresa extends StatefulWidget {
  @override
  _TelaEmpresaState createState() => _TelaEmpresaState();
}

class _TelaEmpresaState extends State<TelaEmpresa> {

  Firestore db = Firestore();
  Usuario _usuario;
  String url;
  String tipo;
  String nome;
  String uid;
  String situacaoConta;
  List listaDividas = List();

  _testeLogado() async {
    print('teste logado executado');
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    setState(() {
      uid = user.uid;
    });
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
        situacaoConta = snapshot.data['situaçãoConta'];
      });
    }
  }

  Stream<QuerySnapshot> _recuperarCampanhas() {
    final stream = Firestore.instance
        .collection('campanhas')
        .orderBy('pendencias', descending: true)
        .snapshots();
    return stream;
  }

  @override
  void initState() {
    listaDividas.clear();
    print('tela inicial');
    super.initState();
    _testeLogado();
  }
  @override
  void didUpdateWidget(TelaEmpresa oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('update tela');
    setState(() {
      listaDividas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[350],
        body: StreamBuilder(
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
                  listaDividas.clear();
                  for (DocumentSnapshot item in querySnapshot.documents) {
                    if (item.data['nomeEmpresa'] != nome) continue;
                    if(item.data['situaçãoPagamento'] == 'Enviado'){
                      listaDividas.add(item);
                    }
                    listDocuments.add(item);
                  }
                  print('Numero de dividas: ' + listaDividas.length.toString());
                  if(listaDividas.length >= 2){
                    Firestore.instance.collection('usuarios').document(uid).updateData({
                      'situaçãoConta' : 'Dividas Pendentes'
                    });
                  }
                  return snapshot.data == null ? Center(
                    child: CircularProgressIndicator(),
                  ) : listDocuments.length != 0 ?
                  ListView.builder(
                    itemCount: listDocuments.length,

                    itemBuilder: (context, index) {
                      Map<String, dynamic> campanha = listDocuments[index].data;

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
                            onTap: (){
                              Navigator.pushNamed(context, Rotas.Rota_TelaInteressados, arguments: campanha['nomeCampanha']);
                            },
                            title: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8, top: 8, right: 36),
                                  child: Text(
                                    campanha['nomeCampanha'], style: TextStyle(fontSize: 21, color: Colors.blue[800]),),
                                ),

                                Icon(Icons.notifications),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8, top: 8, left: 8, right: 8),
                                  child: Text(
                                    campanha['pendencias'].toString(),style: TextStyle(fontSize: 21),),
                                ),
                              ],
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                               Row(
                                 children: [
                                   Padding(
                                     padding: EdgeInsets.only(bottom: 8, right: 16),
                                     child: Text('Tipo: ' +
                                         campanha['tipoCampanha']),
                                   ),
                                   Padding(
                                     padding: EdgeInsets.only(bottom: 8),
                                     child: Text('Situação: ' +
                                         campanha['situaçãoDaCampanha']),
                                   ),
                                 ],
                               ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Image.network(campanha['urlImagemDaEmpresa' ], fit: BoxFit.fill,),
                                ),

                                /*
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
                                )
                                    : Container(),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Valor por visualização R\$: ' +
                                      campanha['valorPorVisualizacao']),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Valor maximo por video R\$: ' +
                                      campanha['valorMaximoPorVideo']),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Observação: ' +
                                      campanha['observacao']),
                                ),
                                 */

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Alcance: ' +
                                      campanha['alcance'].toString() + ' pessoas'),
                                ),

                                campanha['situaçãoDaCampanha'] == 'fechada' ?
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Pagamento: ' +
                                      campanha['situaçãoPagamento']),
                                ) : Container(),

                                Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
                                ),



                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Valor Total R\$: ' +
                                      campanha['valorEstimado'], style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                ),

                                campanha['situaçãoDaCampanha'] == 'aberta' ?
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 8, right: 8),
                                      child: RaisedButton(
                                          child: Text('Fechar', style: TextStyle(color: Colors.white, fontSize: 14),),
                                          color: Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                            //side: BorderSide(color: Color(0xff990000))
                                          ),
                                          onPressed: (){

                                            Firestore.instance.collection('campanhas').document(campanha['nomeCampanha']).updateData({
                                              'situaçãoDaCampanha' : 'fechada',
                                              'situaçãoPagamento' : campanha['valorEstimado'] == '0' || campanha['valorEstimado'] == '0.0' || campanha['valorEstimado'] == '0.00'? 'Não existe valor a ser pago' : 'O boleto para pagamento sera enviado para o Email cadastrado'
                                            });
                                          }
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: RaisedButton(
                                          child: Text('Interessados', style: TextStyle(color: Colors.white, fontSize: 14),),
                                          color: Colors.blue[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                            //side: BorderSide(color: Color(0xff990000))
                                          ),
                                          onPressed: (){

                                            Navigator.pushNamed(context, Rotas.Rota_TelaInteressados, arguments: campanha['nomeCampanha']);
                                          }
                                      )
                                  ),
                                ],) :
                                Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: RaisedButton(
                                        child: Text('Interessados', style: TextStyle(color: Colors.white, fontSize: 14),),
                                        color: Colors.blue[800],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          //side: BorderSide(color: Color(0xff990000))
                                        ),
                                        onPressed: (){
                                          Navigator.pushNamed(context, Rotas.Rota_TelaInteressados, arguments: campanha['nomeCampanha']);
                                        }
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ) : Center(
                    child: Text('Você ainda não criou nenhuma campanha'),
                  );
              }
              return Container();
            }
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.edit),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed:
            (){
              _testeLogado();
              listaDividas.length < 2 ?
                Navigator.pushNamed(context, Rotas.Rota_NovaCampanha)
               :
                Navigator.pushNamed(context, Rotas.Rota_ContaBloqueada);
            }
        )
    );
  }
}

