import 'Token.dart';

class RuntimeError implements Exception {
  final Token token;
  final String message;
  RuntimeError(this.token, this.message) {}
}

class BreakException implements Exception {
  final Token token;

  BreakException(this.token);
}
