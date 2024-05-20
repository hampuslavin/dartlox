// AUTO - GENERATED FILE !!!

import 'Token.dart';

abstract class Expr {
  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitAssignExpr(Assign expr);
  R visitBinaryExpr(Binary expr);
  R visitGroupingExpr(Grouping expr);
  R visitLiteralExpr(Literal expr);
  R visitUnaryExpr(Unary expr);
  R visitTernaryExpr(Ternary expr);
  R visitVariableExpr(Variable expr);
}
class Assign extends Expr {
  final Token name;
  final Expr value;

  Assign(this.name, this.value, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitAssignExpr(this);
  }
}
class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  Binary(this.left, this.operator, this.right, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}
class Grouping extends Expr {
  final Expr expression;

  Grouping(this.expression, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}
class Literal extends Expr {
  final Object? value;

  Literal(this.value, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}
class Unary extends Expr {
  final Token operator;
  final Expr right;

  Unary(this.operator, this.right, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}
class Ternary extends Expr {
  final Expr condition;
  final Expr left;
  final Expr right;

  Ternary(this.condition, this.left, this.right, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitTernaryExpr(this);
  }
}
class Variable extends Expr {
  final Token name;

  Variable(this.name, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitVariableExpr(this);
  }
}


