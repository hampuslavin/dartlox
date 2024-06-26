// AUTO - GENERATED FILE !!!

import 'Expr.dart';
import 'Token.dart';

abstract class Stmt {
  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitBlockStmt(Block stmt);
  R visitBreakStmt(Break stmt);
  R visitExpressionStmt(Expression stmt);
  R visitFunction_Stmt(Function_ stmt);
  R visitIfStmt(If stmt);
  R visitPrintStmt(Print stmt);
  R visitReturnStmt(Return stmt);
  R visitVarStmt(Var stmt);
  R visitWhileStmt(While stmt);
}
class Block extends Stmt {
  final List<Stmt?> statements;

  Block(this.statements, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
}
class Break extends Stmt {
  final Token token;

  Break(this.token, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBreakStmt(this);
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
class Function_ extends Stmt {
  final Token? name;
  final List<Token> params;
  final List<Stmt> body;

  Function_(this.name, this.params, this.body, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitFunction_Stmt(this);
  }
}
class If extends Stmt {
  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;

  If(this.condition, this.thenBranch, this.elseBranch, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitIfStmt(this);
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
class Return extends Stmt {
  final Token keyword;
  final Expr? value;

  Return(this.keyword, this.value, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitReturnStmt(this);
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
class While extends Stmt {
  final Expr condition;
  final Stmt body;

  While(this.condition, this.body, );

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitWhileStmt(this);
  }
}


