import 'Environment.dart';
import 'Interpreter.dart';
import 'LoxCallable.dart';
import 'Stmt.dart' as Stmt;

class LoxFunction implements LoxCallable {
  Stmt.Function_ _declaration;
  LoxFunction(this._declaration) {}

  @override
  int arity() {
    return _declaration.params.length;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    Environment environment = new Environment(interpreter.globals);
    for (int i = 0; i < _declaration.params.length; i++) {
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }

    interpreter.executeBlock(_declaration.body, environment);
    return null;
  }

  @override
  String toString() {
    return "<fn ${_declaration.name.lexeme}>";
  }
}
