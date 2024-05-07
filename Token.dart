import 'TokenType.dart';

class Token {
  TokenType type;
  String lexeme;
  Object? literal;
  int line;

  Token(this.type, this.lexeme, this.literal, this.line) {}

  String toString() {
    return type.name + " " + lexeme + " " + literal.toString();
  }
}
