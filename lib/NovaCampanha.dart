import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NovaCampanha extends StatefulWidget {
  @override
  _NovaCampanhaState createState() => _NovaCampanhaState();
}

class _NovaCampanhaState extends State<NovaCampanha> {

  TextEditingController _controllerNomeCampanha = TextEditingController();
  TextEditingController _controllerValorPorVisualizacao = TextEditingController();
  TextEditingController _controllerValorMaximoPorVideo = TextEditingController();
  TextEditingController _controllerInstrucoes = TextEditingController();
  TextEditingController _controllerNomeProduto = TextEditingController();
  TextEditingController _controllerObservacao = TextEditingController();
  TextEditingController _controllerDevolucao = TextEditingController();


  String _idUsuarioLogado;
  String _nome;
  String _ramo;
  String _urlImagem;
  String _nomeCampanha;
  String _tipoCampanha;
  String _enviaProduto;
  String _devolucao;
  String _situacao;
  bool _subindoImagem=false;
  File _imagem;
  File _videoUpload;
  String _ImagemLogo;
  String _Imagem1;
  String _Imagem2;
  String _video;
  bool ImageLogo=false;
  bool Imagem1=false;
  bool Imagem2=false;
  bool video=false;
  String _nomeTeste;
  bool _nomeExite;
  bool _campanhaExiste = false;
  String _mensagemErro = '';
  String situacaoConta = 'ativa';




  _recuperarDadosUsuario()async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    setState(() {
      _idUsuarioLogado = user.uid;
    });
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection('usuarios').document(_idUsuarioLogado).get();

