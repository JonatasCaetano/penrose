import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SalvarDadosCanal extends StatefulWidget {

  List<dynamic> argumentos;
  SalvarDadosCanal(this.argumentos);

  @override
  _SalvarDadosCanalState createState() => _SalvarDadosCanalState();
}

class _SalvarDadosCanalState extends State<SalvarDadosCanal> {

  TextEditingController _controllerUrlCanal = TextEditingController();
  TextEditingController _controllerInscritos = TextEditingController();
  TextEditingController _controllermediaDeVisualizacoes = TextEditingController();
  String canalExiste='';



  _salvarDados(String uidCanal){
    print(uidCanal);
    Firestore.instance.collection('UrldosCanais').document('urls').collection('UrldosCanais').document(uidCanal).setData({
      'urlCanal' : _controllerUrlCanal.text
    });
    Firestore.instance.collection('usuarios').document(uidCanal).updateData({
      'urlCanal' : _controllerUrlCanal.text,
      'inscritos' : _controllerInscritos.text,
      'MediaDeVisualizacoes' : _controllermediaDeVisualizacoes.text
    }).then((value){
      setState(() {
        canalExiste = 'Informações atualizadas';
      });
      Timer(Duration(seconds: 5), (){
        setState(() {
          canalExiste = '';
        });
      });
    }).catchError((error){
      setState(() {
        canalExiste = 'Erro ao atualizar informações';
      });
      Timer(Duration(seconds: 5), (){
        setState(() {
          canalExiste = '';
        });
      });
    });
  }

  _recuperarDadosCanal()async{
    String uidCanal = widget.argumentos[0];
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection('usuarios').document(uidCanal).get();
    setState(() {
      _controllerUrlCanal.text = documentSnapshot.data['urlCanal'];
      _controllerInscritos.text = documentSnapshot.data['inscritos'];
      _controllermediaDeVisualizacoes.text = documentSnapshot.data['MediaDeVisualizacoes'];
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosCanal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.argumentos[1]),),
      body: Container(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(bottom: 8, top: 8),
                  child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _controllerUrlCanal,
                      decoration: InputDecoration(
                          hintText: 'Canal url',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50))
                      )
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 8, top: 8),
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _controllerInscritos,
                      decoration: InputDecoration(
                          hintText: 'Numero de inscritos',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50))
                      )
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 8, top: 8),
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _controllermediaDeVisualizacoes,
                      decoration: InputDecoration(
                          hintText: 'Média de visualizações',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50))
                      )
                  ),
                ),

                Padding(padding: EdgeInsets.only(bottom: 8, right: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          child: Text('Salvar', style: TextStyle(
                              color: Colors.white, fontSize: 16),),
                          onPressed: (){
                            String uidCanal = widget.argumentos[0];
                            _salvarDados(uidCanal);
                          },
                          color: Color(0xff990000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            //side: BorderSide(color: Color(0xff990000))
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 16),
                          child: RaisedButton(
                            child: Text('Verificar canal', style: TextStyle(
                                color: Colors.white, fontSize: 16),),
                                onPressed:()async{
                                  String urlCanal = _controllerUrlCanal.text;
                                  setState(() {
                                    canalExiste= '';
                                  });
                                  QuerySnapshot querySnapshot = await Firestore.instance.collection('UrldosCanais').document('urls').collection('UrldosCanais').getDocuments();
                                  for(DocumentSnapshot documentSnapshot in querySnapshot.documents){
                                    if(documentSnapshot.data['urlCanal'] == urlCanal){
                                      setState(() {
                                        canalExiste = 'canal já existe';
                                      });
                                    }
                                  }
                                  if(canalExiste == ''){
                                    setState(() {
                                      canalExiste = 'canal não existe';
                                    });
                                  }
                                  print(canalExiste);
                                  Timer(Duration(seconds: 5), (){
                                    setState(() {
                                      canalExiste = '';
                                    });
                                  });
                                },
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              //side: BorderSide(color: Color(0xff990000))
                            ),
                          ),
                        ),
                      ],
                    )
                ),
                Text(canalExiste, style: TextStyle(fontSize: 16, color: canalExiste == 'canal já existe' ? Colors.red : Colors.blue[800]),)
              ],
            ),
          ),
        ),
      )
    );
  }
}
