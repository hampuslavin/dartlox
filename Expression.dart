import 'Token.dart';

abstract class Expr {}

class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  Binary(
    this.left,
    this.operator,
    this.right,
  );
}
