import "Expr.dart";
import "Token.dart";
import "TokenType.dart";

class AstPrinter implements Visitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return _parenthesize(
        expr.operator.lexeme, List.of([expr.left, expr.right]));
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return _parenthesize("group", List.of([expr.expression]));
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) return "nil";

    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return _parenthesize(expr.operator.lexeme, List.of([expr.right]));
  }

  @override
  String visitTernaryExpr(Ternary expr) {
    return _parenthesize("ternary", [expr.condition, expr.left, expr.right]);
  }

  String _parenthesize(String name, List<Expr> expressions) {
    String string = "(";

    string += name;
    for (final expression in expressions) {
      string += " ";
      string += expression.accept(this);
    }
    string += ")";

    return string;
  }
}

void main() {
  // Expr expression = Binary(
  //     Unary(Token(TokenType.MINUS, "-", null, 1), Literal(123)),
  //     Token(TokenType.STAR, "*", null, 1),
  //     Grouping(Literal(45.67)));
  Expr expression = Binary(
      Binary(Literal(1), Token(TokenType.PLUS, "+", null, 1), Literal(2)),
      Token(TokenType.STAR, "*", null, 1),
      Binary(Literal(4), Token(TokenType.MINUS, "-", null, 1), Literal(3)));

  print(AstPrinter().print(expression));
}
