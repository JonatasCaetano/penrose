
class Usuario {

  String _nome;
  String _ramo;
  String _tipo;
  String _urlImagem;
  String _urlCanal;
  String _numeroDeInscritos;
  String _mediaDeVisualizacoes;


  Usuario(this._nome, this._ramo, this._tipo, this._urlImagem, this._urlCanal, this._numeroDeInscritos, this._mediaDeVisualizacoes);


  String get mediaDeVisualizacoes => _mediaDeVisualizacoes;

  set mediaDeVisualizacoes(String value) {
    _mediaDeVisualizacoes = value;
  }

  String get numeroDeInscritos => _numeroDeInscritos;

  set numeroDeInscritos(String value) {
    _numeroDeInscritos = value;
  }

  String get urlCanal => _urlCanal;

  set urlCanal(String value) {
    _urlCanal = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get ramo => _ramo;

  set ramo(String value) {
    _ramo = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }


}