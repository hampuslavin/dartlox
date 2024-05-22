import 'Environment.dart';
import 'Interpreter.dart';
import 'LoxCallable.dart';
import 'Return.dart';
import 'Stmt.dart' as Stmt;

class LoxFunction implements LoxCallable {
  Stmt.Function_ _declaration;
  Environment _closure;

  LoxFunction(this._declaration, this._closure) {}

  @override
  int arity() {
    return _declaration.params.length;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = new Environment(_closure);
    for (int i = 0; i < _declaration.params.length; i++) {
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }

    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on Return catch (returnValue) {
      return returnValue.value;
    }
    return null;
  }

  @override
  String toString() {
    return "<fn ${_declaration.name?.lexeme ?? 'anonymous function'}>";
  }
}
