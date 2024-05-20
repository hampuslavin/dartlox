import 'Expr.dart';
import 'Lox.dart';
import 'RuntimeError.dart';
import 'Token.dart';
import 'TokenType.dart';

class Interpreter implements Visitor<Object?> {
  Object? interpret(Expr expression) {
    try {
      Object? value = _evaluate(expression);
      print(_stringify(value));
    } on RuntimeError catch (error) {
      Lox.runtimeError(error);
    }
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
  Object? visitBinaryExpr(Binary expr) {
    Object? left = _evaluate(expr.left);
    Object? right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.MINUS:
        _checkNumberOperand(expr.operator, right);
        return (left as double) - (right as double);
      case TokenType.SLASH:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) / (right as double);
      case TokenType.STAR:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) * (right as double);
      case TokenType.PLUS:
        {
          _checkNumberOperands(expr.operator, left, right);
          if (left is double && right is double) {
            return (left) +
                (right); // no difference in Dart between numbers and string addition
          }
          if (left is String && right is String) {
            return (left) + (right);
          }
          break;
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
  Object? visitGroupingExpr(Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitTernaryExpr(Ternary expr) {
    Object? condition = _evaluate(expr.condition);
    if (_isTruthy(condition)) {
      return _evaluate(expr.left);
    }

    return _evaluate(expr.right);
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
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

  Object? _evaluate(Expr expr) {
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
}
