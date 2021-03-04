import 'package:flutter/material.dart';
import 'package:penrose/Classes/Rotas.dart';
import 'package:penrose/Inicio.dart';

void main()async{
  runApp(MaterialApp(
    title: 'Penrose',
    home: Inicio(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Color(0xff990000),
      accentColor: Color(0xff990000)
    ),
    initialRoute: '/',
    onGenerateRoute: Rotas.gerarRotas,
   )
  );
}
