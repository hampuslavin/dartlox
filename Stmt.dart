// AUTO - GENERATED FILE !!!

import 'Expr.dart';
import 'Token.dart';

abstract class Stmt {
  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitBlockStmt(Block stmt);
  R visitExpressionStmt(Expression stmt);
  R visitPrintStmt(Print stmt);
  R visitVarStmt(Var stmt);
}
class Block extends Stmt {
  final List<Stmt?> statements;

  Block(this.statements, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
}
class Expression extends Stmt {
  final Expr expression;

  Expression(this.expression, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}
class Print extends Stmt {
  final Expr expression;

  Print(this.expression, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}
class Var extends Stmt {
  final Token name;
  final Expr? initializer;

  Var(this.name, this.initializer, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}


