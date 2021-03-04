import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmpresasAdm extends StatefulWidget {
  @override
  _EmpresasAdmState createState() => _EmpresasAdmState();
}

class _EmpresasAdmState extends State<EmpresasAdm> {


  String nome;
  String email;
  String uid;
  String _urlImagemRecuperada;
  String _nomeRecuperado;

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
      appBar: AppBar(title: Text('Empresas ADM', style: TextStyle(fontSize: 16),),
      ),
      body: nome == null ? Center(child: CircularProgressIndicator(),) :
      Column(
        children: <Widget>[
          Expanded(child: StreamBuilder(
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
                      if(item.data['tipo'] != 'empresa') continue;
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
                                          Text('Conta: '
                                              ),
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
          ),
        ],
      )
    );
  }
}

