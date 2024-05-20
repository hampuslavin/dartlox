import 'Environment.dart';
import 'Expr.dart' as Expr;
import 'Stmt.dart' as Stmt;
import 'Lox.dart';
import 'RuntimeError.dart';
import 'Token.dart';
import 'TokenType.dart';

class Interpreter implements Expr.Visitor<Object?>, Stmt.Visitor<void> {
  Environment _environment = new Environment();

  Object? interpret(List<Stmt.Stmt> statements) {
    try {
      for (final stmt in statements) {
        _execute(stmt);
      }
    } on RuntimeError catch (error) {
      Lox.runtimeError(error);
    }
  }

  void _execute(Stmt.Stmt statement) {
    statement.accept(this);
  }

  String _stringify(Object? object) {
    if (object == null) return "nil";

    if (object is double) {
      String text = object.toString();
      if (text.endsWith(".0")) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }

    return object.toString();
  }

  @override
  Object? visitBinaryExpr(Expr.Binary expr) {
    Object? left = _evaluate(expr.left);
    Object? right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.MINUS:
        _checkNumberOperand(expr.operator, right);
        return (left as double) - (right as double);
      case TokenType.SLASH:
        _checkNumberOperands(expr.operator, left, right);
        if (right == 0) {
          throw RuntimeError(expr.operator, "Division by zero not allowed.");
        }
        return (left as double) / (right as double);
      case TokenType.STAR:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) * (right as double);
      case TokenType.PLUS:
        {
          if (left is double && right is double) {
            // no difference in Dart between numbers and string addition
            return left + right;
          }
          if (left is String && right is String) {
            return "$left$right";
          }
          if ((left is String && right is double) ||
              left is double && right is String) {
            return "${_stringify(left)}${_stringify(right)}";
          }
          throw RuntimeError(
              expr.operator, "Combination of operands not allowed.");
        }
      case TokenType.GREATER:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) > (right as double);
      case TokenType.GREATER_EQUAL:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) >= (right as double);
      case TokenType.LESS:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) < (right as double);
      case TokenType.LESS_EQUAL:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) <= (right as double);
      case TokenType.BANG_EQUAL:
        return !_isEqual(left, right);
      case TokenType.EQUAL_EQUAL:
        return _isEqual(left, right);
      default:
        throw UnimplementedError();
    }
  }

  @override
  Object? visitGroupingExpr(Expr.Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Expr.Literal expr) {
    return expr.value;
  }

  @override
  Object? visitTernaryExpr(Expr.Ternary expr) {
    Object? condition = _evaluate(expr.condition);
    if (_isTruthy(condition)) {
      return _evaluate(expr.left);
    }

    return _evaluate(expr.right);
  }

  @override
  Object? visitUnaryExpr(Expr.Unary expr) {
    Object? right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.BANG:
        return _isTruthy(right);
      case TokenType.MINUS:
        return -(right as double);
      default:
        throw UnimplementedError();
    }
  }

  Object? _evaluate(Expr.Expr expr) {
    return expr.accept(this);
  }

  bool _isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return !!object;

    return true;
  }

  bool _isEqual(Object? left, Object? right) {
    if (left == null && right == null) return true;
    if (left == null) return false;

    return left == right;
  }

  void _checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) return;
    throw RuntimeError(operator, "Operand must be a number.");
  }

  void _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is double && right is double) return;
    throw RuntimeError(operator, "Operands must be a numbers.");
  }

  @override
  void visitExpressionStmt(Stmt.Expression stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitPrintStmt(Stmt.Print stmt) {
    Object? value = _evaluate(stmt.expression);
    print(_stringify(value));
  }

  @override
  void visitVarStmt(Stmt.Var stmt) {
    Object? value = null;
    var initializer = stmt.initializer;
    if (initializer != null) {
      value = _evaluate(initializer);
    }

    _environment.define(stmt.name.lexeme, value);
  }

  @override
  Object? visitVariableExpr(Expr.Variable expr) {
    return _environment.get(expr.name);
  }

  @override
  Object? visitAssignExpr(Expr.Assign expr) {
    Object? value = _evaluate(expr.value);
    _environment.assign(expr.name, value);

    return value;
  }
}
