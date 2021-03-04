import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Rotas.dart';


class CampanhasAdm extends StatefulWidget {
  @override
  _CampanhasAdmState createState() => _CampanhasAdmState();
}

class _CampanhasAdmState extends State<CampanhasAdm> {

  String nome;
  String email;
  String uid;
  String _urlImagemRecuperada;
  String _nomeRecuperado;


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
    setState(() {
      uid = user.uid;
      email= user.email;
    });
    if (user != null) {
      print('Usuario não é nulo');

      DocumentSnapshot snapshot = await Firestore.instance
          .collection('usuarios')
          .document(user.uid)
          .get();

      setState(() {
        nome  = snapshot.data['nome'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _testeLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(title: Text('Campanhas ADM', style: TextStyle(fontSize: 16),),
      ),
      body:
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
                List<DocumentSnapshot> listDocuments = List();
                for (DocumentSnapshot item in querySnapshot.documents) {
                  listDocuments.add(item);
                }
                return listDocuments.length == 0 ? Center(
                  child: Text('Não existe nenhuma campanha'),
                ) :
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
                            Navigator.pushNamed(context, Rotas.Rota_InteressadosAdm, arguments: campanha['nomeCampanha']);
                          },
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
                                child: Text('Situação: ' +
                                    campanha['situaçãoDaCampanha']),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Pagamento: ' +
                                    campanha['situaçãoPagamento']),
                              ),

                              Padding(padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: Divider(height: 1.0, color: Colors.grey, thickness: 1.0,),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text('Valor a Pagar R\$: ' +
                                    campanha['valorEstimado'], style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
                              ),

                              campanha['situaçãoPagamento'] == 'O boleto para pagamento sera enviado para o Email cadastrado' ?
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8, right: 16),
                                    child: RaisedButton(
                                        child: Text('Ver solicitações', style: TextStyle(color: Colors.white, fontSize: 14),),
                                        color: Colors.blue[800],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          //side: BorderSide(color: Color(0xff990000))
                                        ),
                                        onPressed: (){
                                          Navigator.pushNamed(context, Rotas.Rota_InteressadosAdm, arguments: campanha['nomeCampanha']);
                                        }
                                    ),

                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: RaisedButton(
                                        child: Text('Enviado', style: TextStyle(color: Colors.white, fontSize: 14),),
                                        color: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          //side: BorderSide(color: Color(0xff990000))
                                        ),
                                        onPressed: (){
                                          Firestore.instance.collection('campanhas').document(campanha['nomeCampanha']).updateData({
                                            'situaçãoDaCampanha' : 'fechada',
                                            'situaçãoPagamento' : 'Enviado'
                                          });
                                        }
                                    ),

                                  ),
                                ],
                              ) : campanha['situaçãoPagamento'] == 'Enviado' ?
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8, right: 16),
                                    child: RaisedButton(
                                        child: Text('Ver solicitações', style: TextStyle(color: Colors.white, fontSize: 14),),
                                        color: Colors.blue[800],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          //side: BorderSide(color: Color(0xff990000))
                                        ),
                                        onPressed: (){
                                          Navigator.pushNamed(context, Rotas.Rota_InteressadosAdm, arguments: campanha['nomeCampanha']);
                                        }
                                    ),

                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: RaisedButton(
                                        child: Text('Pago', style: TextStyle(color: Colors.white, fontSize: 14),),
                                        color: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          //side: BorderSide(color: Color(0xff990000))
                                        ),
                                        onPressed: (){
                                          Firestore.instance.collection('campanhas').document(campanha['nomeCampanha']).updateData({
                                            'situaçãoDaCampanha' : 'fechada',
                                            'situaçãoPagamento' : 'Pago'
                                          });
                                        }
                                    ),

                                  ),
                                ],
                              ) : Padding(
                                padding: EdgeInsets.only(bottom: 8, right: 16),
                                child: RaisedButton(
                                    child: Text('Ver solicitações', style: TextStyle(color: Colors.white, fontSize: 14),),
                                    color: Colors.blue[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      //side: BorderSide(color: Color(0xff990000))
                                    ),
                                    onPressed: (){
                                      Navigator.pushNamed(context, Rotas.Rota_InteressadosAdm, arguments: campanha['nomeCampanha']);
                                    }
                                ),

                              ),
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
