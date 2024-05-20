import 'RuntimeError.dart';
import 'Token.dart';

class Environment {
  final Map<String, Object?> _values = new Map();

  void define(String name, Object? value) {
    _values[name] = value;
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    throw new RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  void assign(Token name, Object? value) {
    _values.update(
      name.lexeme,
      (_) => value,
      ifAbsent: () =>
          throw new RuntimeError(name, "Undefined variable '${name.lexeme}'."),
    );
  }
}