    _nome = snapshot.data['nome'];
    _ramo = snapshot.data['ramo'];
    _urlImagem = snapshot.data['urlImagem'];
    situacaoConta = snapshot.data['situaçãoConta'];
    print(situacaoConta);
  }
  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  _salvarCampanha()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    setState(() {
      _situacao='aberta';

      if(_tipoCampanha!='Produto'){
        setState(() {
          _controllerNomeProduto.clear();
          _enviaProduto='não';
        });

      }
    });

    Map<String, dynamic> map = {
      'nomeCampanha' : _controllerNomeCampanha.text,
      'nomeEmpresa' : _nome,
      'ramoEmpresa' : _ramo,
      'urlImagemDaEmpresa' : _urlImagem,
      'tipoCampanha' : _tipoCampanha,
      'enviaProduto' : _enviaProduto,
      'valorPorVisualizacao' : _controllerValorPorVisualizacao.text,
      'valorMaximoPorVideo' : _controllerValorMaximoPorVideo.text,
      'instrucao' : _controllerInstrucoes.text,
      'situaçãoDaCampanha' : _situacao,
      'nomeDoProduto' : _controllerNomeProduto.text,
      'ImagemLogo' : _ImagemLogo == null ? 'vazia' : _ImagemLogo,
      'Imagem1' : _Imagem1 == null ? 'vazia' : _Imagem1,
      'Imagem2': _Imagem2 == null ? 'vazia' : _Imagem2,
      'video' : _video == null ? 'vazia' : _video,
      'dataInicio' : Timestamp.now(),
      'plataforma' : 'youtuber',
      'valorEstimado' : '0.00',
      'observacao' : _controllerObservacao.text.isEmpty ? 'não tem' : _controllerObservacao.text,
      'devoluçãoEndereço' : _controllerDevolucao.text.isEmpty ? 'vazia' : _controllerDevolucao.text,
      'situaçãoPagamento' : 'vazia',
      'pendencias' : 0,
      'pendenciasAdm' : 0,
      'alcance' : 0,

    };
    Firestore.instance.collection('campanhas').document(_nomeCampanha).setData(map).then(

            (FirebaseUser){
          salvarInteresse(_nomeCampanha, _controllerValorPorVisualizacao.text, _controllerValorMaximoPorVideo.text);
          Navigator.pop(context);
        }
    );
  }

  salvarInteresse(String nomeCampanha, String valorView, String valorMaximo)async{
    String valorMaximoRecebido = valorMaximo;
    String valorViewRecebido = valorView;
    QuerySnapshot querySnapshot = await Firestore.instance.collection('usuarios').getDocuments();
    for(DocumentSnapshot documentSnapshot in querySnapshot.documents){
      if(documentSnapshot.data['tipo'] == 'empresa' || documentSnapshot.data['tipo'] == 'administracao' || documentSnapshot.data['situaçãoConta'] == 'Em analise') continue;
      String uid = documentSnapshot.data['uid'];

      double valorViewFinal = double.parse(valorViewRecebido);
      double valorMaximoFinal = double.parse(valorMaximoRecebido);
      double viewsFinal = double.parse(documentSnapshot.data['MediaDeVisualizacoes']);
      double valorCampanha = (viewsFinal * valorViewFinal) > valorMaximoFinal ?
      valorMaximo : (viewsFinal * valorViewFinal);
      String valorVideo = valorCampanha.toStringAsFixed(2);

      Firestore.instance.collection('campanhas').document(nomeCampanha).updateData({uid : {
        'situação': 'não solicitada',
        'dataSolicitação': Timestamp.now(),
        'valorVideo' : valorVideo
      }
      }
      );
    }

  }

  Future _salvarImagem(String nomeImagem)async{
    File _imagemSelecionada;
    _imagemSelecionada =await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imagem=_imagemSelecionada;
      if(_imagem != null){
        _subindoImagem=true;
        _uploadImagem(nomeImagem);
      }
    });
  }
  Future _salvarVideo(String nomeVideo)async{
    File _videoSelecionado;
    _videoSelecionado =await ImagePicker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _videoUpload=_videoSelecionado;
      if(_videoUpload != null){
        _subindoImagem=true;
        _uploadVideo(nomeVideo);
      }
    });
  }

  Future _uploadImagem(String nomeImagem){
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child(_nomeCampanha).child(nomeImagem + '.jpeg');

    StorageUploadTask task = arquivo.putFile(_imagem);
    task.events.listen((StorageTaskEvent storageEvent){
      if(storageEvent.type == StorageTaskEventType.progress){
        setState(() {
          _subindoImagem=true;
        });
      }else if (storageEvent.type == StorageTaskEventType.success){
        setState(() {
          _subindoImagem=false;
        });
      }
    });
    task.onComplete.then(
            (StorageTaskSnapshot snapshot){
          _recuperarUrlImagem(snapshot, nomeImagem);
        }
    );
  }
  Future _uploadVideo(String nomeVideo){
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child(_nomeCampanha).child('video.mp4');
    StorageUploadTask task = arquivo.putFile(_videoUpload, StorageMetadata(contentType: 'video.mp4'));

    task.events.listen((StorageTaskEvent storageEvent){
      if(storageEvent.type == StorageTaskEventType.progress){
        setState(() {
          _subindoImagem=true;
        });
      }else if (storageEvent.type == StorageTaskEventType.success){
        setState(() {
          _subindoImagem=false;
        });
      }
    });
    task.onComplete.then(
            (StorageTaskSnapshot snapshot){
          _recuperarUrlImagem(snapshot, nomeVideo);
        }
    );
  }



  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot, String nomeImagem)async{
    String url = await snapshot.ref.getDownloadURL();
    setState(() {
      switch(nomeImagem){
        case 'ImagemLogotipo': setState(() {
          _ImagemLogo = url;
          ImageLogo=true;
        });
        break;
        case 'Imagem1': setState(() {
          _Imagem1 = url;
          Imagem1=true;
        });
        break;
        case 'Imagem2': setState(() {
          _Imagem2 = url;
          Imagem2=true;
        });
        break;
        case 'video.mp4': setState(() {
          _video = url;
          video = true;
        });
        break;
      }
    });
  }

  _verificarNome()async{    setState(() {
    _nomeExite=false;
  });
  QuerySnapshot querySnapshot = await Firestore.instance.collection('campanhas').getDocuments();
  for(DocumentSnapshot item in querySnapshot.documents){
    if(item.data['nomeCampanha'] ==_nomeTeste){
      setState(() {
        _nomeExite=true;
      });
    }
  }
  if(_nomeExite!=true){
    setState(() {
      _nomeCampanha=_nomeTeste;
    });
  }else{

  }
  }

  _verificarTipo()async{
    setState(() {
      _campanhaExiste=false;
    });
    QuerySnapshot querySnapshot = await Firestore.instance.collection('campanhas').getDocuments();
    for(DocumentSnapshot item in querySnapshot.documents){
      print(item.data['nomeEmpresa'] );
      print(item.data['tipoCampanha']);
      print(item.data['situaçãoDaCampanha'] );
      if((item.data['nomeEmpresa'] == _nome) && (item.data['tipoCampanha'] == _tipoCampanha) && (item.data['situaçãoDaCampanha'] =='aberta')){
        print('---------------------------------');
        print(item.data['nomeEmpresa'] );
        print(item.data['tipoCampanha']);
        print(item.data['situaçãoDaCampanha'] );
        setState(() {
          _campanhaExiste=true;
        });
      }
    }
    print(_campanhaExiste.toString());
  }

  _validarCampos(){
    _mensagemErro='';
    if(_tipoCampanha != null ){
      print('Ok tipo campanha');
      if(_tipoCampanha == 'Produto'){
        print('tipo campanha: produto');
        if(_controllerNomeProduto.text.isEmpty){
          setState(() {
            _mensagemErro= 'nome do produto para divulgação não informado';
          });
        }else{
          print('ok nome');
          if(_enviaProduto != null){
            print('ok envia produto');
            if(_enviaProduto == 'sim'){
              print('empresa envia produto');
              //rota continua
              if(_controllerValorPorVisualizacao.text.isEmpty){
                print('valor por view vazio');
                setState(() {
                  _mensagemErro='Não informado o valor por visualização';
                });
              }else{
                print('valor por view ok');
                if(_controllerValorMaximoPorVideo.text.isEmpty){
                  print('valor maximo por video não informado');
                  setState(() {
                    _mensagemErro='valor maximo por video não informado';
                  });
                }else{
                  print('valor maximo ok');

                  if(_controllerInstrucoes.text.isEmpty){
                    print('instruções não informadas');
                    setState(() {
                      _mensagemErro='instruções não informadas';
                    });
                  }else{
                    print('ok instruções');
                    _salvarCampanha();
                  }

                }

              }

            }else{
              print('empresa não envia produto');
              //rota continua
              if(_controllerValorPorVisualizacao.text.isEmpty){
                print('valor por view vazio');
                setState(() {
                  _mensagemErro='Não informado o valor por visualização';
                });
              }else{
                print('valor por view ok');
                if(_controllerValorMaximoPorVideo.text.isEmpty){
                  print('valor maximo por video não informado');
                  setState(() {
                    _mensagemErro='valor maximo por video não informado';
                  });
                }else{
                  print('valor maximo ok');

                  if(_controllerInstrucoes.text.isEmpty){
                    print('instruções não informadas');
                    setState(() {
                      _mensagemErro='instruções não informadas';
                    });
                  }else{
                    print('ok instruções');
                    _salvarCampanha();
                  }

                }

              }
            }


          }else{
            print('não informado se a empresa envia o produto');
            setState(() {
              _mensagemErro='não informado se a empresa envia o produto';
            });
          }
        }


      }else{
        //rota continua
        if(_controllerValorPorVisualizacao.text.isEmpty){
          print('valor por view vazio');
          setState(() {
            _mensagemErro='Não informado o valor por visualização';
          });
        }else{
          print('valor por view ok');
          if(_controllerValorMaximoPorVideo.text.isEmpty){
            print('valor maximo por video não informado');
            setState(() {
              _mensagemErro='valor maximo por video não informado';
            });
          }else{
            print('valor maximo ok');

            if(_controllerInstrucoes.text.isEmpty){
              print('instruções não informadas');
              setState(() {
                _mensagemErro='instruções não informadas';
              });
            }else{
              print('ok instruções');
              _salvarCampanha();
            }

          }

        }
      }


    }else{
      setState(() {
        _mensagemErro='tipo campanha não selecionado';
      });
    }
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text('Nova campanha'),
        ),
        body:
        Container(
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width,
            child: _idUsuarioLogado == null ? Center(child: CircularProgressIndicator(), ) :
            SingleChildScrollView(
                child:  Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _nomeCampanha == null ?
                          Padding(padding: EdgeInsets.only(bottom: 0, top: 16),
                            child: Text('Nome da campanha', style: TextStyle(fontWeight: FontWeight.bold),),
                          ) : Container(),
                          _nomeCampanha == null ?
                          Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 8),
                            child: Text('Nome pelo qual a campanha sera identificada', style: TextStyle(fontSize: 12),),
                          ) : Container(),
                          _nomeCampanha == null ? Padding(padding: EdgeInsets.only(bottom: 2),
                            child: TextField(
                                controller: _controllerNomeCampanha,
                                decoration: InputDecoration(
                                    hintText: 'nome da campanha',
                                    filled: true,
                                    suffixIcon: IconButton(icon: Icon(Icons.file_upload), color: _nomeCampanha != null ? Colors.blue : Colors.grey ,onPressed: (){
                                      if(_controllerNomeCampanha.text.isNotEmpty){
                                        setState(() {
                                          _nomeTeste= _controllerNomeCampanha.text;
                                        });
                                        _verificarNome();
                                      }else{
                                        setState(() {
                                          _mensagemErro='O nome da campanha não pode ser vazia';
                                        });
                                      }
                                    }),
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                )
                            ),
                          ) : Padding(padding: EdgeInsets.only(bottom: 16, top: 16),
                            child: Text('Nome da campanha: ' + _nomeCampanha, style: TextStyle(),),
                          ),
                          _nomeCampanha == null ? Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 8),
                            child: Text('Escolha um nome para a campanha e clique na seta', style: TextStyle(fontSize: 12),),
                          ) : Container(),
                          _nomeExite == true ? Center(child: Text('Este nome não esta disponivel', style: TextStyle(color: Colors.red),),) : Container(),
                          _nomeCampanha == null ? Container() :
                          Column(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(bottom: 16, top: 16),
                                  child: Text('Tipo de campanha', style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                Column(children: <Widget>[
                                  RadioListTile(title: Text('Institucional'), subtitle: Text('Divulgação da empresa') ,value: 'Institucional', groupValue: _tipoCampanha, onChanged: (novo){
                                    setState(() {
                                      _tipoCampanha=novo;
                                    });
                                    _verificarTipo();
                                  }),
                                  RadioListTile(title: Text('Promoção'), subtitle: Text('Divulgação de uma promoção') , value: 'Promoção', groupValue: _tipoCampanha, onChanged: (novo){
                                    setState(() {
                                      _tipoCampanha=novo;
                                    });
                                    _verificarTipo();
                                  }),
                                  /*
                                  RadioListTile(title: Text('Produto'), subtitle: Text('Divulgação de um produto') , value: 'Produto', groupValue: _tipoCampanha, onChanged: (novo){
                                    setState(() {
                                      _tipoCampanha=novo;
                                    });
                                    _verificarTipo();
                                  }),
                                   */
                                  _tipoCampanha == 'Produto' ?
                                  Column(
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.only(bottom: 2, top: 16),
                                        child: Text('Nome do Produto', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                      Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 8),
                                        child: Text('Nome do produto que deve ser divulgado', style: TextStyle(fontSize: 12),),
                                      ),
                                    ],): Container(),

                                  _tipoCampanha == 'Produto' ?
                                  Padding(padding: EdgeInsets.only(bottom: 8),
                                    child: TextField(
                                        controller: _controllerNomeProduto,
                                        decoration: InputDecoration(
                                            hintText: 'nome do produto',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                        )
                                    ),) : Container(),

                                  _tipoCampanha == 'Produto' ?
                                  Padding(padding: EdgeInsets.only(bottom: 2, top: 16),
                                    child: Text('Envia Produto?', style: TextStyle(fontWeight: FontWeight.bold),),
                                  ) : Container(),

                                  _tipoCampanha == 'Produto' ?
                                  Column(children: <Widget>[
                                    Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 8),
                                      child: Text('A empresa enviara o produto que deve ser divulgado', style: TextStyle(fontSize: 12),),
                                    ),
                                    RadioListTile(title: Text('sim') ,value: 'sim', groupValue: _enviaProduto, onChanged: (novo){
                                      setState(() {
                                        _enviaProduto=novo;
                                      });
                                    }),
                                    RadioListTile(title: Text('não'), value: 'não', groupValue: _enviaProduto, onChanged: (novo){
                                      setState(() {
                                        _enviaProduto=novo;
                                      });
                                    }),
                                  ]
                                  ) : Container(),
                                  _enviaProduto == 'sim' ? Text('caso seja necessária a devolução do produto a empresa deve informar na observação') : Container(),
                                  _enviaProduto == 'sim' ? Padding(padding: EdgeInsets.only(top: 8),
                                      child: Text('(Importante) A Penrose não se responsabiliza pelo envio ou devolução dos produtos, sendo totalmente da empresa o risco de danos ou perdas do material enviado', style: TextStyle(fontSize: 10),)
                                  ): Container(),

                                  Padding(padding: EdgeInsets.only(bottom: 16, top: 16),
                                    child: Text('Pagamento', style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 2),
                                    child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: _controllerValorPorVisualizacao,
                                        decoration: InputDecoration(
                                            hintText: 'valor por visualização ex: 0.025',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                        )
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 16, top: 0, left: 16),
                                    child: Text('utilize ponto ao invés de virgula ex: se a empresa colocar 0.025 um vídeo com 1000 visualizações custara R\$: 25,00', style: TextStyle(fontSize: 12),),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 2),
                                    child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: _controllerValorMaximoPorVideo,
                                        decoration: InputDecoration(
                                            hintText: 'Não utilize ponto ex: 6000',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                        )
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 16),
                                    child: Text('valor maximo que a empresa ira pagar por cada video', style: TextStyle(fontSize: 12),),
                                  ),

                                  Padding(padding: EdgeInsets.only(bottom: 2, top: 16),
                                    child: Text('Arquivos de apoio (Opcional)', style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 16),
                                    child: Text('arquivos para serem usados durante a divulgação', style: TextStyle(fontSize: 12),),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.image),
                                            color: ImageLogo == false ? Colors.grey : Colors.blue,
                                            onPressed: (){
                                              _salvarImagem('ImagemLogotipo');
                                            },
                                          ),
                                          Text('Logotipo')
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.image),
                                            color: Imagem1 == false ? Colors.grey : Colors.blue,
                                            onPressed: (){
                                              _salvarImagem('Imagem1');
                                            },
                                          ),
                                          Text('Imagem')
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.image),
                                            color: Imagem2 == false ? Colors.grey : Colors.blue,
                                            onPressed: (){
                                              _salvarImagem('Imagem2');
                                            },
                                          ),
                                          Text('Imagem')
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.videocam),
                                            color: video == false ? Colors.grey : Colors.blue,
                                            onPressed: (){
                                              _salvarVideo('video.mp4');
                                            },
                                          ),
                                          Text('video')
                                        ],
                                      )
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        _subindoImagem == true ? Padding(padding: EdgeInsets.only(top: 16),
                                          child: CircularProgressIndicator(),) : Container(),
                                        Padding(padding: EdgeInsets.only(bottom: 16, top: 16),
                                          child: Text('Instruções', style: TextStyle(fontWeight: FontWeight.bold),),
                                        ),
                                        Padding(padding: EdgeInsets.only(bottom: 2),
                                          child: TextField(
                                              controller:_controllerInstrucoes,
                                              decoration: InputDecoration(
                                                  hintText: 'Insira informações para divulgação',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                              )
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(bottom: 8, top: 0, left: 16),
                                          child: Text('insira as instruções de como deve ser feita a divulgação', style: TextStyle(fontSize: 12),),
                                        ),
                                        Padding(padding: EdgeInsets.only(bottom: 16, top: 16),
                                          child: Text('Obervação (Opcional)', style: TextStyle(fontWeight: FontWeight.bold),),
                                        ),
                                        Padding(padding: EdgeInsets.only(bottom: 2),
                                          child: TextField(
                                              controller: _controllerObservacao,
                                              decoration: InputDecoration(
                                                  hintText: 'Observação',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))
                                              )
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(bottom: 16, top: 0, left: 16),
                                          child: Text('Informação que os interessados devem saber antes de aceitarem a campanha, ex apenas canais de culinaria, necessario comprar algum produto, etc', style: TextStyle(fontSize: 12),),
                                        ),
                                        _campanhaExiste == true ?
                                        Padding(padding: EdgeInsets.only(left: 8, right: 8),
                                            child: Text('A empresa já possui uma campanha aberta do tipo : ' + _tipoCampanha + ', não é permitido ter mais de uma campanha de cada tipo em situação aberta', style: TextStyle(color: Colors.red, fontSize: 12),)
                                        )     :
                                        RaisedButton(
                                            color: Colors.blue[800],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              //side: BorderSide(color: Color(0xff990000))
                                            ),
                                            child: Text('Salvar', style: TextStyle(color: Colors.white),),
                                            onPressed: (){
                                              _validarCampos();
                                            }
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                                ),
                                _mensagemErro != '' ? Padding(padding: EdgeInsets.only(left: 16, right: 16),
                                  child: Text(_mensagemErro, style: TextStyle(fontSize: 12, color: Colors.red),) ,
                                ): Container()
                              ]
                          )
                        ],
                      )
                    ]
                )
            )
        )
    );
  }
}
