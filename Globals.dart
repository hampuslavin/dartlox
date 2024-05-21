import 'Interpreter.dart';
import 'LoxCallable.dart';

class ClockCallable implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  String toString() {
    return "<native fn>";
  }

  @override
  Object call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000.0;
  }
}
