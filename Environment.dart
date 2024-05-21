import 'RuntimeError.dart';
import 'Token.dart';

class Environment {
  final Map<String, Object?> _values = new Map();
  Environment? enclosing;

  Environment(this.enclosing);

  void define(String name, Object? value) {
    _values[name] = value;
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }
    var localEnclosing = enclosing;
    if (localEnclosing != null) return localEnclosing.get(name);

    throw new RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
    } else {
      var enclosing = this.enclosing;
      if (enclosing != null) {
        return enclosing.assign(name, value);
      }
      throw new RuntimeError(name, "Undefined variable '${name.lexeme}'.");
    }
  }
}
