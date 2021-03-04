import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Rotas.dart';



class Administracao extends StatefulWidget {
  @override
  _AdministracaoState createState() => _AdministracaoState();
}

class _AdministracaoState extends State<Administracao> {

  String nome;
  String email;
  String uid;
  String _urlImagemRecuperada;
  String _nomeRecuperado;


  Stream<QuerySnapshot> _recuperarCampanhas() {
    final stream = Firestore.instance
        .collection('campanhas')
        .orderBy('pendenciasAdm', descending: true)
        .snapshots();
    return stream;
  }

  _sair(){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
    Navigator.pushReplacementNamed(context, Rotas.Rota_Login);
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

  Stream<DocumentSnapshot> _recuperarPerfil(){
    final stream = Firestore.instance.collection('usuarios').document(uid).snapshots();
    return stream;
  }

  @override
  void initState() {
    super.initState();
    _testeLogado();
  }

  @override
  Widget build(BuildContext context) {
    return nome == null ? Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(title: Text('Administração', style: TextStyle(fontSize: 16),),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
      drawer: Drawer(),
    ) : Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: Text('Administração', style: TextStyle(fontSize: 16),),
      ),
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
                for (DocumentSnapshot item in querySnapshot.documents) {
                  if (item.data['situaçãoDaCampanha'] != 'fechada') continue;
                  listDocuments.add(item);
                }
                return listDocuments.length == 0 ? Center(
                  child: Text('Não existe nenhuma campanha fechada'),
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
                                  campanha['pendenciasAdm'].toString(),style: TextStyle(fontSize: 21),),
                              ),
                            ],
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
                    child: ListView(
                      children: <Widget>[
                        DrawerHeader(
                            decoration: BoxDecoration(color: Color(0xff990000),),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(bottom: 8),
                                    child:
                                    _urlImagemRecuperada == null ? Container() : CircleAvatar(radius: 35, backgroundImage: NetworkImage(_urlImagemRecuperada),)
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 8),
                                  child: Text(_nomeRecuperado, style: TextStyle(fontSize: 18, color: Colors.white),),
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 8),
                                  child: Text(email, style: TextStyle(color: Colors.white)),
                                )
                              ],
                            )),

                        ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.person_add),
                                ),
                                Text('Novos Usuarios',  style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            onTap: (){
                              Navigator.pushNamed(context, Rotas.Rota_NovosUsuarios);
                            }
                        ),

                        ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.people_outline),
                                ),
                                Text('Usuarios',  style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            onTap: (){
                              Navigator.pushNamed(context, Rotas.Rota_UsuariosAdm);
                            }
                        ),

                        ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.business),
                                ),
                                Text('Empresas',  style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            onTap: (){
                              Navigator.pushNamed(context, Rotas.Rota_EmpresasAdm);
                            }
                        ),
                        ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.list),
                                ),
                                Text('Campanhas',  style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            onTap: (){
                              Navigator.pushNamed(context, Rotas.Rota_CampanhasAdm);
                            }
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
                        ListTile(
                            title: Row(
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
                );
            }
            return Container();
          }
      ),
    );
  }
}
