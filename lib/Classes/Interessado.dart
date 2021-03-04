
class Interessado {

  String _nome;
  String _ramo;
  String _urlImagem;
  String _urlCanal;

  Interessado(this._nome, this._ramo, this._urlImagem, this._urlCanal);

  String get urlCanal => _urlCanal;

  set urlCanal(String value) {
    _urlCanal = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
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