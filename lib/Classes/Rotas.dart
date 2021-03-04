import 'package:flutter/material.dart';
import 'package:penrose/Ajuda.dart';
import 'package:penrose/Cadastro.dart';
import 'package:penrose/ContaBloqueada.dart';
import 'package:penrose/EnviarVideo.dart';
import 'package:penrose/Hist%C3%B3rico.dart';
import 'package:penrose/Home.dart';
import 'package:penrose/Inicio.dart';
import 'package:penrose/Login.dart';
import 'package:penrose/NovaCampanha.dart';
import 'package:penrose/Perfil.dart';
import 'package:penrose/Telas/CampanhasAdm.dart';
import 'package:penrose/Telas/EmpresasAdm.dart';
import 'package:penrose/Telas/SalvarDadosCanal.dart';
import 'package:penrose/Telas/TelaAdministrador.dart';
import 'package:penrose/Telas/TelaInteressados.dart';
import 'package:penrose/Telas/TelaInteressadosAdm.dart';
import 'package:penrose/Telas/TelaNovosUsuarios.dart';
import 'package:penrose/Telas/UsuariosAdm.dart';
import 'package:penrose/TermoDeUso.dart';
import 'package:penrose/recuperarSenha.dart';



class Rotas {

  static const String Rota_Inicio = '/';
  static const String Rota_Login = '/login';
  static const String Rota_Home = '/home';
  static const String Rota_Perfil = '/perfil';
  static const String Rota_Cadastro = '/cadastro';
  static const String Rota_Historico = '/historico';
  static const String Rota_NovaCampanha = '/novacampanha';
  static const String Rota_TelaInteressados = '/telaInteressados';
  static const String Rota_RecuperarSenha = '/recuperarSenha';
  static const String Rota_Ajuda = '/ajuda';
  static const String Rota_Administracao = '/administracao';
  static const String Rota_InteressadosAdm = '/telaInteressadosAdm';
  static const String Rota_ContaBloqueada = '/contaBloqueada';
  static const String Rota_CampanhasAdm = '/campanhasAdm';
  static const String Rota_UsuariosAdm = '/usuariosAdm';
  static const String Rota_EmpresasAdm = '/empresasAdm';
  static const String Rota_Termosdeuso = '/termosdeuso';
  static const String Rota_NovosUsuarios = '/novosUsuariosAdm';
  static const String Rota_SalvarDadosCanal = '/salvarDadosCanal';
  static const String Rota_EnviarVideo = '/enviarVideo';


  static Route<dynamic> gerarRotas(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case Rota_Inicio:
        return MaterialPageRoute(builder: (_)=> Inicio());
      case Rota_Login:
        return MaterialPageRoute(builder: (_)=> Login());
      case Rota_Home:
        return MaterialPageRoute(builder: (_)=> Home());
      case Rota_Perfil:
        return MaterialPageRoute(builder: (_)=> Perfil());
      case Rota_Cadastro:
        return MaterialPageRoute(builder: (_)=> Cadastro());
      case Rota_Historico:
        return MaterialPageRoute(builder: (_)=> Historico());
      case Rota_NovaCampanha:
        return MaterialPageRoute(builder: (_)=> NovaCampanha());
      case Rota_TelaInteressados:
        return MaterialPageRoute(builder: (_)=> TelaInteressados(args));
      case Rota_RecuperarSenha:
        return MaterialPageRoute(builder: (_)=> RecuperarSenha());
      case Rota_Ajuda:
        return MaterialPageRoute(builder: (_)=> Ajuda());
      case Rota_Administracao:
        return MaterialPageRoute(builder: (_)=> Administracao());
      case Rota_ContaBloqueada:
        return MaterialPageRoute(builder: (_)=> ContaBloqueada());
      case Rota_CampanhasAdm:
        return MaterialPageRoute(builder: (_)=> CampanhasAdm());
      case Rota_UsuariosAdm:
        return MaterialPageRoute(builder: (_)=> UsuariosAdm());
      case Rota_EmpresasAdm:
        return MaterialPageRoute(builder: (_)=> EmpresasAdm());
      case Rota_InteressadosAdm:
        return MaterialPageRoute(builder: (_)=> TelaInteressadosAdm(args));
      case Rota_Termosdeuso:
        return MaterialPageRoute(builder: (_)=> Termosdeuso());
      case Rota_NovosUsuarios:
        return MaterialPageRoute(builder: (_)=> NovosUsuariosAdm());
      case Rota_SalvarDadosCanal:
        return MaterialPageRoute(builder: (_)=> SalvarDadosCanal(args));
      case Rota_EnviarVideo:
        return MaterialPageRoute(builder: (_)=> EnviarVideo());
      default:
    _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(builder:(_){
      return Scaffold(
        body: Center(
          child: Text('Tela não encontrada'),
        ),
      );
    }
    );
  }
}
