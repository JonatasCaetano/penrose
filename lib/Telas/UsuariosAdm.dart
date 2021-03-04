
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:penrose/Classes/Rotas.dart';

class UsuariosAdm extends StatefulWidget {
  @override
  _UsuariosAdmState createState() => _UsuariosAdmState();
}

class _UsuariosAdmState extends State<UsuariosAdm> {

  String nome;
  String email;
  String uid;
  TextEditingController _controllerUrlCanal = TextEditingController();
  TextEditingController _controllerInscritos = TextEditingController();
  TextEditingController _controllermediaDeVisualizacoes = TextEditingController();

  Stream<QuerySnapshot> _recuperarUsuarios() {
    final stream = Firestore.instance
        .collection('usuarios')
        .orderBy('nome', descending: false)
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
      appBar: AppBar(title: Text('Usuarios ADM', style: TextStyle(fontSize: 16),),
      ),
      body: nome == null ? Center(child: CircularProgressIndicator(),) :
      StreamBuilder(
          stream: _recuperarUsuarios(),
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
                  if(item.data['tipo'] == 'empresa' || item.data['tipo'] == 'administracao') continue;
                  listDocuments.add(item);
                }
                return listDocuments.length == 0 ? Center(
                  child: Text('Não existe nenhum usuario'),
                ) :
                ListView.builder(
                  itemCount: listDocuments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> user = listDocuments[index].data;
                    bool situacaoConta = true;
                    situacaoConta = user['situaçãoConta'] =='ativa' ? true : false;

                    double pendentePerfilAntigo = double.parse(user['pendentePerfil']);
                    double pendentePerfilNovo = pendentePerfilAntigo - 1.0;
                    String pendentePerfilFinal = pendentePerfilNovo.toStringAsFixed(1);
                    print(user['nome'] + ' ' + pendentePerfilAntigo.toStringAsFixed(1));
                    print(user['nome'] + ' ' + pendentePerfilFinal);
                    return GestureDetector(
                      child: Container(
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
                                  user['nome'], style: TextStyle(fontSize: 21, color: Colors.blue[800])),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Tipo: ' +
                                      user['tipo']),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Image.network(user['urlImagem' ], fit: BoxFit.fill,),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Email: ' +
                                      user['email']),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Uid: ' +
                                      user['uid']),
                                ),

                                Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: <Widget>[
                                        Text('Conta: '),
                                        Switch(
                                            value: situacaoConta,
                                            onChanged: (valor){
                                              print(valor.toString());
                                              valor == false ? Firestore.instance.collection('usuarios').document(user['uid']).updateData(
                                                  {
                                                    'situaçãoConta' : 'bloqueada'
                                                  }
                                              ) : Firestore.instance.collection('usuarios').document(user['uid']).updateData(
                                                  {
                                                    'situaçãoConta' : 'ativa'
                                                  }
                                              );
                                            }),
                                        Text(
                                            user['situaçãoConta']),
                                      ],
                                    )
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.only(right: 8),
                                        child: Icon(Icons.notifications),
                                      ),
                                      Padding(padding: EdgeInsets.only(right: 16),
                                        child: Text(user['pendentePerfil'].toString()),
                                      ),
                                      pendentePerfilAntigo >= 1.0 ?
                                      RaisedButton(
                                        child: Text('ok'),
                                        color: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          //side: BorderSide(color: Color(0xff990000))
                                        ),
                                        onPressed: (){
                                          Firestore.instance.collection('usuarios').document(user['uid']).updateData({
                                            'pendentePerfil' : pendentePerfilFinal
                                          });
                                        },
                                      ) : Container()
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.pushNamed(context, Rotas.Rota_SalvarDadosCanal, arguments: [user['uid'], user['nome']] );
                      },
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
