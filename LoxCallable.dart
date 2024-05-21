import 'Interpreter.dart';

abstract class LoxCallable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments);
  String toString();
}
